extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var selector_scene := load("res://screens/prototype/mission_test_select_screen.tscn") as PackedScene
	_check(selector_scene != null and selector_scene.can_instantiate(), "Le sélecteur de test missions doit être instanciable.")
	var selector := selector_scene.instantiate() as Control if selector_scene != null else null
	_check(selector != null and selector.has_method(&"open_mission"), "Le sélecteur de test missions doit exposer open_mission.")
	if selector != null:
		root.add_child(selector)
		await process_frame
		var catalog := load("res://maps/definitions/mission_map_catalog.tres") as MissionMapCatalog
		_check(selector.get("mission_catalog") == catalog, "Le sélecteur doit lire le catalogue canonique.")
		var mission_buttons: Node = selector.get_node_or_null("%MissionButtons")
		_check(mission_buttons != null, "Le sélecteur doit exposer la liste de boutons.")
		if mission_buttons != null and catalog != null:
			_check(mission_buttons.get_child_count() == catalog.maps.size(), "Le sélecteur doit créer un bouton par mission du catalogue.")
		var mission_2 := catalog.find_map(&"mission_2_abyssal") if catalog != null else null
		selector.open_mission(mission_2)
		var layer: Node = selector.get_node_or_null("%MissionLayer")
		_check(layer != null and layer.get_child_count() == 1, "Ouvrir Mission 2 doit instancier un écran de mission.")
		var mission_screen := layer.get_child(0) as PrototypeMissionScreen if layer != null and layer.get_child_count() > 0 else null
		_check(mission_screen != null, "Le test lancé doit rester le PrototypeMissionScreen canonique.")
		_check(mission_screen != null and mission_screen.mission_definition_override == mission_2, "Mission 2 doit être transmise comme override au runtime canonique.")
		selector.queue_free()

	var flow_config := load("res://app/app_flow_config.tres") as AppFlowConfig
	_check(flow_config != null and flow_config.prototype_mission_screen == selector_scene, "Le bouton Mission doit ouvrir le sélecteur de test missions.")

	if _failures.is_empty():
		print("MISSION_PLAYTEST_SELECTOR_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MISSION_PLAYTEST_SELECTOR_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
