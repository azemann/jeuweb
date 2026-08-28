extends SceneTree

const DestructibleTerrainType = preload("res://terrain/destructible_terrain_2d.gd")
const DestructibleTerrainProfileType = preload("res://terrain/destructible_terrain_profile.gd")
const GroundPieceDefinitionType = preload("res://terrain/ground_pieces/ground_piece_definition.gd")
const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _piece_definition(piece_id: StringName, color: Color) -> Resource:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var definition := GroundPieceDefinitionType.new()
	definition.piece_id = piece_id
	definition.display_name = str(piece_id)
	definition.texture = ImageTexture.create_from_image(image)
	definition.pivot_px = Vector2(32, 32)
	definition.simplification = 0.0
	return definition


func _piece(packed: PackedScene, piece_id: StringName, color: Color, position: Vector2) -> Node2D:
	var result := packed.instantiate()
	result.name = str(piece_id)
	result.position = position
	result.definition = _piece_definition(piece_id, color)
	result.ground_mode = GroundPiece2DType.GroundMode.CARVABLE
	return result


func _run() -> void:
	var map_root := Node2D.new()
	map_root.name = "StampTestMap"
	var gameplay := Node2D.new()
	gameplay.name = "Gameplay"
	map_root.add_child(gameplay)
	var zones := Node2D.new()
	zones.name = "DestructibleZones"
	gameplay.add_child(zones)
	var pieces := Node2D.new()
	pieces.name = "GroundPieces"
	gameplay.add_child(pieces)

	var packed := load("res://terrain/ground_pieces/ground_piece_2d.tscn") as PackedScene
	var left := _piece(packed, &"left_stamp", Color("d45a31"), Vector2(608, 560))
	var right := _piece(packed, &"right_stamp", Color("91b82d"), Vector2(672, 560))
	var transformed := _piece(packed, &"transformed_stamp", Color("315bd4"), Vector2(900, 350))
	transformed.rotation = deg_to_rad(-35.0)
	transformed.scale = Vector2(-1.6, 0.55)
	pieces.add_child(left)
	pieces.add_child(right)
	pieces.add_child(transformed)

	var profile := DestructibleTerrainProfileType.new()
	profile.world_size = Vector2i(1280, 720)
	profile.chunk_size = 128
	profile.minimum_polygon_area = 1.0
	var terrain := DestructibleTerrainType.new()
	terrain.name = "DestructibleTerrain"
	terrain.profile = profile
	terrain.authored_zones_path = NodePath("../Gameplay/DestructibleZones")
	terrain.ground_pieces_path = NodePath("../Gameplay/GroundPieces")
	map_root.add_child(terrain)
	root.add_child(map_root)
	await process_frame

	_check(terrain.collect_carvable_pieces().size() == 3, "Trois stamps doivent être collectés.")
	_check(terrain.is_solid_at(Vector2(636, 560)), "Le stamp gauche doit être solide.")
	_check(terrain.is_solid_at(Vector2(644, 560)), "Le stamp droit doit être solide.")
	_check(
		terrain.authored_color_image.get_pixel(636, 560).r > terrain.authored_color_image.get_pixel(636, 560).g,
		"La couleur illustrée gauche doit être composée."
	)
	_check(
		terrain.authored_color_image.get_pixel(644, 560).g > terrain.authored_color_image.get_pixel(644, 560).r,
		"La couleur illustrée droite doit être composée."
	)
	_check(transformed.validation_errors().is_empty(), "Rotation, miroir et échelle non uniforme doivent être autorisés.")
	var transformed_inside := transformed.to_global(Vector2(18, 8))
	var transformed_outside := transformed.to_global(Vector2(42, 0))
	_check(terrain.is_solid_at(transformed_inside), "Le masque doit suivre la transformation Godot complète.")
	_check(not terrain.is_solid_at(transformed_outside), "Le masque transformé ne doit pas déborder de sa source.")
	var transformed_pixel := Vector2i(terrain.to_local(transformed_inside).floor())
	_check(
		terrain.authored_color_image.get_pixelv(transformed_pixel).b > terrain.authored_color_image.get_pixelv(transformed_pixel).r,
		"La couleur de la pièce doit suivre sa transformation."
	)
	await physics_frame
	var ray := PhysicsRayQueryParameters2D.create(
		transformed.to_global(Vector2(-50, 0)),
		transformed.to_global(Vector2(50, 0)),
		1
	)
	ray.collide_with_areas = false
	ray.collide_with_bodies = true
	_check(
		not terrain.get_world_2d().direct_space_state.intersect_ray(ray).is_empty(),
		"La collision générée doit suivre rotation, miroir et échelle non uniforme."
	)
	terrain.carve_circle(Vector2(640, 560), 12.0)
	_check(not terrain.is_solid_at(Vector2(636, 560)), "Le cratère doit traverser le stamp gauche.")
	_check(not terrain.is_solid_at(Vector2(644, 560)), "Le cratère doit traverser le stamp droit.")
	_check(terrain.has_pending_collision_rebuild(), "Toute future pièce Carvable doit utiliser la file physique commune du terrain.")
	await process_frame
	_check(terrain.collision_flush_count == 1, "Les stamps de Ground Pieces doivent être synchronisés par un unique flush différé.")
	_check(
		not left.is_permanent_collision_active() and not right.is_permanent_collision_active(),
		"Les stamps ne doivent pas conserver de collisions locales."
	)

	map_root.free()
	if _failures.is_empty():
		print("GROUND_PIECE_DESTRUCTIBLE_STAMP_TEST: PASS")
		quit(0)
	else:
		print("GROUND_PIECE_DESTRUCTIBLE_STAMP_TEST: FAIL (%d)" % _failures.size())
		quit(1)
