extends SceneTree

var _failures: Array[String] = []
var _mission_won_count := 0


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var packed := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	_check(packed != null and packed.can_instantiate(), "L'écran de mission doit être instanciable.")
	if packed == null:
		_finish()
		return

	var screen := packed.instantiate() as PrototypeMissionScreen
	root.add_child(screen)
	await process_frame
	await physics_frame

	var viewport := screen.get_node("MissionViewportContainer/MissionViewport") as SubViewport
	var host := viewport.get_node("MapHost") as MissionMapHost2D
	var actor_spawner := viewport.get_node("ActorSpawner") as MissionActorSpawner2D
	var encounter_controller := viewport.get_node("EncounterController") as MissionEncounterController
	var controller := viewport.get_node("MissionRunController") as MissionRunController
	_check(host != null and host.current_map != null, "La scène maîtresse doit être chargée pour la mission.")
	_check(actor_spawner != null and actor_spawner.current_player != null, "Le joueur doit être présent dans la mission.")
	_check(encounter_controller != null and encounter_controller.validation_errors().is_empty(), "MissionEncounterController doit exposer ses correspondances dans le SceneTree.")
	_check(controller != null and controller.validation_errors().is_empty(), "MissionRunController doit exposer des correspondances valides dans le SceneTree.")
	if host == null or host.current_map == null or actor_spawner == null or actor_spawner.current_player == null or encounter_controller == null or controller == null:
		screen.queue_free()
		_finish()
		return

	_check(controller.exit_path == NodePath("Gameplay/Exits/MissionEnd"), "Le chemin de sortie doit être relatif à la scène maîtresse.")
	var required_encounters := controller.required_encounter_ids()
	var expected_encounters := [&"bridge_gauntlet", &"foundry_boss_gate", &"landing_cadence"]
	_check(required_encounters.size() == expected_encounters.size() and required_encounters.all(func(encounter_id): return expected_encounters.has(encounter_id)), "Les trois rencontres rythmées doivent bloquer la sortie : %s" % str(required_encounters))
	_check(not controller.all_required_encounters_cleared(), "Une rencontre non apparue ne doit jamais être considérée comme éliminée.")

	controller.mission_won.connect(_on_mission_won)
	var exit := host.current_map.get_node("Gameplay/Exits/MissionEnd") as Marker2D
	actor_spawner.current_player.global_position = exit.global_position
	await physics_frame
	await physics_frame
	_check(_mission_won_count == 0, "Atteindre la sortie avant d'éliminer la rencontre ne doit pas terminer la mission.")

	var killed := 0
	for _frame in 900:
		for child in host.current_map.actors_root().get_children():
			var enemy := child as EnemyCharacter2D
			if enemy != null and enemy.health_component() != null and enemy.health_component().current_health > 0.0:
				enemy.health_component().apply_damage(enemy.health_component().current_health)
				killed += 1
		await physics_frame
		if controller.all_required_encounters_cleared():
			break
	_check(killed >= 12, "Le run doit réellement traverser les douze apparitions de la cadence auteur.")
	_check(controller.all_required_encounters_cleared(), "La rencontre doit être marquée éliminée après sa dernière mort.")
	actor_spawner.current_player.global_position = exit.global_position
	await physics_frame
	await physics_frame
	_check(_mission_won_count == 1, "La sortie doit émettre mission_won exactement une fois après l'objectif.")
	_check(screen.get_node("ResultPanel").visible, "Le résultat de victoire doit être visible dans l'écran de mission.")
	await physics_frame
	_check(_mission_won_count == 1, "Une mission gagnée ne doit pas réémettre mission_won.")

	screen.queue_free()
	await process_frame
	_finish()


func _on_mission_won() -> void:
	_mission_won_count += 1


func _finish() -> void:
	if _failures.is_empty():
		print("MISSION_RUN_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MISSION_RUN_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
