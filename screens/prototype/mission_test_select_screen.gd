@tool
class_name MissionTestSelectScreen
extends Control

signal back_requested

## Catalogue autoritaire des missions proposées au joueur pour le test runtime.
@export var mission_catalog: MissionMapCatalog:
	set(value):
		mission_catalog = value
		_rebuild_when_ready()

## Écran canonique qui assemble player, HUD, spawners et map host pour jouer la mission choisie.
@export var mission_screen_scene: PackedScene:
	set(value):
		mission_screen_scene = value
		update_configuration_warnings()

var _active_mission_screen: Control


func _ready() -> void:
	%BackButton.pressed.connect(back_requested.emit)
	_rebuild_mission_buttons()
	_return_to_selector()


func open_mission(definition: MissionMapDefinition) -> void:
	if definition == null:
		_set_status("Mission absente.")
		return
	if mission_screen_scene == null or not mission_screen_scene.can_instantiate():
		_set_status("Scène de test absente.")
		return
	_clear_active_mission()
	var screen := mission_screen_scene.instantiate() as Control
	if screen == null:
		_set_status("La scène de test doit avoir un Control comme racine.")
		return
	screen.set("mission_definition_override", definition)
	if screen.has_signal(&"back_requested"):
		screen.connect(&"back_requested", _return_to_selector)
	%MissionLayer.add_child(screen)
	_active_mission_screen = screen
	%SelectorPanel.visible = false
	%MissionLayer.visible = true


func _return_to_selector() -> void:
	_clear_active_mission()
	%MissionLayer.visible = false
	%SelectorPanel.visible = true
	if not Engine.is_editor_hint():
		_focus_first_mission_button()


func _rebuild_when_ready() -> void:
	if is_inside_tree():
		_rebuild_mission_buttons()
	update_configuration_warnings()


func _rebuild_mission_buttons() -> void:
	for child in %MissionButtons.get_children():
		child.queue_free()
	if mission_catalog == null:
		_set_status("Assigner MissionMapCatalog.")
		return
	var definitions := mission_catalog.maps.duplicate()
	definitions.sort_custom(_sort_missions)
	var valid_count := 0
	for definition: MissionMapDefinition in definitions:
		if definition == null:
			continue
		var button := Button.new()
		button.text = "%02d  %s" % [definition.campaign_order, definition.display_name]
		button.tooltip_text = str(definition.map_id)
		button.custom_minimum_size = Vector2(360.0, 48.0)
		button.pressed.connect(open_mission.bind(definition))
		%MissionButtons.add_child(button)
		valid_count += 1
	_set_status("%d mission(s) testable(s) avec le player canonique." % valid_count)
	if not Engine.is_editor_hint():
		_focus_first_mission_button()


func _focus_first_mission_button() -> void:
	for child in %MissionButtons.get_children():
		var button := child as Button
		if button != null:
			button.grab_focus()
			return
	%BackButton.grab_focus()


func _sort_missions(a: MissionMapDefinition, b: MissionMapDefinition) -> bool:
	if a == null:
		return false
	if b == null:
		return true
	if a.campaign_order == b.campaign_order:
		return str(a.map_id) < str(b.map_id)
	return a.campaign_order < b.campaign_order


func _set_status(text: String) -> void:
	if is_inside_tree():
		%StatusLabel.text = text


func _clear_active_mission() -> void:
	if is_instance_valid(_active_mission_screen):
		%MissionLayer.remove_child(_active_mission_screen)
		_active_mission_screen.queue_free()
	_active_mission_screen = null
	for child in %MissionLayer.get_children():
		%MissionLayer.remove_child(child)
		child.queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if mission_catalog == null or not mission_catalog.validation_errors().is_empty():
		warnings.append("Assigner un MissionMapCatalog valide.")
	if mission_screen_scene == null or not mission_screen_scene.can_instantiate():
		warnings.append("Assigner la scène PrototypeMissionScreen canonique.")
	return warnings
