extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var plugin_path := "res://addons/mission_authoring/plugin.cfg"
	var plugin_script_path := "res://addons/mission_authoring/mission_authoring_plugin.gd"
	_check(FileAccess.file_exists(plugin_path), "Le plugin Mission Authoring doit exposer un plugin.cfg.")
	_check(FileAccess.file_exists(plugin_script_path), "Le plugin Mission Authoring doit fournir son script.")
	var enabled_plugins: PackedStringArray = ProjectSettings.get_setting("editor_plugins/enabled", PackedStringArray())
	_check(enabled_plugins.has(plugin_path), "Le plugin Mission Authoring doit être activé dans project.godot.")

	var plugin_source := FileAccess.get_file_as_string(plugin_script_path)
	_check(plugin_source.contains("MissionMapCatalog"), "Le dock doit lire MissionMapCatalog, pas coder les missions en dur.")
	_check(plugin_source.contains("open_scene_from_path"), "Le dock doit pouvoir ouvrir la scène maîtresse sélectionnée.")
	_check(plugin_source.contains("edit_resource"), "Le dock doit pouvoir ouvrir la MissionMapDefinition sélectionnée.")
	_check(plugin_source.contains("play_custom_scene"), "Le dock doit pouvoir lancer la scène de playtest sélectionnée.")

	var catalog := load("res://maps/definitions/mission_map_catalog.tres") as MissionMapCatalog
	_check(catalog != null and catalog.validation_errors().is_empty(), "Le catalogue de missions doit rester valide.")
	if catalog != null:
		for definition in catalog.maps:
			_check(definition != null and definition.is_valid(), "Chaque MissionMapDefinition doit être valide.")
			if definition == null:
				continue
			_check(definition.has_playtest_scene(), "%s doit déclarer une scène de playtest." % definition.map_id)
			_check(ResourceLoader.exists(definition.scene_path), "%s doit pointer vers une scène maîtresse existante." % definition.map_id)
			_check(ResourceLoader.exists(definition.playtest_scene_path), "%s doit pointer vers une scène de playtest existante." % definition.map_id)

	var toxic_playtest := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	_check(toxic_playtest != null and toxic_playtest.can_instantiate(), "L'écran de test Côte toxique doit rester instanciable.")
	var toxic_screen := toxic_playtest.instantiate() as PrototypeMissionScreen if toxic_playtest != null else null
	_check(toxic_screen != null, "Le playtest Côte toxique doit produire un PrototypeMissionScreen.")
	if toxic_screen != null:
		var host := toxic_screen.get_node_or_null("MissionViewportContainer/MissionViewport/MapHost") as MissionMapHost2D
		_check(host != null and host.definition != null and host.definition.map_id == &"toxic_coast", "Le playtest par défaut doit charger Côte toxique.")
		toxic_screen.free()

	var mission_2_playtest := load("res://screens/prototype/mission_2_playtest_screen.tscn") as PackedScene
	_check(mission_2_playtest != null and mission_2_playtest.can_instantiate(), "L'écran de test Mission 2 doit rester instanciable.")
	var mission_2_screen := mission_2_playtest.instantiate() as PrototypeMissionScreen if mission_2_playtest != null else null
	_check(mission_2_screen != null, "Le playtest Mission 2 doit produire un PrototypeMissionScreen.")
	if mission_2_screen != null:
		_check(mission_2_screen.mission_definition_override != null and mission_2_screen.mission_definition_override.map_id == &"mission_2_abyssal", "Le playtest Mission 2 doit surcharger la MissionMapDefinition.")
		mission_2_screen.free()

	if _failures.is_empty():
		print("MISSION_AUTHORING_TOOLS_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MISSION_AUTHORING_TOOLS_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
