@tool
class_name MapSpawnPoint2D
extends Marker2D

enum SpawnKind {
	PLAYER_START,
	CHECKPOINT,
	MAP_ENTRY,
}

@export_category("Identity")
## Identifiant stable résolu par les spawners, checkpoints et futures sauvegardes.
@export var spawn_id: StringName
## Rôle du point : départ joueur, checkpoint ou entrée réservée à un système.
@export var kind := SpawnKind.PLAYER_START
## Direction initiale de l'acteur instancié ; modifie son regard sans tourner le Marker2D.
@export_enum("left", "right") var facing := "right"


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if str(spawn_id).is_empty():
		warnings.append("Spawn ID est obligatoire et doit être unique dans la carte.")
	return warnings
