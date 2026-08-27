@tool
class_name MapEncounterMarker2D
extends Marker2D

@export_category("Encounter")
## Identité stable de cette occurrence dans la mission.
@export var encounter_id: StringName
## Rôle attendu ; une future registry le traduira en PackedScene.
@export_enum("vacuum_trooper", "vacuum_brute", "vacuum_siphoner", "alien_pilot") var enemy_archetype := "vacuum_trooper"
## Nombre d'ennemis demandé par cette occurrence ; la formation reste décidée par le futur spawner.
@export_range(1, 12, 1) var count := 1
## Distance horizontale, en pixels, entre deux ennemis successifs de la formation.
@export_range(32.0, 512.0, 8.0) var formation_spacing := 140.0
## Distance horizontale, en pixels, à laquelle la progression du joueur active la rencontre.
@export_range(64.0, 1600.0, 16.0) var activation_distance := 640.0
## Permet de neutraliser cette rencontre depuis l'Inspector sans effacer son placement.
@export var enabled := true


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if str(encounter_id).is_empty():
		warnings.append("Encounter ID est obligatoire et doit être unique dans la carte.")
	if formation_spacing <= 0.0:
		warnings.append("Formation Spacing doit être positif.")
	return warnings
