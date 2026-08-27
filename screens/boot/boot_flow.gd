class_name BootFlow
extends Control

signal completed

var _completed := false


func _ready() -> void:
	%AutoContinueTimer.timeout.connect(_complete)
	%AnimationPlayer.play(&"reveal")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
		_complete()
		get_viewport().set_input_as_handled()


func _complete() -> void:
	if _completed:
		return
	_completed = true
	completed.emit()

