@tool
class_name ActorStateMachineComponent
extends Node

signal state_changed(previous: State, current: State)

enum State {
	IDLE,
	RUN,
	ATTACK,
	HURT,
	DEAD,
	RESPAWN,
}

@export_category("State")
@export var initial_state := State.IDLE

var current_state: State = State.IDLE


func _ready() -> void:
	current_state = initial_state


func transition(next_state: State) -> bool:
	if current_state == next_state:
		return false
	if current_state == State.DEAD and next_state != State.RESPAWN:
		return false
	var previous := current_state
	current_state = next_state
	state_changed.emit(previous, current_state)
	return true


func is_in(state: State) -> bool:
	return current_state == state


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray() if initial_state >= State.IDLE and initial_state <= State.RESPAWN else PackedStringArray(["Initial State est invalide."])
