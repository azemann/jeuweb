@tool
extends EditorPlugin

const CATALOG_PATH := "res://maps/definitions/mission_map_catalog.tres"

var _dock: VBoxContainer
var _mission_picker: OptionButton
var _status: Label
var _summary: RichTextLabel
var _open_definition_button: Button
var _open_scene_button: Button
var _playtest_button: Button
var _definitions: Array[MissionMapDefinition] = []


func _enter_tree() -> void:
	_build_dock()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock)
	_refresh()


func _exit_tree() -> void:
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()


func _build_dock() -> void:
	_dock = VBoxContainer.new()
	_dock.name = "Missions"
	_dock.tooltip_text = "Ouvre les définitions, scènes maîtresses et scènes de playtest depuis le catalogue de missions."

	var title := Label.new()
	title.text = "Missions"
	title.tooltip_text = "Catalogue auteur : %s" % CATALOG_PATH
	_dock.add_child(title)

	_mission_picker = OptionButton.new()
	_mission_picker.tooltip_text = "Mission issue de MissionMapCatalog. La Resource reste l'autorité de l'identité et du chemin de test."
	_mission_picker.item_selected.connect(_on_selection_changed)
	_dock.add_child(_mission_picker)

	var actions := HBoxContainer.new()
	_dock.add_child(actions)
	_open_definition_button = _add_button(actions, "Définition", "Ouvre la MissionMapDefinition sélectionnée dans l'Inspecteur.", _open_definition)
	_open_scene_button = _add_button(actions, "Scène", "Ouvre la scène maîtresse autoritaire de la mission.", _open_master_scene)
	_playtest_button = _add_button(actions, "Tester", "Lance la scène de playtest déclarée par la MissionMapDefinition.", _playtest_mission)

	var refresh_button := _add_button(_dock, "Rafraîchir", "Recharge le catalogue après modification ou ajout de mission.", _refresh)
	refresh_button.size_flags_horizontal = Control.SIZE_FILL

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dock.add_child(_status)

	_summary = RichTextLabel.new()
	_summary.fit_content = true
	_summary.scroll_active = false
	_summary.bbcode_enabled = false
	_summary.tooltip_text = "Résumé des autorités : définition, scène maître, scène de test, dimensions et politique de destruction."
	_dock.add_child(_summary)


func _add_button(parent: Control, label: String, tooltip: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.tooltip_text = tooltip
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _refresh() -> void:
	_definitions.clear()
	_mission_picker.clear()
	var catalog := load(CATALOG_PATH) as MissionMapCatalog
	if catalog == null:
		_status.text = "Catalogue introuvable : %s" % CATALOG_PATH
		_update_buttons()
		return
	var errors := catalog.validation_errors()
	for definition in catalog.maps:
		if definition == null:
			continue
		_definitions.append(definition)
		var label := "%03d  %s" % [definition.campaign_order, definition.display_name]
		_mission_picker.add_item(label)
	if not errors.is_empty():
		_status.text = "Catalogue invalide : %s" % "; ".join(errors)
	elif _definitions.is_empty():
		_status.text = "Catalogue vide."
	else:
		_status.text = "%d mission(s) disponibles." % _definitions.size()
	if _mission_picker.item_count > 0:
		_mission_picker.select(0)
	_on_selection_changed(_mission_picker.selected)


func _selected_definition() -> MissionMapDefinition:
	var selected := _mission_picker.selected
	if selected < 0 or selected >= _definitions.size():
		return null
	return _definitions[selected]


func _on_selection_changed(_index: int) -> void:
	var definition := _selected_definition()
	if definition == null:
		_summary.text = "Aucune mission sélectionnée."
		_update_buttons()
		return
	var validation := "OK" if definition.is_valid() else "INVALIDE"
	var playtest := definition.playtest_scene_path if definition.has_playtest_scene() else "non assignée"
	_summary.text = (
		"ID : %s\nNom : %s\nContrat : %s\nScène maître : %s\nPlaytest : %s\nMonde : %s\nDestruction : %s"
		% [
			definition.map_id,
			definition.display_name,
			validation,
			definition.scene_path,
			playtest,
			definition.world_size,
			MissionMapDefinition.DestructionPolicy.keys()[definition.destruction_policy],
		]
	)
	_update_buttons()


func _update_buttons() -> void:
	var definition := _selected_definition()
	var has_definition := definition != null
	_open_definition_button.disabled = not has_definition
	_open_scene_button.disabled = not (has_definition and ResourceLoader.exists(definition.scene_path))
	_playtest_button.disabled = not (has_definition and definition.has_playtest_scene() and ResourceLoader.exists(definition.playtest_scene_path))


func _open_definition() -> void:
	var definition := _selected_definition()
	if definition == null:
		return
	get_editor_interface().edit_resource(definition)


func _open_master_scene() -> void:
	var definition := _selected_definition()
	if definition == null:
		return
	get_editor_interface().open_scene_from_path(definition.scene_path)


func _playtest_mission() -> void:
	var definition := _selected_definition()
	if definition == null or not definition.has_playtest_scene():
		return
	get_editor_interface().play_custom_scene(definition.playtest_scene_path)
