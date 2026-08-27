@tool
class_name MissionRunController
extends Node

signal mission_won
signal encounter_cleared(encounter_id: StringName)

@export_category("Correspondence")
## Hôte qui expose la scène maîtresse et ses objectifs auteur.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Spawner qui expose l'instance courante du joueur pour tester la sortie.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../ActorSpawner")
## Spawner dont les signaux associent les ennemis runtime aux rencontres auteur.
@export_node_path("MissionEnemySpawner2D") var enemy_spawner_path := NodePath("../EnemySpawner")
## Chemin vers la sortie, relatif à la racine de la scène maîtresse chargée.
@export_node_path("Marker2D") var exit_path := NodePath("Gameplay/Exits/MissionEnd")
## Distance maximale entre le joueur et le Marker2D de sortie pour gagner.
@export_range(16.0, 160.0, 4.0) var exit_radius := 72.0

var _required_encounters: Dictionary = {}
var _remaining_enemies: Dictionary = {}
var _cleared_encounters: Dictionary = {}
var _won := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var host := map_host()
	if host != null and not host.map_loaded.is_connected(_on_map_loaded):
		host.map_loaded.connect(_on_map_loaded)
	var spawner := get_node_or_null(enemy_spawner_path) as MissionEnemySpawner2D
	if spawner != null and not spawner.encounter_spawned.is_connected(_on_encounter_spawned):
		spawner.encounter_spawned.connect(_on_encounter_spawned)
	if host != null and host.current_map != null:
		_on_map_loaded(host.current_map)


func _physics_process(_delta: float) -> void:
	if _won:
		return
	var host := map_host()
	var actor_spawner := get_node_or_null(actor_spawner_path) as MissionActorSpawner2D
	if host == null or host.current_map == null or actor_spawner == null or actor_spawner.current_player == null:
		return
	var exit := _resolve_exit(host.current_map)
	if exit != null and all_required_encounters_cleared() and actor_spawner.current_player.global_position.distance_to(exit.global_position) <= exit_radius:
		_won = true
		mission_won.emit()


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func required_encounter_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for encounter_id: StringName in _required_encounters:
		result.append(encounter_id)
	result.sort()
	return result


func remaining_enemy_count(encounter_id: StringName) -> int:
	return int(_remaining_enemies.get(encounter_id, 0))


func all_required_encounters_cleared() -> bool:
	for encounter_id: StringName in _required_encounters:
		if not _cleared_encounters.has(encounter_id):
			return false
	return true


func _on_map_loaded(map: MissionMapRoot2D) -> void:
	_required_encounters.clear()
	_remaining_enemies.clear()
	_cleared_encounters.clear()
	_won = false
	var root := map.get_node_or_null("Gameplay/EnemySpawns")
	if root == null:
		return
	for child in root.get_children():
		var marker := child as MapEncounterMarker2D
		if marker != null and marker.enabled and marker.required_for_completion:
			_required_encounters[marker.encounter_id] = true


func _on_encounter_spawned(encounter_id: StringName, enemies: Array[EnemyCharacter2D]) -> void:
	if not _required_encounters.has(encounter_id) or enemies.is_empty():
		return
	for enemy in enemies:
		var health := enemy.health_component()
		if health != null and not health.died.is_connected(_on_enemy_died.bind(encounter_id, enemy)):
			health.died.connect(_on_enemy_died.bind(encounter_id, enemy))
	_remaining_enemies[encounter_id] = enemies.size()


func _on_enemy_died(encounter_id: StringName, _enemy: EnemyCharacter2D) -> void:
	if not _remaining_enemies.has(encounter_id):
		return
	_remaining_enemies[encounter_id] = maxi(0, int(_remaining_enemies[encounter_id]) - 1)
	if _remaining_enemies[encounter_id] == 0:
		_remaining_enemies.erase(encounter_id)
		_cleared_encounters[encounter_id] = true
		encounter_cleared.emit(encounter_id)


func _resolve_exit(map: MissionMapRoot2D) -> Marker2D:
	return map.get_node_or_null(exit_path) as Marker2D


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if map_host() == null:
		errors.append("MissionMapHost2D obligatoire.")
	if get_node_or_null(actor_spawner_path) == null:
		errors.append("MissionActorSpawner2D obligatoire.")
	if get_node_or_null(enemy_spawner_path) == null:
		errors.append("MissionEnemySpawner2D obligatoire.")
	if exit_path.is_empty():
		errors.append("Le chemin relatif vers la sortie est obligatoire.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
