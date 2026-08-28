@tool
class_name WaveData
extends Resource

enum CombatBeat {
	PRESSURE,
	RELEASE,
	ESCALATION,
	PAYOFF,
}

enum AdvanceCondition {
	WHEN_CLEARED,
	AFTER_DELAY,
}

@export_category("Identity")
## Identifiant stable de cette vague dans son EncounterData.
@export var wave_id: StringName
## Fonction rythmique communiquée au level designer dans l'Inspector.
@export var combat_beat := CombatBeat.PRESSURE

@export_category("Composition")
## Motifs d'apparition exécutés dans l'ordre au sein de cette vague.
@export var spawn_patterns: Array[EnemySpawnPatternData] = []

@export_category("Cadence")
## Respiration entre l'ouverture de la vague et son premier motif.
@export_range(0.0, 15.0, 0.05) var lead_in_delay := 0.0
## Condition autorisant la vague suivante : élimination ou délai volontaire.
@export var advance_condition := AdvanceCondition.WHEN_CLEARED
## Délai après le dernier spawn lorsque la progression est temporelle.
@export_range(0.0, 20.0, 0.05) var advance_delay := 0.0


func authored_enemy_count() -> int:
	var total := 0
	for pattern in spawn_patterns:
		if pattern != null:
			total += pattern.spawn_count()
	return total


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(wave_id).is_empty():
		errors.append("Wave ID est obligatoire.")
	if spawn_patterns.is_empty():
		errors.append("Une vague exige au moins un EnemySpawnPatternData.")
	var known_patterns: Dictionary = {}
	for pattern in spawn_patterns:
		if pattern == null:
			errors.append("Un motif de spawn est absent.")
			continue
		for pattern_error in pattern.validation_errors():
			errors.append("%s : %s" % [pattern.pattern_id, pattern_error])
		if known_patterns.has(pattern.pattern_id):
			errors.append("Pattern ID '%s' est dupliqué dans la vague." % pattern.pattern_id)
		known_patterns[pattern.pattern_id] = true
	return errors
