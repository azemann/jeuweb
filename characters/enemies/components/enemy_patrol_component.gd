class_name EnemyPatrolComponent
extends Node

signal direction_changed(direction: float)

@export_category("Authority")
## Profil d'archétype contenant vitesse, accélération, gravité et amplitude.
@export var profile: EnemyArchetypeProfile
## CharacterBody2D dont ce composant possède la vélocité de patrouille.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")
## Sens initial de la première traversée de patrouille.
@export_enum("Left:-1", "Right:1") var initial_direction := -1

var origin_x := 0.0
var direction := -1.0
var movement_enabled := true
var _body: CharacterBody2D


func _ready() -> void:
	_body = get_node_or_null(body_path) as CharacterBody2D
	direction = -1.0 if initial_direction < 0 else 1.0
	if _body != null:
		origin_x = _body.global_position.x
	set_physics_process(not Engine.is_editor_hint() and _body != null and profile != null and profile.is_valid())


func _physics_process(delta: float) -> void:
	if movement_enabled:
		var requested_direction := direction
		if _body.is_on_wall() and not is_zero_approx(_body.get_wall_normal().x):
			requested_direction = signf(_body.get_wall_normal().x)
		elif direction > 0.0 and _body.global_position.x >= origin_x + profile.patrol_half_width:
			requested_direction = -1.0
		elif direction < 0.0 and _body.global_position.x <= origin_x - profile.patrol_half_width:
			requested_direction = 1.0
		if requested_direction != direction:
			direction = requested_direction
			direction_changed.emit(direction)
		var target_speed := direction * profile.movement_speed
		_body.velocity.x = move_toward(_body.velocity.x, target_speed, profile.acceleration * delta)
	else:
		_body.velocity.x = 0.0
	if not _body.is_on_floor():
		_body.velocity.y = minf(_body.velocity.y + profile.gravity * delta, profile.maximum_fall_speed)
	_body.move_and_slide()


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled and _body != null:
		_body.velocity.x = 0.0
