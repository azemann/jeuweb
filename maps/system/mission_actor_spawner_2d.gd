@tool
class_name MissionActorSpawner2D
extends Node

signal player_spawned(player: PlayerCharacter2D, spawn: MapSpawnPoint2D)

@export_category("Correspondence")
## Hôte de map dont le chargement déclenche l'apparition des acteurs de mission.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Scène canonique du joueur instanciée dans la branche Actors de la map chargée.
@export var player_scene: PackedScene
## Identifiant du MapSpawnPoint2D utilisé pour la position et l'orientation initiales.
@export var player_spawn_id: StringName = &"player_start"

var current_player: PlayerCharacter2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var host := map_host()
	if host == null:
		push_error("MissionActorSpawner2D exige un MissionMapHost2D.")
		return
	if not host.map_loaded.is_connected(_on_map_loaded):
		host.map_loaded.connect(_on_map_loaded)
	if host.current_map != null:
		spawn_player(host.current_map)


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func spawn_player(map: MissionMapRoot2D) -> PlayerCharacter2D:
	if player_scene == null or map == null or map.actors_root() == null:
		return null
	var spawn := map.find_spawn(player_spawn_id)
	if spawn == null:
		push_error("Spawn joueur introuvable : %s" % player_spawn_id)
		return null
	var player := player_scene.instantiate() as PlayerCharacter2D
	if player == null:
		push_error("player_scene doit produire un PlayerCharacter2D.")
		return null
	player.name = "RuntimePlayer"
	map.actors_root().add_child(player)
	player.global_position = spawn.global_position
	var aim := player.aim_component()
	if aim != null:
		aim.set_facing(-1.0 if spawn.facing == "left" else 1.0)
	current_player = player
	player_spawned.emit(player, spawn)
	return player


func _on_map_loaded(map: MissionMapRoot2D) -> void:
	spawn_player(map)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if map_host() == null:
		warnings.append("Assigner un MissionMapHost2D valide.")
	if player_scene == null:
		warnings.append("Assigner la scène canonique du joueur.")
	if str(player_spawn_id).is_empty():
		warnings.append("Player Spawn ID est obligatoire.")
	return warnings
