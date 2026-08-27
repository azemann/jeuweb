@tool
class_name MissionEnemySpawner2D
extends Node

signal encounter_spawned(encounter_id: StringName, enemies: Array[EnemyCharacter2D])

@export_category("Correspondence")
## Hôte dont la scène maîtresse contient les marqueurs auteur et la branche Actors.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Spawner du joueur utilisé comme autorité de progression horizontale.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../ActorSpawner")
## Catalogue Resource traduisant chaque enemy_archetype en PackedScene.
@export var catalog: EnemyCatalog

var _triggered: Dictionary = {}


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var host := map_host()
	if host != null and not host.map_loaded.is_connected(_on_map_loaded):
		host.map_loaded.connect(_on_map_loaded)
	set_physics_process(host != null and catalog != null)


func _physics_process(_delta: float) -> void:
	var host := map_host()
	var actor_spawner := actor_spawner()
	if host == null or host.current_map == null or actor_spawner == null or actor_spawner.current_player == null:
		return
	var marker_root := host.current_map.get_node_or_null("Gameplay/EnemySpawns")
	if marker_root == null:
		return
	for marker_node in marker_root.get_children():
		var marker := marker_node as MapEncounterMarker2D
		if marker == null or not marker.enabled or _triggered.has(marker.encounter_id):
			continue
		if actor_spawner.current_player.global_position.x >= marker.global_position.x - marker.activation_distance:
			spawn_encounter(host.current_map, marker)


func spawn_encounter(map: MissionMapRoot2D, marker: MapEncounterMarker2D) -> Array[EnemyCharacter2D]:
	var spawned: Array[EnemyCharacter2D] = []
	if map == null or marker == null or catalog == null:
		return spawned
	_triggered[marker.encounter_id] = true
	var scene := catalog.find_scene(StringName(marker.enemy_archetype))
	if scene == null:
		push_warning("Aucune scène ennemie pour l'archétype '%s'." % marker.enemy_archetype)
		return spawned
	var center_offset := (float(marker.count) - 1.0) * marker.formation_spacing * 0.5
	for index in marker.count:
		var enemy := scene.instantiate() as EnemyCharacter2D
		if enemy == null:
			push_error("La scène '%s' doit produire un EnemyCharacter2D." % marker.enemy_archetype)
			continue
		enemy.name = "%s_%02d" % [marker.encounter_id, index + 1]
		var spawn_global_position := marker.global_position + Vector2(index * marker.formation_spacing - center_offset, 0.0)
		# La position doit exister avant _ready(), car Patrol la mémorise comme origine.
		enemy.position = map.actors_root().to_local(spawn_global_position)
		map.actors_root().add_child(enemy)
		spawned.append(enemy)
	encounter_spawned.emit(marker.encounter_id, spawned)
	return spawned


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func actor_spawner() -> MissionActorSpawner2D:
	return get_node_or_null(actor_spawner_path) as MissionActorSpawner2D


func _on_map_loaded(_map: MissionMapRoot2D) -> void:
	_triggered.clear()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if map_host() == null:
		warnings.append("Assigner le MissionMapHost2D.")
	if actor_spawner() == null:
		warnings.append("Assigner le MissionActorSpawner2D.")
	if catalog == null or not catalog.validation_errors().is_empty():
		warnings.append("Assigner un EnemyCatalog valide.")
	return warnings
