@tool
class_name MissionMapCatalog
extends Resource

## Liste ordonnée des missions disponibles, utilisée pour résoudre un map_id sans chemin codé en dur.
@export var maps: Array[MissionMapDefinition] = []


func find_map(map_id: StringName) -> MissionMapDefinition:
	for definition in maps:
		if definition != null and definition.map_id == map_id:
			return definition
	return null


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	var known_ids: Dictionary = {}
	for index in maps.size():
		var definition := maps[index]
		if definition == null or not definition.is_valid():
			errors.append("La définition %d est absente ou invalide." % index)
			continue
		if known_ids.has(definition.map_id):
			errors.append("Le map_id '%s' est dupliqué." % definition.map_id)
		known_ids[definition.map_id] = true
	return errors
