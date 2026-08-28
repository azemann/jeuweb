@tool
class_name MissionEnemySpawner2D
extends Node

signal enemy_spawned(encounter_id: StringName, pattern_id: StringName, enemy: EnemyCharacter2D)

@export_category("Correspondence")
## Hôte dont la scène maîtresse contient la branche Actors recevant les ennemis.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Catalogue Resource traduisant chaque enemy_archetype en PackedScene.
@export var catalog: EnemyCatalog


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_physics_process(false)


func spawn_enemy(
	map: MissionMapRoot2D,
	encounter_id: StringName,
	pattern: EnemySpawnPatternData,
	spawn_global_position: Vector2,
	serial: int
) -> EnemyCharacter2D:
	if map == null or pattern == null or catalog == null:
		return null
	var scene := catalog.find_scene(pattern.enemy_archetype)
	if scene == null:
		push_warning("Aucune scène ennemie pour l'archétype '%s'." % pattern.enemy_archetype)
		return null
	var enemy := scene.instantiate() as EnemyCharacter2D
	if enemy == null:
		push_error("La scène '%s' doit produire un EnemyCharacter2D." % pattern.enemy_archetype)
		return null
	enemy.name = "%s_%02d" % [encounter_id, serial]
	# La position doit exister avant _ready(), car Patrol la mémorise comme origine.
	enemy.position = map.actors_root().to_local(spawn_global_position)
	map.actors_root().add_child(enemy)
	enemy_spawned.emit(encounter_id, pattern.pattern_id, enemy)
	return enemy


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if map_host() == null:
		warnings.append("Assigner le MissionMapHost2D.")
	if catalog == null or not catalog.validation_errors().is_empty():
		warnings.append("Assigner un EnemyCatalog valide.")
	return warnings
