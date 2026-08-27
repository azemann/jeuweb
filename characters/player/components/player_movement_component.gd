class_name PlayerMovementComponent
extends Node

signal horizontal_input_changed(value: float)
signal jumped
signal grounded_changed(is_grounded: bool)

@export_category("Authority")
## Profil partagé contenant toutes les valeurs de locomotion exprimées en unités gameplay.
@export var profile: PlayerMovementProfile
## CharacterBody2D déplacé par ce composant ; séparer ce chemin permet de réutiliser le comportement.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")

var _body: CharacterBody2D
var _coyote_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _last_horizontal_input := 0.0
var _was_grounded := false


func _ready() -> void:
	_body = get_node_or_null(body_path) as CharacterBody2D
	set_physics_process(not Engine.is_editor_hint() and _body != null and profile != null and profile.is_valid())


func _physics_process(delta: float) -> void:
	var grounded_before_move := _body.is_on_floor()
	if grounded_before_move:
		_coyote_remaining = profile.coyote_time
	else:
		_coyote_remaining = maxf(0.0, _coyote_remaining - delta)

	if Input.is_action_just_pressed(&"player_jump"):
		_jump_buffer_remaining = profile.jump_buffer_time
	else:
		_jump_buffer_remaining = maxf(0.0, _jump_buffer_remaining - delta)

	var horizontal := Input.get_axis(&"player_move_left", &"player_move_right")
	if not is_equal_approx(horizontal, _last_horizontal_input):
		_last_horizontal_input = horizontal
		horizontal_input_changed.emit(horizontal)
	var acceleration := profile.ground_acceleration
	if not grounded_before_move:
		acceleration *= profile.air_control
	var target_speed := horizontal * profile.maximum_speed
	var rate := acceleration if not is_zero_approx(horizontal) else profile.ground_deceleration
	_body.velocity.x = move_toward(_body.velocity.x, target_speed, rate * delta)

	if _jump_buffer_remaining > 0.0 and _coyote_remaining > 0.0:
		_body.velocity.y = -profile.jump_speed
		_jump_buffer_remaining = 0.0
		_coyote_remaining = 0.0
		jumped.emit()
	elif not grounded_before_move:
		_body.velocity.y = minf(_body.velocity.y + profile.gravity * delta, profile.maximum_fall_speed)

	_body.move_and_slide()
	var grounded_after_move := _body.is_on_floor()
	_update_state(grounded_after_move)
	if grounded_after_move != _was_grounded:
		_was_grounded = grounded_after_move
		grounded_changed.emit(grounded_after_move)


func _update_state(grounded: bool) -> void:
	var player := get_parent().get_parent() as PlayerCharacter2D
	var state := player.state_machine() if player != null else null
	if state == null or state.is_in(ActorStateMachineComponent.State.HURT) or state.is_in(ActorStateMachineComponent.State.DEAD):
		return
	if not grounded:
		state.transition(ActorStateMachineComponent.State.JUMP if _body.velocity.y < 0.0 else ActorStateMachineComponent.State.FALL)
	elif absf(_body.velocity.x) > 1.0:
		state.transition(ActorStateMachineComponent.State.RUN)
	else:
		state.transition(ActorStateMachineComponent.State.IDLE)
