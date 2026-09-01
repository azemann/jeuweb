@tool
class_name MissionMapHost2D
extends Node2D

signal map_loaded(map: MissionMapRoot2D)
signal map_loading_started(definition: MissionMapDefinition)
signal map_load_failed(errors: PackedStringArray)
signal map_unloaded(map_id: StringName)

## Définition de la mission à charger ; elle désigne l'unique scène maîtresse autoritaire.
@export var definition: MissionMapDefinition:
	set(value):
		definition = value
		update_configuration_warnings()
## Charge automatiquement la map à l'entrée dans l'arbre. Désactiver pour les tests ou transitions pilotées.
@export var load_on_ready := true

var current_map: MissionMapRoot2D
var last_load_errors := PackedStringArray()


func _ready() -> void:
	if Engine.is_editor_hint() or not load_on_ready:
		return
	load_map()


func load_map(override_definition: MissionMapDefinition = null) -> MissionMapRoot2D:
	var requested := override_definition if override_definition != null else definition
	last_load_errors = PackedStringArray()
	map_loading_started.emit(requested)
	if requested == null or not requested.is_valid():
		return _fail_load("MissionMapHost2D exige une MissionMapDefinition valide.")
	unload_map()
	var packed := load(requested.scene_path) as PackedScene
	if packed == null or not packed.can_instantiate():
		return _fail_load("Scène de carte introuvable : %s" % requested.scene_path)
	var instance := packed.instantiate() as MissionMapRoot2D
	if instance == null:
		return _fail_load("La scène '%s' doit produire un MissionMapRoot2D." % requested.scene_path)
	var errors := instance.validation_errors()
	if not errors.is_empty():
		instance.free()
		return _fail_load("Carte '%s' invalide : %s" % [requested.map_id, "; ".join(errors)])
	add_child(instance)
	current_map = instance
	map_loaded.emit(instance)
	return instance


func _fail_load(message: String) -> MissionMapRoot2D:
	last_load_errors = PackedStringArray([message])
	push_error(message)
	map_load_failed.emit(last_load_errors)
	return null


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
