@tool
class_name AppFlow
extends Control

## Panneau autoritaire qui associe chaque étape du flux à sa scène et règle les fondus.
@export var config: AppFlowConfig:
	set(value):
		config = value
		update_configuration_warnings()

@onready var screen_host: Control = %ScreenHost
@onready var fade: ColorRect = %Fade
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _current_screen: Control
var _transitioning := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if config == null or config.boot_screen == null:
		push_error("Main exige une AppFlowConfig et une scène Boot.")
		return
	fade.color = config.fade_color
	_clear_screen_host()
	_show_screen_immediately(config.boot_screen)
	animation_player.speed_scale = 0.20 / maxf(config.fade_duration, 0.05)
	animation_player.play(&"fade_in")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if config == null:
		warnings.append("Assigner AppFlowConfig.")
		return warnings
	if config.boot_screen == null or config.start_screen == null or config.gallery_screen == null or config.prototype_mission_screen == null:
		warnings.append("Les quatre écrans doivent être assignés dans AppFlowConfig.")
	return warnings


func _show_screen_immediately(scene: PackedScene) -> void:
	if scene == null:
		push_error("Impossible d'ouvrir un écran non assigné.")
		return
	if is_instance_valid(_current_screen):
		screen_host.remove_child(_current_screen)
		_current_screen.queue_free()
	_current_screen = scene.instantiate() as Control
	if _current_screen == null:
		push_error("La scène d'écran doit avoir un Control comme racine.")
		return
	screen_host.add_child(_current_screen)
	_connect_screen_intentions(_current_screen)


func _clear_screen_host() -> void:
	for child in screen_host.get_children():
		screen_host.remove_child(child)
		child.queue_free()


func _connect_screen_intentions(screen: Control) -> void:
	if screen.has_signal(&"completed"):
		screen.connect(&"completed", _on_boot_completed)
	if screen.has_signal(&"open_gallery_requested"):
		screen.connect(&"open_gallery_requested", _on_open_gallery_requested)
	if screen.has_signal(&"open_mission_requested"):
		screen.connect(&"open_mission_requested", _on_open_mission_requested)
	if screen.has_signal(&"back_requested"):
		screen.connect(&"back_requested", _on_back_requested)
	if screen.has_signal(&"quit_requested"):
		screen.connect(&"quit_requested", _on_quit_requested)


func _change_screen(scene: PackedScene) -> void:
	if _transitioning or scene == null:
		return
	_transitioning = true
	animation_player.play(&"fade_out")
	await animation_player.animation_finished
	_show_screen_immediately(scene)
	animation_player.play(&"fade_in")
	await animation_player.animation_finished
	_transitioning = false


func _on_boot_completed() -> void:
	_change_screen(config.start_screen)


func _on_open_gallery_requested() -> void:
	_change_screen(config.gallery_screen)


func _on_open_mission_requested() -> void:
	_change_screen(config.prototype_mission_screen)


func _on_back_requested() -> void:
	_change_screen(config.start_screen)


func _on_quit_requested() -> void:
	get_tree().quit()
