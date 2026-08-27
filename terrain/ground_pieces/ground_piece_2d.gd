@tool
class_name GroundPiece2D
extends Node2D

const GroundPieceDefinitionType = preload("res://terrain/ground_pieces/ground_piece_definition.gd")
const GroundBreakableComponentType = preload("res://terrain/ground_pieces/components/ground_breakable_component.gd")

signal piece_broken

enum GroundMode {
	PERMANENT,
	CARVABLE,
	BREAKABLE,
}

@export_category("Definition")
## Resource autoritaire qui associe identité, PNG, pivot, géométrie et profil de rupture.
@export var definition: GroundPieceDefinitionType:
	set(value):
		definition = value
		_sync_if_ready()
		update_configuration_warnings()

@export_category("Gameplay")
## Permanent garde une collision locale, Carvable rejoint le masque destructible
## façon Worms, Breakable utilise les PV du Breakable Profile.
@export var ground_mode: GroundMode = GroundMode.CARVABLE:
	set(value):
		ground_mode = value
		_sync_if_ready()
		update_configuration_warnings()

@export_category("Placement")
## Retourne horizontalement la présentation et la géométrie dérivée sans modifier le PNG source.
@export var flip_h := false:
	set(value):
		flip_h = value
		_sync_if_ready()
## Priorité réservée au classement des pièces par les futurs outils auteur ; n'altère pas encore le rendu.
@export var render_priority := 0
## Affiche dans l'éditeur le contour physique et sa portion marchable, jamais au runtime.
@export var show_walk_geometry_preview := true:
	set(value):
		show_walk_geometry_preview = value
		queue_redraw()

var _last_synced_mode := -1
var _editor_sync_retry_pending := false


func _ready() -> void:
	sync_from_authority()


func presentation_sprite() -> Sprite2D:
	return get_node_or_null("Presentation") as Sprite2D


func permanent_body() -> StaticBody2D:
	return get_node_or_null("PermanentBody") as StaticBody2D


func collision_polygon() -> CollisionPolygon2D:
	return get_node_or_null("PermanentBody/Collision") as CollisionPolygon2D


func destructible_stamp() -> Node2D:
	return get_node_or_null("DestructibleStamp") as Node2D


func breakable_component() -> GroundBreakableComponentType:
	return get_node_or_null("BreakableComponent") as GroundBreakableComponentType


func sync_from_authority() -> void:
	var sprite := presentation_sprite()
	var body := permanent_body()
	var collision := collision_polygon()
	var stamp := destructible_stamp()
	var breakable := breakable_component()
	if sprite == null or body == null or collision == null or stamp == null or breakable == null:
		return
	# Lors du premier scan de l'éditeur, le Node enfant peut exister une frame
	# avant que son script @tool ait exposé ses méthodes et propriétés.
	if (
		not breakable.has_method(&"configure")
		or not breakable.has_method(&"apply_damage")
		or not breakable.has_method(&"is_broken")
	):
		if Engine.is_editor_hint() and not _editor_sync_retry_pending and get_tree() != null:
			_editor_sync_retry_pending = true
			get_tree().process_frame.connect(_retry_editor_sync, CONNECT_ONE_SHOT)
		return
	_editor_sync_retry_pending = false
	var broken_callback := Callable(self, &"_on_breakable_piece_broken")
	if breakable.has_signal(&"piece_broken") and not breakable.is_connected(&"piece_broken", broken_callback):
		breakable.connect(&"piece_broken", broken_callback)
	var health_callback := Callable(self, &"_on_breakable_health_changed")
	if breakable.has_signal(&"health_changed") and not breakable.is_connected(&"health_changed", health_callback):
		breakable.connect(&"health_changed", health_callback)
	var has_definition := definition != null
	sprite.texture = definition.texture if has_definition else null
	sprite.position = -definition.pivot_px if has_definition else Vector2.ZERO
	sprite.centered = false
	sprite.flip_h = flip_h
	sprite.z_index = definition.default_z_index if has_definition else 0
	var polygons: Array[PackedVector2Array] = definition.geometry_polygons() if has_definition else []
	collision.polygon = _largest_polygon(polygons)
	var local_collision_active := ground_mode != GroundMode.CARVABLE and not breakable.is_broken()
	body.collision_layer = 1 if local_collision_active else 0
	body.collision_mask = 0
	collision.disabled = not local_collision_active
	stamp.visible = ground_mode == GroundMode.CARVABLE
	breakable.process_mode = (
		Node.PROCESS_MODE_INHERIT if ground_mode == GroundMode.BREAKABLE
		else Node.PROCESS_MODE_DISABLED
	)
	if ground_mode == GroundMode.BREAKABLE and has_definition:
		if _last_synced_mode != GroundMode.BREAKABLE or breakable.configured_profile() != definition.breakable_profile:
			breakable.configure(definition.breakable_profile)
	if ground_mode != GroundMode.BREAKABLE:
		breakable.reset_state()
	sprite.visible = has_definition and (ground_mode != GroundMode.CARVABLE or Engine.is_editor_hint())
	_last_synced_mode = ground_mode
	queue_redraw()


func _draw() -> void:
	if (
		not Engine.is_editor_hint()
		or not show_walk_geometry_preview
		or definition == null
		or ground_mode == GroundMode.CARVABLE
		or definition.collision_source != GroundPieceDefinitionType.CollisionSource.AUTHORED_OUTLINE
	):
		return
	var outline := definition.authored_outline.duplicate()
	if outline.size() >= 3:
		outline.append(outline[0])
		draw_polyline(outline, Color(0.94, 0.13, 0.55, 0.88), 2.0, true)
	var surface := definition.walk_surface()
	if surface.size() >= 2:
		draw_polyline(surface, Color(0.71, 0.84, 0.12, 1.0), 4.0, true)


func is_permanent_collision_active() -> bool:
	var body := permanent_body()
	var collision := collision_polygon()
	return body != null and collision != null and body.collision_layer != 0 and not collision.disabled


func is_carvable_stamp_active() -> bool:
	return definition != null and ground_mode == GroundMode.CARVABLE


func is_breakable_active() -> bool:
	var component := breakable_component()
	return (
		component != null
		and ground_mode == GroundMode.BREAKABLE
		and component.process_mode != Node.PROCESS_MODE_DISABLED
		and not component.is_broken()
	)


func apply_damage(amount: float) -> bool:
	var component := breakable_component()
	if component == null or ground_mode != GroundMode.BREAKABLE:
		return false
	return component.apply_damage(amount)


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if definition == null:
		errors.append("GroundPieceDefinition est obligatoire.")
		return errors
	for error in definition.validation_errors():
		errors.append(error)
	var polygons := definition.geometry_polygons()
	if polygons.size() > 1:
		errors.append("La géométrie produit plusieurs îlots ; consolider l'alpha ou utiliser Authored Outline.")
	if ground_mode == GroundMode.BREAKABLE:
		if definition.breakable_profile == null or not definition.breakable_profile.is_valid():
			errors.append("Breakable Profile est obligatoire en mode Breakable.")
		elif not definition.breakable_profile.remove_after_break and definition.destroyed_texture == null:
			errors.append("Breakable exige Remove After Break ou une Destroyed Texture.")
	if is_zero_approx(transform.determinant()):
		errors.append("La transformation doit rester inversible : aucune composante d'échelle ne peut être nulle.")
	return errors


func _on_breakable_piece_broken() -> void:
	var sprite := presentation_sprite()
	var body := permanent_body()
	var collision := collision_polygon()
	var component := breakable_component()
	if sprite != null and definition != null and definition.destroyed_texture != null:
		sprite.texture = definition.destroyed_texture
	var profile := component.configured_profile() if component != null else null
	if profile != null and profile.remove_collision_when_broken:
		if body != null:
			body.collision_layer = 0
		if collision != null:
			collision.disabled = true
	piece_broken.emit()
	if profile != null and profile.remove_after_break:
		queue_free()


func _on_breakable_health_changed(current: float, maximum: float) -> void:
	var sprite := presentation_sprite()
	var component := breakable_component()
	if sprite == null or definition == null or component == null or component.is_broken():
		return
	var profile := component.configured_profile()
	if definition.damaged_texture == null or profile == null or maximum <= 0.0:
		sprite.texture = definition.texture
		return
	var health_ratio := current / maximum
	if health_ratio <= profile.damaged_health_ratio:
		sprite.texture = definition.damaged_texture
	else:
		sprite.texture = definition.texture


func _largest_polygon(polygons: Array[PackedVector2Array]) -> PackedVector2Array:
	var largest := PackedVector2Array()
	var largest_area := 0.0
	for polygon in polygons:
		var area := _polygon_area(polygon)
		if area > largest_area:
			largest_area = area
			largest = polygon
	return largest


func _polygon_area(polygon: PackedVector2Array) -> float:
	var area := 0.0
	for index in polygon.size():
		var next := (index + 1) % polygon.size()
		area += polygon[index].x * polygon[next].y - polygon[next].x * polygon[index].y
	return absf(area) * 0.5


func _sync_if_ready() -> void:
	if is_inside_tree():
		sync_from_authority()


func _retry_editor_sync() -> void:
	_editor_sync_retry_pending = false
	if is_inside_tree():
		sync_from_authority()


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
