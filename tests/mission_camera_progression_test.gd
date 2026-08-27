extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var screen := (load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene).instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame
	var viewport := screen.get_node("MissionViewportContainer/MissionViewport")
	var host := viewport.get_node("MapHost") as MissionMapHost2D
	var spawner := viewport.get_node("ActorSpawner") as MissionActorSpawner2D
	var rig := viewport.get_node("MissionCameraRig") as MissionCameraRig2D
	_check(rig != null and rig.profile != null and rig.profile.is_valid(), "La mission doit exposer un CameraRig profilé.")
	_check(rig.target == spawner.current_player, "CameraRig doit suivre le joueur instancié.")
	_check(spawner.current_player.get_node_or_null("PlayerCamera") == null, "Le joueur ne doit plus posséder une caméra concurrente.")
	_check(not host.current_map.get_node("PreviewCamera").enabled, "PreviewCamera doit être inactive au runtime.")
	_check(host.current_map.get_node("Visual/FarBackgroundParallax") is Parallax2D, "Le fond lointain doit appartenir à une couche de parallaxe.")

	var initial_center := rig.global_position.x
	spawner.current_player.global_position.x = 1050.0
	await process_frame
	await process_frame
	var progressed_center := rig.global_position.x
	_check(progressed_center > initial_center, "La caméra doit avancer lorsque le joueur progresse vers la droite.")
	spawner.current_player.global_position.x = 420.0
	await process_frame
	await process_frame
	_check(rig.global_position.x >= progressed_center, "La caméra arcade ne doit pas reculer après progression.")
	screen.free()

	if _failures.is_empty():
		print("MISSION_CAMERA_PROGRESSION_TEST: PASS")
		quit(0)
	else:
		print("MISSION_CAMERA_PROGRESSION_TEST: FAIL (%d)" % _failures.size())
		quit(1)

