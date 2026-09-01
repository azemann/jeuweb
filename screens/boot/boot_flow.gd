@tool
class_name BootFlow
extends Control

signal completed

@export_category("Presentation")
## Resource autoritaire des illustrations et cadres du Boot Flow.
@export var presentation: BootStartFlowTheme:
	set(value):
		presentation = value
		_queue_apply_presentation()

var _completed := false


func _ready() -> void:
	_apply_presentation()
	if Engine.is_editor_hint():
		return
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


func _queue_apply_presentation() -> void:
	if is_inside_tree():
		call_deferred(&"_apply_presentation")


func _apply_presentation() -> void:
	if not is_node_ready() or presentation == null:
		return
	%Backdrop.texture = presentation.boot_background
	%Emblem.texture = presentation.faction_emblem
	%PlateTexture.texture = presentation.title_plaque


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray(["Assigner un BootStartFlowTheme valide."]) if presentation == null or not presentation.is_valid() else PackedStringArray()
