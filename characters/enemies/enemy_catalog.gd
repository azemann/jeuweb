@tool
class_name EnemyCatalog
extends Resource

@export_category("Correspondences")
## Entrées éditables reliant les identifiants de carte aux scènes ennemies.
@export var bindings: Array[EnemySceneBinding] = []


func find_scene(archetype_id: StringName) -> PackedScene:
	for binding in bindings:
		if binding != null and binding.archetype_id == archetype_id:
			return binding.scene
	return null


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	var known: Dictionary = {}
	for index in bindings.size():
		var binding := bindings[index]
		if binding == null or not binding.is_valid():
			errors.append("Binding ennemi %d absent ou invalide." % index)
			continue
		if known.has(binding.archetype_id):
			errors.append("Archétype ennemi dupliqué : %s." % binding.archetype_id)
		known[binding.archetype_id] = true
	return errors
