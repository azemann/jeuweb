class_name PrototypeMissionScreen
extends Control

signal back_requested


func _ready() -> void:
	%DesignReferencePanel.visible = false
	%BackButton.pressed.connect(back_requested.emit)
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
	%ActorSpawner.player_spawned.connect(_on_player_spawned)
	if %ActorSpawner.current_player != null:
		_on_player_spawned(%ActorSpawner.current_player, null)
	%BackButton.grab_focus()


func _on_mission_won() -> void:
	%ResultPanel.visible = true
	%ResultLabel.text = "MISSION ACCOMPLIE\nCÔTE TOXIQUE SÉCURISÉE"
	%BackButton.grab_focus()


func _on_encounter_started(_encounter_id: StringName, data: EncounterData) -> void:
	%EncounterLabel.text = "RENCONTRE · %s" % str(data.cadence_id).replace("_", " ").to_upper()
	%CadenceLabel.text = "PRÉPARATION"


func _on_wave_started(_encounter_id: StringName, wave_index: int, wave: WaveData) -> void:
	var beat_names := ["PRESSION", "RESPIRATION", "ESCALADE", "PAYOFF"]
	%CadenceLabel.text = "%s · VAGUE %d" % [beat_names[wave.combat_beat], wave_index + 1]


func _on_encounter_completed(_encounter_id: StringName) -> void:
	%CadenceLabel.text = "ZONE SÉCURISÉE"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	var health := player.health_component()
	if health == null or health.profile == null:
		return
	%Health.max_value = health.profile.maximum_health
	%Health.value = health.current_health
	if not health.health_changed.is_connected(_on_player_health_changed):
		health.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(current: float, maximum: float) -> void:
	%Health.max_value = maximum
	%Health.value = current
