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
	var spawner := viewport.get_node("RuntimeSystems/ActorSpawner") as MissionActorSpawner2D
	var rig := viewport.get_node("MissionCameraRig") as MissionCameraRig2D
	_check(rig != null and rig.profile != null and rig.profile.is_valid(), "La mission doit exposer un CameraRig profilé.")
	_check(not rig.profile.lock_backward_progression, "Le profil Côte toxique doit autoriser le retour arrière.")
	_check(is_zero_approx(rig.profile.forward_lookahead), "Le profil Côte toxique ne doit pas déplacer la caméra lors d'un changement de direction.")
	_check(rig.profile.maximum_shake_offset > 0.0 and rig.profile.shake_frequency > 0.0, "Le profil caméra doit borner les secousses de combat.")
	_check(rig.target == spawner.current_player, "CameraRig doit suivre le joueur instancié.")
	_check(spawner.current_player.get_node_or_null("PlayerCamera") == null, "Le joueur ne doit plus posséder une caméra concurrente.")
	_check(not host.current_map.get_node("EditorPreview/PreviewCamera").enabled, "PreviewCamera doit être inactive au runtime.")
	_check(host.current_map.get_node("Visual/SegmentBackgrounds").get_child_count() == 5, "La caméra doit parcourir trois backgrounds et leurs deux raccords.")

	var initial_center := rig.global_position.x
	spawner.current_player.global_position.x = 1050.0
	await process_frame
	await process_frame
	var progressed_center := rig.global_position.x
	_check(progressed_center > initial_center, "La caméra doit avancer lorsque le joueur progresse vers la droite.")
	var center_before_turn := rig.global_position.x
	spawner.current_player.aim_component().set_aim_direction(Vector2.LEFT)
	await process_frame
	await process_frame
	_check(is_equal_approx(rig.global_position.x, center_before_turn), "Changer de direction sans bouger ne doit pas déplacer la caméra.")
	spawner.current_player.global_position.x = 720.0
	await process_frame
	await process_frame
	_check(rig.global_position.x < progressed_center, "La caméra doit revenir vers la gauche avec le joueur.")
	var progression_before_shake := rig.global_position
	var tracked_player := rig.target
	rig.target = null
	_check(rig.request_shake(4.0, 0.1), "Le CameraRig doit conserver une commande optionnelle pour les événements lourds.")
	await create_timer(0.04).timeout
	_check(not rig.camera.offset.is_zero_approx(), "Une demande lourde explicite doit utiliser Camera2D.offset.")
	_check(rig.global_position.is_equal_approx(progression_before_shake), "Une secousse optionnelle ne doit pas déplacer le Rig.")
	await create_timer(0.12).timeout
	_check(rig.camera.offset.is_zero_approx(), "La secousse optionnelle doit restaurer un offset nul.")
	rig.target = tracked_player
	screen.free()

	if _failures.is_empty():
		print("MISSION_CAMERA_PROGRESSION_TEST: PASS")
		quit(0)
	else:
		print("MISSION_CAMERA_PROGRESSION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
