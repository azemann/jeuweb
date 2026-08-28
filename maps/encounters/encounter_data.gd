@tool
class_name EncounterData
extends Resource

enum EncounterKind {
	STANDARD,
	COMBAT_GATE,
	KILL_ROOM,
	GAUNTLET,
	SET_PIECE,
	ARENA,
}

@export_category("Identity")
## Identifiant réutilisable de cette recette de rencontre.
@export var cadence_id: StringName
## Intention de level design affichée dans l'Inspector.
@export var encounter_kind := EncounterKind.STANDARD

@export_category("Progression")
## Cette rencontre doit être terminée pour autoriser la sortie de mission.
@export var blocks_mission_exit := true
## Respiration après la dernière élimination avant de déclarer la rencontre terminée.
@export_range(0.0, 10.0, 0.05) var completion_delay := 0.0

@export_category("Cadence")
## Vagues ordonnées constituant pression, respiration, escalade et payoff.
@export var waves: Array[WaveData] = []


func authored_enemy_count() -> int:
	var total := 0
	for wave in waves:
		if wave != null:
			total += wave.authored_enemy_count()
	return total


func combat_beats() -> PackedInt32Array:
	var result := PackedInt32Array()
	for wave in waves:
		if wave != null:
			result.append(wave.combat_beat)
	return result


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(cadence_id).is_empty():
		errors.append("Cadence ID est obligatoire.")
	if waves.is_empty():
		errors.append("EncounterData exige au moins une WaveData.")
	var known_waves: Dictionary = {}
	for wave in waves:
		if wave == null:
			errors.append("Une WaveData est absente.")
			continue
		for wave_error in wave.validation_errors():
			errors.append("%s : %s" % [wave.wave_id, wave_error])
		if known_waves.has(wave.wave_id):
			errors.append("Wave ID '%s' est dupliqué dans la rencontre." % wave.wave_id)
		known_waves[wave.wave_id] = true
	return errors
