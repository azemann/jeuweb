extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var scene_paths := [
		"res://app/main.tscn",
		"res://screens/boot/boot_flow.tscn",
		"res://screens/start/start_flow.tscn",
		"res://screens/gallery/art_direction_gallery.tscn",
		"res://screens/prototype/prototype_mission_screen.tscn",
		"res://maps/missions/toxic_coast/toxic_coast.tscn",
	]
	for path in scene_paths:
		_check(load(path) is PackedScene, "Scène illisible : %s" % path)

	var flow_config := load("res://app/app_flow_config.tres") as AppFlowConfig
	_check(flow_config != null, "AppFlowConfig illisible.")
	if flow_config != null:
		_check(flow_config.boot_screen != null, "Boot absent de AppFlowConfig.")
		_check(flow_config.start_screen != null, "Start absent de AppFlowConfig.")
		_check(flow_config.gallery_screen != null, "Galerie absente de AppFlowConfig.")
		_check(flow_config.prototype_mission_screen != null, "Mission absente de AppFlowConfig.")

	var catalog := load("res://screens/gallery/gallery_catalog.tres") as GalleryCatalog
	_check(catalog != null, "GalleryCatalog illisible.")
	if catalog != null:
		_check(catalog.entries.size() == 7, "Le catalogue doit contenir sept planches.")
		for entry in catalog.entries:
			_check(entry != null and entry.board_texture != null, "Une planche du catalogue n'a pas de texture.")

	_check(_scene_has_signal("res://screens/boot/boot_flow.tscn", &"completed"), "BootFlow doit émettre completed.")
	_check(_scene_has_signal("res://screens/start/start_flow.tscn", &"open_gallery_requested"), "StartFlow doit émettre open_gallery_requested.")
	_check(_scene_has_signal("res://screens/start/start_flow.tscn", &"open_mission_requested"), "StartFlow doit émettre open_mission_requested.")
	_check(_scene_has_signal("res://screens/gallery/art_direction_gallery.tscn", &"back_requested"), "La galerie doit émettre back_requested.")
	_check(_scene_has_signal("res://screens/prototype/prototype_mission_screen.tscn", &"back_requested"), "La mission doit émettre back_requested.")

	var main := (load("res://app/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_check(main.get_node("ScreenHost").get_child_count() == 1, "Main doit héberger exactement un écran au runtime.")
	main.free()

	if _failures.is_empty():
		print("FOUNDATION_SMOKE_TEST: PASS")
		quit(0)
	else:
		print("FOUNDATION_SMOKE_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _scene_has_signal(path: String, signal_name: StringName) -> bool:
	var scene := load(path) as PackedScene
	if scene == null:
		return false
	var instance := scene.instantiate()
	var result := instance.has_signal(signal_name)
	instance.free()
	return result
