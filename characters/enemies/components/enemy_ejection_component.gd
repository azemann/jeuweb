@tool
class_name EnemyEjectionComponent
extends Node

signal ejected(actor: EnemyCharacter2D)

@export_category("Lifecycle Correspondence")
## Health dont la mort déclenche l'éjection après le délai auteur.
@export_node_path("EnemyHealthComponent") var health_component_path := NodePath("../Health")
## Socket de la coque depuis lequel le pilote apparaît dans Actors.
@export_node_path("Marker2D") var ejection_origin_path := NodePath("../../Presentation/SlopeVisual/EjectionOrigin")
## Scène canonique instanciée pour le pilote éjecté.
@export var ejected_scene: PackedScene
## Délai alignant l'acteur autonome avec l'ouverture visuelle de la coque.
@export_range(0.0, 2.0, 0.05) var ejection_delay := 0.65

var _triggered := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var health := get_node_or_null(health_component_path) as EnemyHealthComponent
	if health != null and not health.died.is_connected(_on_died):
		health.died.connect(_on_died)


func _on_died() -> void:
	if _triggered or ejected_scene == null:
		return
	_triggered = true
	var origin := get_node_or_null(ejection_origin_path) as Marker2D
	var spawn_position := origin.global_position if origin != null else (get_parent().get_parent() as Node2D).global_position
	await get_tree().create_timer(ejection_delay).timeout
	var actors_root := get_parent().get_parent().get_parent()
	var pilot := ejected_scene.instantiate() as EnemyCharacter2D
	if pilot == null or actors_root == null:
		return
	actors_root.add_child(pilot)
	pilot.global_position = spawn_position
	ejected.emit(pilot)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if get_node_or_null(health_component_path) == null:
		warnings.append("EnemyHealthComponent obligatoire.")
	if get_node_or_null(ejection_origin_path) == null:
		warnings.append("EjectionOrigin obligatoire.")
	if ejected_scene == null:
		warnings.append("Scène du pilote éjecté obligatoire.")
	return warnings
