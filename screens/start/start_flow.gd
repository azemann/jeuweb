@tool
class_name StartFlow
extends Control

signal open_gallery_requested
signal open_mission_requested
signal quit_requested

@export_category("Presentation")
## Resource autoritaire des illustrations, cadres et ornements du menu principal.
@export var presentation: BootStartFlowTheme:
	set(value):
		presentation = value
		_queue_apply_presentation()


func _ready() -> void:
	_apply_presentation()
	if Engine.is_editor_hint():
		return
	%MissionButton.pressed.connect(open_mission_requested.emit)
	%GalleryButton.pressed.connect(open_gallery_requested.emit)
	%QuitButton.pressed.connect(quit_requested.emit)
	%MissionButton.focus_entered.connect(_show_focus_indicator.bind(%MissionIndicator))
	%GalleryButton.focus_entered.connect(_show_focus_indicator.bind(%GalleryIndicator))
	%QuitButton.focus_entered.connect(_show_focus_indicator.bind(%QuitIndicator))
	%MissionButton.grab_focus()
	%AnimationPlayer.play(&"reveal")


func _show_focus_indicator(active_indicator: TextureRect) -> void:
	for indicator in [%MissionIndicator, %GalleryIndicator, %QuitIndicator]:
		indicator.modulate.a = 1.0 if indicator == active_indicator else 0.0


func _queue_apply_presentation() -> void:
	if is_inside_tree():
		call_deferred(&"_apply_presentation")


func _apply_presentation() -> void:
	if not is_node_ready() or presentation == null:
		return
	%Backdrop.texture = presentation.start_background
	%TitlePlateTexture.texture = presentation.title_plaque
	%MenuFrame.texture = presentation.main_menu_frame
	for indicator in [%MissionIndicator, %GalleryIndicator, %QuitIndicator]:
		indicator.texture = presentation.previous_active


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray(["Assigner un BootStartFlowTheme valide."]) if presentation == null or not presentation.is_valid() else PackedStringArray()
