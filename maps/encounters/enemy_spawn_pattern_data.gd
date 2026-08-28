@tool
class_name EnemySpawnPatternData
extends Resource

enum Formation {
	CENTERED_LINE,
	LEFT_TO_RIGHT,
	RIGHT_TO_LEFT,
	VERTICAL_STACK,
	PINCER,
	CUSTOM_OFFSETS,
}

@export_category("Identity")
## Identifiant stable de ce motif à l'intérieur de sa vague.
@export var pattern_id: StringName
## Archétype résolu par EnemyCatalog au moment de chaque apparition.
@export var enemy_archetype: StringName = &"vacuum_grunt"

@export_category("Formation")
## Règle géométrique appliquée autour du MapEncounterMarker2D auteur.
@export var formation := Formation.CENTERED_LINE
## Nombre d'ennemis générés, sauf en mode Custom Offsets où la liste fait autorité.
@export_range(1, 16, 1) var count := 1
## Écart entre occurrences ; les deux axes sont utilisés par les formations adaptées.
@export var spacing := Vector2(140.0, 0.0)
## Décalage commun de toute la formation par rapport au marqueur auteur.
@export var local_offset := Vector2.ZERO
## Positions entièrement auteur utilisées uniquement par la formation Custom Offsets.
@export var custom_offsets := PackedVector2Array()

@export_category("Cadence")
## Silence précédant ce motif après le motif précédent de la même vague.
@export_range(0.0, 10.0, 0.05) var delay_before := 0.0
## Intervalle séparant chaque apparition du motif ; zéro produit une formation simultanée.
@export_range(0.0, 5.0, 0.05) var spawn_interval := 0.0


func spawn_count() -> int:
	return custom_offsets.size() if formation == Formation.CUSTOM_OFFSETS else count


func authored_offsets() -> PackedVector2Array:
	if formation == Formation.CUSTOM_OFFSETS:
		var result := PackedVector2Array()
		for offset in custom_offsets:
			result.append(local_offset + offset)
		return result
	var result := PackedVector2Array()
	for index in count:
		match formation:
			Formation.CENTERED_LINE:
				result.append(local_offset + Vector2((float(index) - (float(count) - 1.0) * 0.5) * spacing.x, index * spacing.y))
			Formation.LEFT_TO_RIGHT:
				result.append(local_offset + Vector2(index * spacing.x, index * spacing.y))
			Formation.RIGHT_TO_LEFT:
				result.append(local_offset - Vector2(index * spacing.x, -index * spacing.y))
			Formation.VERTICAL_STACK:
				result.append(local_offset + Vector2(index * spacing.x, (float(index) - (float(count) - 1.0) * 0.5) * spacing.y))
			Formation.PINCER:
				var side := -1.0 if index % 2 == 0 else 1.0
				var rank := float(index / 2 + 1)
				result.append(local_offset + Vector2(side * rank * spacing.x, (rank - 1.0) * spacing.y))
	return result


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(pattern_id).is_empty():
		errors.append("Pattern ID est obligatoire.")
	if str(enemy_archetype).is_empty():
		errors.append("Enemy Archetype est obligatoire.")
	if formation == Formation.CUSTOM_OFFSETS and custom_offsets.is_empty():
		errors.append("Custom Offsets exige au moins une position auteur.")
	if formation != Formation.CUSTOM_OFFSETS and count > 1 and spacing.is_zero_approx():
		errors.append("Une formation multiple exige un espacement non nul.")
	return errors
