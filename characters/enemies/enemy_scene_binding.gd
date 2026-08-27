@tool
class_name EnemySceneBinding
extends Resource

@export_category("Correspondence")
## Identifiant de MapEncounterMarker2D résolu par cette entrée.
@export var archetype_id: StringName
## Scène canonique instanciée pour cet archétype.
@export var scene: PackedScene


func is_valid() -> bool:
	return not str(archetype_id).is_empty() and scene != null and scene.can_instantiate()
