@tool
class_name GroundModule2D
extends Node2D

@export_category("Definition")
## Panneau de matières partagé. Il ne possède jamais la forme du module.
@export var style: PermanentGroundStyle:
	set(value):
		style = value
		_sync_from_authority()
		update_configuration_warnings()

@export_category("Authored Geometry")
## Autorité unique du volume visuel et physique, dans le repère local du module.
@export var outline := PackedVector2Array():
	set(value):
		outline = value
		_sync_from_authority()
		update_configuration_warnings()
## Ligne supérieure recevant la bande de surface. Elle reste purement visuelle.
@export var surface_path := PackedVector2Array():
	set(value):
		surface_path = value
		_sync_from_authority()
		update_configuration_warnings()

@export_category("Physics")
## Couche physique occupée par ce sol ; le joueur et les projectiles doivent la rechercher dans leur masque.
@export_flags_2d_physics var collision_layer := 1:
	set(value):
		collision_layer = value
		_sync_from_authority()
## Couches que le StaticBody2D interroge ; généralement zéro car un sol passif ne détecte rien.
@export_flags_2d_physics var collision_mask := 0:
	set(value):
		collision_mask = value
		_sync_from_authority()


func _ready() -> void:
	_sync_from_authority()


func fill_polygon() -> Polygon2D:
	return get_node_or_null("Fill") as Polygon2D


func surface_line() -> Line2D:
	return get_node_or_null("Surface") as Line2D


func physics_body() -> StaticBody2D:
	return get_node_or_null("Body") as StaticBody2D


func collision_polygon() -> CollisionPolygon2D:
	return get_node_or_null("Body/Collision") as CollisionPolygon2D


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if style == null or not style.is_valid():
		errors.append("PermanentGroundStyle absente ou invalide.")
	if outline.size() < 3:
		errors.append("Outline doit contenir au moins trois points.")
	if surface_path.size() < 2:
		errors.append("Surface Path doit contenir au moins deux points.")
	if fill_polygon() == null:
		errors.append("Le Node Fill/Polygon2D est obligatoire.")
	if surface_line() == null:
		errors.append("Le Node Surface/Line2D est obligatoire.")
	if physics_body() == null or collision_polygon() == null:
		errors.append("Body/Collision est obligatoire.")
	return errors


func _sync_from_authority() -> void:
	var fill := fill_polygon()
	if fill != null:
		fill.polygon = outline
		fill.texture = style.fill_texture if style != null else null
		fill.color = style.fill_color if style != null else Color.WHITE
		fill.texture_offset = style.texture_offset if style != null else Vector2.ZERO
		fill.texture_scale = style.texture_scale if style != null else Vector2.ONE
		fill.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	var surface := surface_line()
	if surface != null:
		surface.points = surface_path
		surface.texture = style.surface_texture if style != null else null
		surface.default_color = style.surface_color if style != null else Color.WHITE
		surface.width = style.surface_width if style != null else 24.0
		surface.texture_mode = Line2D.LINE_TEXTURE_TILE
		surface.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	var body := physics_body()
	if body != null:
		body.collision_layer = collision_layer
		body.collision_mask = collision_mask
	var collision := collision_polygon()
	if collision != null:
		collision.polygon = outline


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
