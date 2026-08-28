@tool
class_name MissionCombatGate2D
extends Node2D

signal closed
signal opened

@export_category("Correspondence")
## Occurrence de MapEncounterMarker2D dont l'achèvement ouvre cette barrière.
@export var encounter_id: StringName
## État initial appliqué au chargement de la scène maîtresse.
@export var starts_closed := true

@export_category("Scene Composition")
## Corps physique World qui bloque réellement le joueur et les acteurs.
@export_node_path("StaticBody2D") var barrier_path := NodePath("Barrier")
## Présentation énergétique rendue visible tant que la barrière est fermée.
@export_node_path("CanvasItem") var visual_path := NodePath("EnergyField")

var _is_closed := true


func _ready() -> void:
	set_closed(starts_closed)


func set_closed(value: bool) -> void:
	_is_closed = value
	var barrier := get_node_or_null(barrier_path) as StaticBody2D
	if barrier != null:
		barrier.set_deferred("collision_layer", 1 if value else 0)
	var visual := get_node_or_null(visual_path) as CanvasItem
	if visual != null:
		visual.visible = value
	if not Engine.is_editor_hint():
		if value:
			closed.emit()
		else:
			opened.emit()


func is_closed() -> bool:
	return _is_closed


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(encounter_id).is_empty():
		errors.append("Encounter ID correspondant est obligatoire.")
	if get_node_or_null(barrier_path) == null:
		errors.append("Barrier StaticBody2D est obligatoire.")
	if get_node_or_null(visual_path) == null:
		errors.append("Energy Field visuel est obligatoire.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
