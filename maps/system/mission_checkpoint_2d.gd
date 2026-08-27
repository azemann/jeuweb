@tool
class_name MissionCheckpoint2D
extends Area2D

signal activated(spawn_id: StringName)

@export_category("Checkpoint")
## Identifiant du MapSpawnPoint2D utilisé par le respawn.
@export var spawn_id: StringName
## Empêche les activations répétées après le premier passage valide du joueur.
@export var one_shot := true

var _activated := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated and one_shot:
		return
	if not body.is_in_group(&"players") or str(spawn_id).is_empty():
		return
	var spawner := get_tree().get_first_node_in_group(&"mission_actor_spawners") as MissionActorSpawner2D
	if spawner == null or not spawner.set_respawn_spawn(spawn_id):
		return
	_activated = true
	activated.emit(spawn_id)


func _get_configuration_warnings() -> PackedStringArray:
	if str(spawn_id).is_empty():
		return PackedStringArray(["Checkpoint Spawn ID est obligatoire."])
	return PackedStringArray()
