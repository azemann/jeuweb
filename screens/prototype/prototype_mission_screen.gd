class_name PrototypeMissionScreen
extends Control

signal back_requested


func _ready() -> void:
	%DesignReferencePanel.visible = false
	%BackButton.pressed.connect(back_requested.emit)
	var host := _map_host()
	if not host.map_loading_started.is_connected(_on_map_loading_started):
		host.map_loading_started.connect(_on_map_loading_started)
	if not host.map_loaded.is_connected(_on_map_loaded):
		host.map_loaded.connect(_on_map_loaded)
	if not host.map_load_failed.is_connected(_on_map_load_failed):
		host.map_load_failed.connect(_on_map_load_failed)
	var run := %MissionRunController
	if not run.mission_won.is_connected(_on_mission_won):
		run.mission_won.connect(_on_mission_won)
	var encounters := %EncounterController as MissionEncounterController
	if not encounters.encounter_started.is_connected(_on_encounter_started):
		encounters.encounter_started.connect(_on_encounter_started)
	if not encounters.wave_started.is_connected(_on_wave_started):
		encounters.wave_started.connect(_on_wave_started)
	if not encounters.encounter_completed.is_connected(_on_encounter_completed):
		encounters.encounter_completed.connect(_on_encounter_completed)
	if not encounters.enemy_registered.is_connected(_on_enemy_registered):
		encounters.enemy_registered.connect(_on_enemy_registered)
	%ActorSpawner.player_spawned.connect(_on_player_spawned)
	if %ActorSpawner.current_player != null:
		_on_player_spawned(%ActorSpawner.current_player, null)
	get_tree().process_frame.connect(_load_mission, Object.CONNECT_ONE_SHOT)


func _map_host() -> MissionMapHost2D:
	return $MissionViewportContainer/MissionViewport/MapHost as MissionMapHost2D


func _hud() -> MissionHUD:
	return %MissionHUD as MissionHUD


func _load_mission() -> void:
	_map_host().load_map()


func _on_map_loading_started(definition: MissionMapDefinition) -> void:
	_hud().theme_profile = definition.hud_theme
	_hud().show_loading()


func _on_map_loaded(_map: MissionMapRoot2D) -> void:
	_hud().hide_loading()


func _on_map_load_failed(errors: PackedStringArray) -> void:
	_hud().show_error(errors)
	%BackButton.visible = true
	%BackButton.focus_mode = Control.FOCUS_ALL
	%BackButton.grab_focus()


func _on_mission_won() -> void:
	_hud().show_result("MISSION ACCOMPLIE\nCÔTE TOXIQUE SÉCURISÉE")
	%BackButton.visible = true
	%BackButton.focus_mode = Control.FOCUS_ALL
	%BackButton.grab_focus()


func _on_encounter_started(_encounter_id: StringName, data: EncounterData) -> void:
	_hud().set_objective_text("ALERTE · %s" % str(data.cadence_id).replace("_", " ").to_upper())


func _on_wave_started(_encounter_id: StringName, wave_index: int, wave: WaveData) -> void:
	var beat_names := ["PRESSION", "RESPIRATION", "ESCALADE", "PAYOFF"]
	_hud().set_objective_text("%s · VAGUE %d" % [beat_names[wave.combat_beat], wave_index + 1])


func _on_encounter_completed(_encounter_id: StringName) -> void:
	_hud().set_objective_text("ZONE SÉCURISÉE · PROGRESSEZ")


func _on_enemy_registered(_encounter_id: StringName, _wave_id: StringName, enemy: EnemyCharacter2D) -> void:
	if enemy.profile == null or enemy.profile.archetype_id != &"vacuum_boss":
		return
	var health := enemy.health_component()
	if health == null:
		return
	_hud().bind_boss(enemy)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	_hud().bind_player(player)
