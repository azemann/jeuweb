extends SceneTree

var _failures: Array[String] = []
var _wave_log: Dictionary = {}
var _registered_count := 0
var _controller: MissionEncounterController
var _bridge_overlap_count := 0


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var landing := load("res://maps/encounters/data/toxic_coast/landing_cadence.tres") as EncounterData
	var bridge := load("res://maps/encounters/data/toxic_coast/bridge_gauntlet.tres") as EncounterData
	var foundry := load("res://maps/encounters/data/toxic_coast/foundry_boss_gate.tres") as EncounterData
	for encounter in [landing, bridge, foundry]:
		_check(encounter != null and encounter.validation_errors().is_empty(), "Chaque EncounterData Côte toxique doit être valide.")
	var catalog := load("res://characters/enemies/data/enemy_catalog.tres") as EnemyCatalog
	for encounter in [landing, bridge, foundry]:
		for wave in encounter.waves:
			for pattern in wave.spawn_patterns:
				_check(catalog.find_scene(pattern.enemy_archetype) != null, "%s doit être résolu par EnemyCatalog." % pattern.enemy_archetype)
	_check(landing.authored_enemy_count() == 3, "Landing doit composer deux Troopers puis un Grunt.")
	_check(landing.combat_beats() == PackedInt32Array([WaveData.CombatBeat.PRESSURE, WaveData.CombatBeat.RELEASE]), "Landing doit matérialiser Pressure puis Release.")
	_check(bridge.authored_enemy_count() == 6 and bridge.encounter_kind == EncounterData.EncounterKind.GAUNTLET, "Bridge doit être un Gauntlet de six ennemis.")
	_check(bridge.combat_beats() == PackedInt32Array([WaveData.CombatBeat.PRESSURE, WaveData.CombatBeat.ESCALATION, WaveData.CombatBeat.ESCALATION]), "Bridge doit porter Pressure puis une double Escalation.")
	_check(foundry.authored_enemy_count() == 3 and foundry.combat_beats()[-1] == WaveData.CombatBeat.PAYOFF, "Foundry doit culminer sur le payoff du Boss.")

	var pincer := load("res://maps/encounters/data/toxic_coast/patterns/bridge_grunt_pincer.tres") as EnemySpawnPatternData
	var pincer_offsets := pincer.authored_offsets()
	_check(pincer_offsets.size() == 2 and pincer_offsets[0].x < 0.0 and pincer_offsets[1].x > 0.0, "Le Spawn Pattern Pincer doit encadrer le point auteur.")
	var flying := load("res://maps/encounters/data/toxic_coast/patterns/bridge_flying_column.tres") as EnemySpawnPatternData
	var flying_offsets := flying.authored_offsets()
	_check(flying_offsets.size() == 2 and not is_equal_approx(flying_offsets[0].y, flying_offsets[1].y), "La colonne volante doit étager ses deux ennemis verticalement.")

	var packed := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := packed.instantiate() as PrototypeMissionScreen
	root.add_child(screen)
	var viewport := screen.get_node("MissionViewportContainer/MissionViewport") as SubViewport
	var controller := viewport.get_node("RuntimeSystems/EncounterController") as MissionEncounterController
	_controller = controller
	controller.wave_started.connect(_on_wave_started)
	controller.enemy_registered.connect(_on_enemy_registered)
	await process_frame
	await physics_frame
	var host := viewport.get_node("MapHost") as MissionMapHost2D
	var actor_spawner := viewport.get_node("RuntimeSystems/ActorSpawner") as MissionActorSpawner2D
	var expected_enemy_count := 0
	var enabled_encounter_ids: Array[StringName] = []
	for child in host.current_map.encounter_markers_root().get_children():
		var marker := child as MapEncounterMarker2D
		if marker != null and marker.enabled and marker.encounter_data != null:
			expected_enemy_count += marker.encounter_data.authored_enemy_count()
			enabled_encounter_ids.append(marker.encounter_id)
	actor_spawner.current_player.global_position = host.current_map.get_node("Gameplay/Exits/MissionEnd").global_position
	for _frame in 900:
		for child in host.current_map.actors_root().get_children():
			var enemy := child as EnemyCharacter2D
			var bridge_waves: Array = _wave_log.get(&"bridge_gauntlet", [])
			var preserve_timed_overlap := str(child.name).begins_with("bridge_gauntlet_") and bridge_waves.has(&"bridge_escalation_air") and not bridge_waves.has(&"bridge_escalation_pincer")
			if preserve_timed_overlap:
				continue
			if enemy != null and enemy.health_component() != null and enemy.health_component().current_health > 0.0:
				enemy.health_component().apply_damage(enemy.health_component().current_health)
		await physics_frame
		var all_completed := true
		for encounter_id in enabled_encounter_ids:
			if not controller.is_completed(encounter_id):
				all_completed = false
				break
		if all_completed:
			break
	_check(_registered_count == expected_enemy_count, "Le contrôleur doit enregistrer exactement les %d ennemis décrits par les Encounter Markers actifs." % expected_enemy_count)
	_check(_wave_log.get(&"landing_cadence", []) == [&"landing_pressure", &"landing_release"], "Les vagues Landing doivent conserver l'ordre auteur.")
	_check(_wave_log.get(&"bridge_gauntlet", []) == [&"bridge_pressure", &"bridge_escalation_air", &"bridge_escalation_pincer"], "Le Gauntlet doit conserver ses trois vagues auteur.")
	_check(_bridge_overlap_count == 2, "After Delay doit lancer le Pincer tandis que les deux ennemis volants sont encore actifs.")
	_check(_wave_log.get(&"foundry_boss_gate", []) == [&"foundry_pressure", &"foundry_payoff"], "Le Combat Gate doit terminer sur le Boss.")
	_check(screen.get_node("HUD/HUDLayout/CadenceStack/CadenceLabel").text == "ZONE SÉCURISÉE" or screen.get_node("ResultPanel").visible, "Le HUD doit rendre la cadence et sa résolution visibles au joueur.")
	_check(screen.get_node("BossHealthPanel").visible and screen.get_node("BossHealthPanel/Stack/BossHealth").value == 0.0, "Le HUD doit rendre les dégâts et la mort du Boss explicitement visibles.")
	for gate in host.current_map.combat_gates_root().get_children():
		_check(gate is MissionCombatGate2D and not gate.is_closed(), "Chaque Combat Gate doit être ouvert après sa rencontre.")
		_check(gate.get_node("Barrier").collision_layer == 0 and not gate.get_node("EnergyField").visible, "Une porte ouverte doit réellement retirer collision et champ visuel.")
	screen.queue_free()
	await process_frame
	if _failures.is_empty():
		print("ENCOUNTER_CADENCE_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("ENCOUNTER_CADENCE_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _on_wave_started(encounter_id: StringName, _wave_index: int, wave: WaveData) -> void:
	if not _wave_log.has(encounter_id):
		_wave_log[encounter_id] = []
	_wave_log[encounter_id].append(wave.wave_id)
	if encounter_id == &"bridge_gauntlet" and wave.wave_id == &"bridge_escalation_pincer":
		_bridge_overlap_count = _controller.active_enemy_count(encounter_id)


func _on_enemy_registered(_encounter_id: StringName, _wave_id: StringName, _enemy: EnemyCharacter2D) -> void:
	_registered_count += 1
