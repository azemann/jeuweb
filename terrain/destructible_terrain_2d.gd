@tool
class_name DestructibleTerrain2D
extends Node2D

const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

signal terrain_generated(solid_pixels: int, chunk_count: int)
signal terrain_carved(center: Vector2, radius: float, affected_chunks: int)

@export_category("Authority")
## Profil de rendu et de performance ; la géométrie initiale vient des zones auteur.
@export var profile: DestructibleTerrainProfile:
	set(value):
		profile = value
		update_configuration_warnings()
## Branche contenant Area2D, CollisionShape2D ou CollisionPolygon2D auteurs.
@export_node_path("Node2D") var authored_zones_path := NodePath("../Gameplay/DestructibleZones")
## Branche des pièces glissables. Les instances Carvable sont composées dans le masque global.
@export_node_path("Node2D") var ground_pieces_path := NodePath("../Gameplay/GroundPieces")
## Construit automatiquement masque visuel et collisions à l'entrée de la scène runtime.
@export var generate_on_ready := true

@export_category("Physics")
## Couche physique des chunks solides générés ; elle doit correspondre aux masques du joueur et des projectiles.
@export_flags_2d_physics var collision_layer := 1
## Couches interrogées par le terrain ; garder uniquement celles nécessaires aux interactions physiques prévues.
@export_flags_2d_physics var collision_mask := 2

@export_category("Editor Preview")
## Affiche les limites des chunks pour diagnostiquer les coûts et raccords de reconstruction.
@export var show_chunk_grid := false
## Rend le terrain semi-transparent dans l'éditeur afin de comparer masque, pièces et zones sources.
@export var debug_transparency := false
## Centre local, en pixels, du cratère créé par le bouton de test de l'Inspector.
@export var preview_crater_position := Vector2(920, 560)
## Rayon, en pixels, du cratère de prévisualisation ; ce réglage ne modifie aucun projectile.
@export_range(8.0, 300.0, 1.0) var preview_crater_radius := 64.0
## Reconstruit le masque depuis les zones et pièces Carvable actuellement présentes dans l'éditeur.
@export_tool_button("Régénérer depuis les zones") var regenerate_button := editor_regenerate
## Creuse un cratère non sauvegardé aux coordonnées de prévisualisation pour contrôler le rendu.
@export_tool_button("Tester un cratère") var crater_button := editor_preview_crater

var mask_image: Image
var fresh_cut_image: Image
var display_image: Image
var authored_color_image: Image
var display_texture: ImageTexture
var collision_bitmap: BitMap
var collision_bitmap_build_count := 0
var _chunk_bodies: Dictionary = {}
var _texture_images: Dictionary = {}


func _ready() -> void:
	add_to_group(&"destructible_terrains")
	if generate_on_ready:
		generate_from_authored_zones()


func authored_zones_root() -> Node2D:
	return get_node_or_null(authored_zones_path) as Node2D


func ground_pieces_root() -> Node2D:
	return get_node_or_null(ground_pieces_path) as Node2D


func collect_carvable_pieces() -> Array[GroundPiece2DType]:
	var result: Array[GroundPiece2DType] = []
	var pieces_root := ground_pieces_root()
	if pieces_root == null:
		return result
	for child in pieces_root.find_children("*", "GroundPiece2D", true, false):
		var piece := child as GroundPiece2DType
		if piece != null and piece.ground_mode == GroundPiece2DType.GroundMode.CARVABLE:
			result.append(piece)
	result.sort_custom(func(a: GroundPiece2DType, b: GroundPiece2DType) -> bool:
		if a.render_priority != b.render_priority:
			return a.render_priority < b.render_priority
		return str(a.get_path()) < str(b.get_path())
	)
	return result


func generate_from_authored_zones() -> void:
	if profile == null or not profile.is_valid():
		push_error("DestructibleTerrain2D exige un profil valide.")
		return
	var zones := authored_zones_root()
	var pieces := collect_carvable_pieces()
	if zones == null and pieces.is_empty():
		push_error("Aucune source auteur de terrain destructible n'est disponible.")
		return
	mask_image = Image.create(profile.world_size.x, profile.world_size.y, false, Image.FORMAT_RGBA8)
	mask_image.fill(Color.TRANSPARENT)
	fresh_cut_image = Image.create(profile.world_size.x, profile.world_size.y, false, Image.FORMAT_RGBA8)
	fresh_cut_image.fill(Color.TRANSPARENT)
	authored_color_image = Image.create(profile.world_size.x, profile.world_size.y, false, Image.FORMAT_RGBA8)
	authored_color_image.fill(Color.TRANSPARENT)
	_cache_texture_images()
	if zones != null:
		for zone in zones.get_children():
			_rasterize_zone(zone)
	for piece in pieces:
		_rasterize_ground_piece(piece)
	collision_bitmap = BitMap.new()
	collision_bitmap.create_from_image_alpha(mask_image, 0.5)
	collision_bitmap_build_count += 1
	_rebuild_display_image()
	_rebuild_all_chunks()
	queue_redraw()
	terrain_generated.emit(collision_bitmap.get_true_bit_count(), _chunk_bodies.size())


func editor_regenerate() -> void:
	generate_from_authored_zones()


func editor_preview_crater() -> int:
	if mask_image == null:
		generate_from_authored_zones()
	return carve_circle(to_global(preview_crater_position), preview_crater_radius)


func carve_circle(world_center: Vector2, radius: float) -> int:
	if mask_image == null or collision_bitmap == null or radius <= 0.0:
		return 0
	var center := to_local(world_center)
	var reveal_radius := radius + profile.surface_depth
	var min_x := maxi(0, floori(center.x - reveal_radius))
	var max_x := mini(mask_image.get_width() - 1, ceili(center.x + reveal_radius))
	var min_y := maxi(0, floori(center.y - reveal_radius))
	var max_y := mini(mask_image.get_height() - 1, ceili(center.y + reveal_radius))
	var radius_squared := radius * radius
	var reveal_squared := reveal_radius * reveal_radius
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var distance_squared := Vector2(x, y).distance_squared_to(center)
			if distance_squared <= radius_squared:
				mask_image.set_pixel(x, y, Color.TRANSPARENT)
				collision_bitmap.set_bit(x, y, false)
				fresh_cut_image.set_pixel(x, y, Color.TRANSPARENT)
			elif distance_squared <= reveal_squared and mask_image.get_pixel(x, y).a > 0.5:
				fresh_cut_image.set_pixel(x, y, Color.WHITE)
	var changed_rect := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
	_rebuild_display_image(changed_rect)
	var affected := _rebuild_chunks_in_rect(changed_rect)
	queue_redraw()
	terrain_carved.emit(world_center, radius, affected)
	return affected


func is_solid_at(world_position: Vector2) -> bool:
	if mask_image == null:
		return false
	var point := Vector2i(to_local(world_position).floor())
	if point.x < 0 or point.y < 0 or point.x >= mask_image.get_width() or point.y >= mask_image.get_height():
		return false
	return mask_image.get_pixelv(point).a > 0.5


func _rasterize_zone(zone: Node) -> void:
	if zone is CollisionPolygon2D:
		_rasterize_polygon(_global_polygon(zone as CollisionPolygon2D))
	elif zone is CollisionShape2D:
		_rasterize_shape(zone as CollisionShape2D)
	for child in zone.get_children():
		_rasterize_zone(child)


func _rasterize_ground_piece(piece: GroundPiece2DType) -> void:
	if piece.definition == null or not piece.validation_errors().is_empty():
		push_warning("Ground Piece ignorée car invalide : %s" % piece.get_path())
		return
	var mask: Image = piece.definition.mask_image()
	var color: Image = piece.definition.texture_image()
	if mask == null or color == null or mask.get_size() != color.get_size():
		return
	var source_size := Vector2(mask.get_size())
	var local_corners := [
		-piece.definition.pivot_px,
		Vector2(source_size.x, 0.0) - piece.definition.pivot_px,
		source_size - piece.definition.pivot_px,
		Vector2(0.0, source_size.y) - piece.definition.pivot_px,
	]
	var first := to_local(piece.to_global(local_corners[0]))
	var bounds := Rect2(first, Vector2.ZERO)
	for corner in local_corners:
		bounds = bounds.expand(to_local(piece.to_global(corner)))
	var target_rect := Rect2i(
		Vector2i(floori(bounds.position.x), floori(bounds.position.y)),
		Vector2i(ceili(bounds.size.x) + 1, ceili(bounds.size.y) + 1)
	).intersection(Rect2i(Vector2i.ZERO, profile.world_size))
	for target_y in range(target_rect.position.y, target_rect.end.y):
		for target_x in range(target_rect.position.x, target_rect.end.x):
			var terrain_point := Vector2(target_x + 0.5, target_y + 0.5)
			var piece_local := piece.to_local(to_global(terrain_point))
			var source_point := piece_local + piece.definition.pivot_px
			if piece.flip_h:
				source_point.x = source_size.x - source_point.x
			var source_pixel := Vector2i(floori(source_point.x), floori(source_point.y))
			if (
				source_pixel.x < 0 or source_pixel.y < 0
				or source_pixel.x >= mask.get_width() or source_pixel.y >= mask.get_height()
			):
				continue
			if mask.get_pixelv(source_pixel).a <= piece.definition.alpha_threshold:
				continue
			mask_image.set_pixel(target_x, target_y, Color.WHITE)
			var source_color := color.get_pixelv(source_pixel)
			var previous := authored_color_image.get_pixel(target_x, target_y)
			authored_color_image.set_pixel(target_x, target_y, previous.blend(source_color))


func _global_polygon(source: CollisionPolygon2D) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in source.polygon:
		result.append(to_local(source.to_global(point)))
	return result


func _rasterize_shape(source: CollisionShape2D) -> void:
	if source.shape is RectangleShape2D:
		var half_size := (source.shape as RectangleShape2D).size * 0.5
		var polygon := PackedVector2Array([
			to_local(source.to_global(Vector2(-half_size.x, -half_size.y))),
			to_local(source.to_global(Vector2(half_size.x, -half_size.y))),
			to_local(source.to_global(Vector2(half_size.x, half_size.y))),
			to_local(source.to_global(Vector2(-half_size.x, half_size.y))),
		])
		_rasterize_polygon(polygon)
	elif source.shape is CircleShape2D:
		var scale_factor := maxf(absf(source.global_scale.x), absf(source.global_scale.y))
		var radius := (source.shape as CircleShape2D).radius * scale_factor
		_fill_circle(to_local(source.global_position), radius)


func _rasterize_polygon(polygon: PackedVector2Array) -> void:
	if polygon.size() < 3:
		return
	var bounds := Rect2(polygon[0], Vector2.ZERO)
	for point in polygon:
		bounds = bounds.expand(point)
	var min_x := maxi(0, floori(bounds.position.x))
	var max_x := mini(profile.world_size.x - 1, ceili(bounds.end.x))
	var min_y := maxi(0, floori(bounds.position.y))
	var max_y := mini(profile.world_size.y - 1, ceili(bounds.end.y))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), polygon):
				mask_image.set_pixel(x, y, Color.WHITE)


func _fill_circle(center: Vector2, radius: float) -> void:
	var min_x := maxi(0, floori(center.x - radius))
	var max_x := mini(profile.world_size.x - 1, ceili(center.x + radius))
	var min_y := maxi(0, floori(center.y - radius))
	var max_y := mini(profile.world_size.y - 1, ceili(center.y + radius))
	var radius_squared := radius * radius
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if Vector2(x, y).distance_squared_to(center) <= radius_squared:
				mask_image.set_pixel(x, y, Color.WHITE)


func _rebuild_display_image(region := Rect2i()) -> void:
	var full_rebuild := display_image == null
	if full_rebuild:
		display_image = Image.create(profile.world_size.x, profile.world_size.y, false, Image.FORMAT_RGBA8)
		display_image.fill(Color.TRANSPARENT)
		region = mask_image.get_used_rect()
	elif region.size == Vector2i.ZERO:
		region = Rect2i(Vector2i.ZERO, profile.world_size)
	region = region.intersection(Rect2i(Vector2i.ZERO, profile.world_size))
	for y in range(region.position.y, region.end.y):
		for x in range(region.position.x, region.end.x):
			if mask_image.get_pixel(x, y).a <= 0.5:
				display_image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var depth_ratio := float(y) / float(profile.world_size.y)
			var authored_color := (
				authored_color_image.get_pixel(x, y)
				if authored_color_image != null else Color.TRANSPARENT
			)
			var material := (
				authored_color
				if authored_color.a > 0.0 else _terrain_sample(x, y, depth_ratio)
			)
			var distance_to_air := _distance_to_air_above(x, y, profile.surface_depth)
			if distance_to_air > 0:
				var is_fresh := fresh_cut_image.get_pixel(x, y).a > 0.5
				var surface: Image = (_texture_images.get(&"fresh_surface") if is_fresh else _texture_images.get(&"intact_surface")) as Image
				if surface != null:
					var sample_y := floori(float(distance_to_air - 1) / float(profile.surface_depth) * surface.get_height())
					var surface_color := _sample_repeated(surface, x, sample_y)
					material = material.lerp(Color(surface_color, 1.0), surface_color.a)
				else:
					material = profile.fresh_cut_color if is_fresh else profile.edge_color
			elif _near_air(x, y):
				material = profile.fresh_cut_color if fresh_cut_image.get_pixel(x, y).a > 0.5 else profile.edge_color
			display_image.set_pixel(x, y, material)
	if display_texture == null:
		display_texture = ImageTexture.create_from_image(display_image)
	else:
		display_texture.update(display_image)


func _terrain_sample(x: int, y: int, depth_ratio: float) -> Color:
	var image: Image
	var fallback := profile.main_color
	if depth_ratio < 0.68:
		image = _texture_images.get(&"shallow")
		fallback = profile.shallow_color
	elif depth_ratio > 0.86:
		image = _texture_images.get(&"deep")
		fallback = profile.deep_color
	else:
		image = _texture_images.get(&"main")
	if image is Image:
		return _sample_repeated(image, x, y)
	return fallback


func _near_air(x: int, y: int) -> bool:
	var edge := profile.edge_thickness
	return (
		x - edge < 0 or x + edge >= profile.world_size.x
		or y - edge < 0 or y + edge >= profile.world_size.y
		or mask_image.get_pixel(maxi(0, x - edge), y).a <= 0.5
		or mask_image.get_pixel(mini(profile.world_size.x - 1, x + edge), y).a <= 0.5
		or mask_image.get_pixel(x, maxi(0, y - edge)).a <= 0.5
		or mask_image.get_pixel(x, mini(profile.world_size.y - 1, y + edge)).a <= 0.5
	)


func _distance_to_air_above(x: int, y: int, maximum: int) -> int:
	for distance in range(1, maximum + 1):
		var probe_y := y - distance
		if probe_y < 0 or mask_image.get_pixel(x, probe_y).a <= 0.5:
			return distance
	return 0


func _cache_texture_images() -> void:
	_texture_images.clear()
	_texture_images[&"shallow"] = _texture_image(profile.shallow_texture)
	_texture_images[&"main"] = _texture_image(profile.main_texture)
	_texture_images[&"deep"] = _texture_image(profile.deep_texture)
	_texture_images[&"intact_surface"] = _texture_image(profile.intact_surface_texture)
	_texture_images[&"fresh_surface"] = _texture_image(profile.fresh_cut_surface_texture)


func _texture_image(texture: Texture2D) -> Image:
	if texture == null:
		return null
	var image := texture.get_image()
	return image if image != null and not image.is_empty() else null


func _sample_repeated(image: Image, x: int, y: int) -> Color:
	return image.get_pixel(posmod(x, image.get_width()), posmod(y, image.get_height()))


func _rebuild_all_chunks() -> void:
	for body in _chunk_bodies.values():
		if is_instance_valid(body):
			body.queue_free()
	_chunk_bodies.clear()
	var columns := ceili(float(profile.world_size.x) / profile.chunk_size)
	var rows := ceili(float(profile.world_size.y) / profile.chunk_size)
	for chunk_y in rows:
		for chunk_x in columns:
			_rebuild_chunk(Vector2i(chunk_x, chunk_y))


func _rebuild_chunks_in_rect(pixel_rect: Rect2i) -> int:
	var first := Vector2i(pixel_rect.position.x / profile.chunk_size, pixel_rect.position.y / profile.chunk_size)
	var last_pixel := pixel_rect.end - Vector2i.ONE
	var last := Vector2i(last_pixel.x / profile.chunk_size, last_pixel.y / profile.chunk_size)
	var count := 0
	for chunk_y in range(first.y, last.y + 1):
		for chunk_x in range(first.x, last.x + 1):
			_rebuild_chunk(Vector2i(chunk_x, chunk_y))
			count += 1
	return count


func _rebuild_chunk(coordinates: Vector2i) -> void:
	if _chunk_bodies.has(coordinates):
		var previous := _chunk_bodies[coordinates] as StaticBody2D
		if is_instance_valid(previous):
			remove_child(previous)
			previous.queue_free()
		_chunk_bodies.erase(coordinates)
	var origin := coordinates * profile.chunk_size
	var size := Vector2i(
		mini(profile.chunk_size, profile.world_size.x - origin.x),
		mini(profile.chunk_size, profile.world_size.y - origin.y)
	)
	if size.x <= 0 or size.y <= 0:
		return
	var polygons := collision_bitmap.opaque_to_polygons(Rect2i(origin, size), profile.collision_simplification)
	if polygons.is_empty():
		return
	var body := StaticBody2D.new()
	body.name = "Chunk_%02d_%02d" % [coordinates.x, coordinates.y]
	body.position = Vector2(origin)
	body.collision_layer = collision_layer
	body.collision_mask = collision_mask
	body.set_meta(&"chunk_coordinates", coordinates)
	add_child(body, false, Node.INTERNAL_MODE_BACK if Engine.is_editor_hint() else Node.INTERNAL_MODE_DISABLED)
	for polygon in polygons:
		if _polygon_area(polygon) < profile.minimum_polygon_area:
			continue
		var collision := CollisionPolygon2D.new()
		collision.polygon = polygon
		body.add_child(collision)
	_chunk_bodies[coordinates] = body


func _polygon_area(polygon: PackedVector2Array) -> float:
	var area := 0.0
	for index in polygon.size():
		var next := (index + 1) % polygon.size()
		area += polygon[index].x * polygon[next].y - polygon[next].x * polygon[index].y
	return absf(area) * 0.5


func _draw() -> void:
	if display_texture != null:
		draw_texture(display_texture, Vector2.ZERO, Color(1, 1, 1, 0.55 if debug_transparency else 1.0))
	if show_chunk_grid and profile != null:
		for x in range(0, profile.world_size.x + 1, profile.chunk_size):
			draw_line(Vector2(x, 0), Vector2(x, profile.world_size.y), Color(0.2, 0.85, 1.0, 0.4), 1.0)
		for y in range(0, profile.world_size.y + 1, profile.chunk_size):
			draw_line(Vector2(0, y), Vector2(profile.world_size.x, y), Color(0.2, 0.85, 1.0, 0.4), 1.0)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if profile == null or not profile.is_valid():
		warnings.append("Assigner un DestructibleTerrainProfile valide.")
	if authored_zones_root() == null and ground_pieces_root() == null:
		warnings.append("Aucune branche auteur DestructibleZones ou GroundPieces n'est disponible.")
	return warnings
