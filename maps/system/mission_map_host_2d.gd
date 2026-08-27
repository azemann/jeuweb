@tool
class_name MissionMapHost2D
extends Node2D

signal map_loaded(map: MissionMapRoot2D)
signal map_unloaded(map_id: StringName)

## Définition de la mission à charger ; elle désigne l'unique scène maîtresse autoritaire.
@export var definition: MissionMapDefinition:
	set(value):
		definition = value
		update_configuration_warnings()
## Charge automatiquement la map à l'entrée dans l'arbre. Désactiver pour les tests ou transitions pilotées.
@export var load_on_ready := true

var current_map: MissionMapRoot2D


func _ready() -> void:
	if Engine.is_editor_hint() or not load_on_ready:
		return
	load_map()


func load_map(override_definition: MissionMapDefinition = null) -> MissionMapRoot2D:
	var requested := override_definition if override_definition != null else definition
	if requested == null or not requested.is_valid():
		push_error("MissionMapHost2D exige une MissionMapDefinition valide.")
		return null
	unload_map()
	var packed := load(requested.scene_path) as PackedScene
	if packed == null or not packed.can_instantiate():
		push_error("Scène de carte introuvable : %s" % requested.scene_path)
		return null
	var instance := packed.instantiate() as MissionMapRoot2D
	if instance == null:
		push_error("La scène '%s' doit produire un MissionMapRoot2D." % requested.scene_path)
		return null
	var errors := instance.validation_errors()
	if not errors.is_empty():
		push_error("Carte '%s' invalide : %s" % [requested.map_id, "; ".join(errors)])
		instance.free()
		return null
	add_child(instance)
	current_map = instance
	map_loaded.emit(instance)
	return instance


func unload_map() -> void:
	if not is_instance_valid(current_map):
		return
	var previous_id := current_map.map_id()
	remove_child(current_map)
	current_map.queue_free()
	current_map = null
	map_unloaded.emit(previous_id)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if definition == null or not definition.is_valid():
		warnings.append("Assigner une MissionMapDefinition valide.")
	return warnings
