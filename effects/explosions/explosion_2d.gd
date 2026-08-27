@tool
class_name Explosion2D
extends Node2D

signal detonated(origin: Vector2, data: ExplosionData)
signal terrain_carved(terrain: DestructibleTerrain2D, affected_chunks: int)
signal damage_requested(target: Node2D, damage: float, impulse: Vector2)
signal finished

@export_category("Definition")
## Resource autoritaire regroupant rayons, dégâts, timing et palette de cette explosion.
@export var data: ExplosionData:
	set(value):
		data = value
		_refresh_from_data()
## Déclenche l'AnimationPlayer dès l'apparition ; désactiver pour une explosion commandée plus tard.
@export var detonate_on_ready := false

@export_category("Terrain Authority")
## Optionnel. Sans cible explicite, tous les terrains du groupe natif sont interrogés.
@export_node_path("DestructibleTerrain2D") var terrain_path: NodePath

@export_category("Editor Preview")
## Dessine dans l'éditeur les rayons terrain et dégâts sans affecter le runtime.
@export var show_editor_radii := true:
	set(value):
		show_editor_radii = value
		queue_redraw()
## Déclenche depuis l'Inspector un impact de prévisualisation sur le terrain ciblé.
@export_tool_button("Prévisualiser l'impact terrain") var preview_button := editor_preview_impact

@onready var damage_area: Area2D = %DamageArea
@onready var damage_shape: CollisionShape2D = %DamageShape
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _impact_applied := false


func _ready() -> void:
	_refresh_from_data()
	if detonate_on_ready and not Engine.is_editor_hint():
		detonate()


func _draw() -> void:
	if not Engine.is_editor_hint() or not show_editor_radii or data == null:
		return
	draw_circle(Vector2.ZERO, data.damage_radius, Color(data.fire_color, 0.08))
	draw_arc(Vector2.ZERO, data.damage_radius, 0.0, TAU, 48, Color(data.fire_color, 0.75), 2.0)
	draw_arc(Vector2.ZERO, data.terrain_radius, 0.0, TAU, 48, Color("b5d61f"), 3.0)


func detonate() -> void:
	if data == null or not data.is_valid() or _impact_applied:
		return
	_refresh_from_data()
	animation_player.speed_scale = 0.42 / data.duration
	animation_player.play(&"detonate")
	detonated.emit(global_position, data)


func apply_impact_now() -> void:
	if data == null or not data.is_valid() or _impact_applied:
		return
	_impact_applied = true
	_apply_terrain_impact()
	_request_damage()


func editor_preview_impact() -> void:
	apply_impact_now()


func _animation_impact() -> void:
	apply_impact_now()


func _animation_finished() -> void:
	finished.emit()
	if not Engine.is_editor_hint():
		queue_free()


func _apply_terrain_impact() -> void:
	if not data.affects_destructible_terrain:
		return
	for terrain in _terrain_targets():
		var affected := terrain.carve_circle(global_position, data.terrain_radius)
		if affected > 0:
			terrain_carved.emit(terrain, affected)


func _terrain_targets() -> Array[DestructibleTerrain2D]:
	var targets: Array[DestructibleTerrain2D] = []
	if not terrain_path.is_empty():
		var explicit := get_node_or_null(terrain_path) as DestructibleTerrain2D
		if explicit != null:
			targets.append(explicit)
		return targets
	if not is_inside_tree():
		return targets
	for candidate in get_tree().get_nodes_in_group(&"destructible_terrains"):
		if candidate is DestructibleTerrain2D:
			targets.append(candidate)
	return targets


func _request_damage() -> void:
	if damage_area == null:
		return
	var emitted: Dictionary = {}
	var candidates: Array[Node2D] = []
	for body in damage_area.get_overlapping_bodies():
		if body is Node2D:
			candidates.append(body)
	for area in damage_area.get_overlapping_areas():
		if area is Node2D:
			candidates.append(area)
	for target in candidates:
		if emitted.has(target.get_instance_id()):
			continue
		emitted[target.get_instance_id()] = true
		var direction := global_position.direction_to(target.global_position)
		damage_requested.emit(target, data.damage, direction * data.impulse)


func _refresh_from_data() -> void:
	queue_redraw()
	if not is_node_ready() or data == null:
		return
	var circle := damage_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = data.damage_radius
	%Flash.modulate = Color(data.flash_color, 1.0)
	%Fireball.modulate = Color(data.fire_color, 1.0)
	%Smoke.modulate = Color(data.smoke_color, 1.0)
