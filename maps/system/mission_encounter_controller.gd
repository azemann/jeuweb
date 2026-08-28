@tool
class_name MissionEncounterController
extends Node

signal encounter_started(encounter_id: StringName, data: EncounterData)
signal wave_started(encounter_id: StringName, wave_index: int, wave: WaveData)
signal wave_finished(encounter_id: StringName, wave_index: int, wave: WaveData)
signal enemy_registered(encounter_id: StringName, wave_id: StringName, enemy: EnemyCharacter2D)
signal encounter_completed(encounter_id: StringName)

@export_category("Correspondence")
## Hôte dont la scène maîtresse porte les Encounter Markers et la branche Actors.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Spawner du joueur utilisé uniquement comme autorité de progression horizontale.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../ActorSpawner")
## Spawner primitif qui traduit un archétype en scène sans décider de la cadence.
@export_node_path("MissionEnemySpawner2D") var enemy_spawner_path := NodePath("../EnemySpawner")

var _started: Dictionary = {}
var _completed: Dictionary = {}
var _active_counts: Dictionary = {}
var _spawn_serials: Dictionary = {}
var _states: Dictionary = {}


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var host := map_host()
	if host != null and not host.map_loaded.is_connected(_on_map_loaded):
		host.map_loaded.connect(_on_map_loaded)
	set_physics_process(host != null and enemy_spawner() != null)


func _physics_process(delta: float) -> void:
	_detect_encounters()
	for encounter_id: StringName in _states.keys():
		_tick_encounter(encounter_id, delta)


func _detect_encounters() -> void:
	var host := map_host()
	var player_spawner := actor_spawner()
	if host == null or host.current_map == null or player_spawner == null or player_spawner.current_player == null:
		return
	var marker_root := host.current_map.get_node_or_null("Gameplay/EnemySpawns")
	if marker_root == null:
		return
	for child in marker_root.get_children():
		var marker := child as MapEncounterMarker2D
		if marker == null or not marker.enabled or _started.has(marker.encounter_id):
			continue
		if player_spawner.current_player.global_position.x >= marker.global_position.x - marker.activation_distance:
			_begin_encounter(host.current_map, marker)


func start_encounter(marker: MapEncounterMarker2D) -> void:
	var host := map_host()
	if host != null and host.current_map != null and marker != null and not _started.has(marker.encounter_id):
		_begin_encounter(host.current_map, marker)


func active_enemy_count(encounter_id: StringName) -> int:
	return int(_active_counts.get(encounter_id, 0))


func is_completed(encounter_id: StringName) -> bool:
	return _completed.has(encounter_id)


func _begin_encounter(map: MissionMapRoot2D, marker: MapEncounterMarker2D) -> void:
	if marker.encounter_data == null or not marker.encounter_data.validation_errors().is_empty():
		push_error("La rencontre '%s' exige une EncounterData valide." % marker.encounter_id)
		return
	_started[marker.encounter_id] = true
	_active_counts[marker.encounter_id] = 0
	_spawn_serials[marker.encounter_id] = 0
	_states[marker.encounter_id] = {
		"map": map,
		"marker": marker,
		"wave_index": 0,
		"pattern_index": 0,
		"offset_index": 0,
		"phase": &"lead_in",
		"timer": marker.encounter_data.waves[0].lead_in_delay,
	}
	_set_combat_gate(map, marker.encounter_id, true)
	encounter_started.emit(marker.encounter_id, marker.encounter_data)


func _tick_encounter(encounter_id: StringName, delta: float) -> void:
	if not _states.has(encounter_id):
		return
	var state: Dictionary = _states[encounter_id]
	state.timer = maxf(0.0, float(state.timer) - delta)
	if state.timer > 0.0:
		return
	# Plusieurs transitions sans délai peuvent être résolues pendant la même frame.
	for _transition_guard in 64:
		var marker := state.marker as MapEncounterMarker2D
		var data := marker.encounter_data
		var wave_index := int(state.wave_index)
		var wave := data.waves[wave_index] if wave_index < data.waves.size() else null
		match StringName(state.phase):
			&"lead_in":
				wave_started.emit(encounter_id, wave_index, wave)
				state.pattern_index = 0
				state.phase = &"pattern_delay"
				state.timer = wave.spawn_patterns[0].delay_before
			&"pattern_delay":
				state.offset_index = 0
				state.phase = &"spawn"
			&"spawn":
				var pattern := wave.spawn_patterns[int(state.pattern_index)]
				var offsets := pattern.authored_offsets()
				var offset_index := int(state.offset_index)
				_spawn_serials[encounter_id] = int(_spawn_serials[encounter_id]) + 1
				var enemy := enemy_spawner().spawn_enemy(
					state.map,
					encounter_id,
					pattern,
					marker.global_position + offsets[offset_index],
					int(_spawn_serials[encounter_id])
				)
				if enemy != null:
					_register_enemy(encounter_id, wave.wave_id, enemy)
				state.offset_index = offset_index + 1
				if int(state.offset_index) < offsets.size():
					state.timer = pattern.spawn_interval
				else:
					state.pattern_index = int(state.pattern_index) + 1
					if int(state.pattern_index) < wave.spawn_patterns.size():
						state.phase = &"pattern_delay"
						state.timer = wave.spawn_patterns[int(state.pattern_index)].delay_before
					elif wave.advance_condition == WaveData.AdvanceCondition.WHEN_CLEARED:
						state.phase = &"wait_clear"
					else:
						state.phase = &"timed_advance"
						state.timer = wave.advance_delay
			&"wait_clear":
				if active_enemy_count(encounter_id) > 0:
					return
				_finish_wave(encounter_id, state, wave)
			&"timed_advance":
				_finish_wave(encounter_id, state, wave)
			&"encounter_clear":
				if active_enemy_count(encounter_id) > 0:
					return
				state.phase = &"completion_delay"
				state.timer = data.completion_delay
			&"completion_delay":
				_complete_encounter(encounter_id, state.map, marker)
				return
		if float(state.timer) > 0.0:
			return
	push_error("La rencontre '%s' dépasse la garde de transitions sans délai." % encounter_id)


func _finish_wave(encounter_id: StringName, state: Dictionary, wave: WaveData) -> void:
	var wave_index := int(state.wave_index)
	wave_finished.emit(encounter_id, wave_index, wave)
	state.wave_index = wave_index + 1
	var marker := state.marker as MapEncounterMarker2D
	if int(state.wave_index) < marker.encounter_data.waves.size():
		state.phase = &"lead_in"
		state.timer = marker.encounter_data.waves[int(state.wave_index)].lead_in_delay
	else:
		state.phase = &"encounter_clear"
		state.timer = 0.0


func _complete_encounter(encounter_id: StringName, map: MissionMapRoot2D, marker: MapEncounterMarker2D) -> void:
	_completed[encounter_id] = true
	_states.erase(encounter_id)
	_set_combat_gate(map, encounter_id, false)
	encounter_completed.emit(encounter_id)


func _register_enemy(encounter_id: StringName, wave_id: StringName, enemy: EnemyCharacter2D) -> void:
	_active_counts[encounter_id] = active_enemy_count(encounter_id) + 1
	var health := enemy.health_component()
	if health != null:
		health.died.connect(_on_enemy_died.bind(encounter_id), CONNECT_ONE_SHOT)
	enemy_registered.emit(encounter_id, wave_id, enemy)


func _on_enemy_died(encounter_id: StringName) -> void:
	_active_counts[encounter_id] = maxi(0, active_enemy_count(encounter_id) - 1)


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func actor_spawner() -> MissionActorSpawner2D:
	return get_node_or_null(actor_spawner_path) as MissionActorSpawner2D


func enemy_spawner() -> MissionEnemySpawner2D:
	return get_node_or_null(enemy_spawner_path) as MissionEnemySpawner2D


func _on_map_loaded(_map: MissionMapRoot2D) -> void:
	_started.clear()
	_completed.clear()
	_active_counts.clear()
	_spawn_serials.clear()
	_states.clear()


func _set_combat_gate(map: MissionMapRoot2D, encounter_id: StringName, closed: bool) -> void:
	var gates_root := map.get_node_or_null("Gameplay/Encounters")
	if gates_root == null:
		return
	for child in gates_root.get_children():
		var gate := child as MissionCombatGate2D
		if gate != null and gate.encounter_id == encounter_id:
			gate.set_closed(closed)


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if map_host() == null:
		errors.append("MissionMapHost2D obligatoire.")
	if actor_spawner() == null:
		errors.append("MissionActorSpawner2D obligatoire.")
	if enemy_spawner() == null:
		errors.append("MissionEnemySpawner2D obligatoire.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
