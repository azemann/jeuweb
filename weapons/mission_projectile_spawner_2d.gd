@tool
class_name MissionProjectileSpawner2D
extends Node

signal projectile_spawned(projectile: Projectile2D)

@export_category("Correspondence")
## Hôte fournissant la map active et sa branche Actors/Projectiles.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Spawner dont le joueur instancié émet les demandes de projectile.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../ActorSpawner")
## Nom de la branche runtime qui reçoit les projectiles afin de garder l'arbre lisible.
@export var projectile_root_name: StringName = &"Projectiles"


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var spawner := actor_spawner()
	if spawner == null:
		push_error("MissionProjectileSpawner2D exige un MissionActorSpawner2D.")
		return
	if not spawner.player_spawned.is_connected(_on_player_spawned):
		spawner.player_spawned.connect(_on_player_spawned)
	if spawner.current_player != null:
		_on_player_spawned(spawner.current_player, null)


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func actor_spawner() -> MissionActorSpawner2D:
	return get_node_or_null(actor_spawner_path) as MissionActorSpawner2D


func projectile_root() -> Node2D:
	var host := map_host()
	if host == null or host.current_map == null or host.current_map.actors_root() == null:
		return null
	return host.current_map.actors_root().get_node_or_null(NodePath(str(projectile_root_name))) as Node2D


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	var weapon := player.weapon_component()
	if weapon != null and not weapon.projectile_requested.is_connected(_on_projectile_requested):
		weapon.projectile_requested.connect(_on_projectile_requested)


func _on_projectile_requested(
	projectile_scene: PackedScene,
	spawn_transform: Transform2D,
	direction: Vector2,
	shooter: Node2D,
	clearance_origin: Vector2,
) -> void:
	var root := projectile_root()
	if root == null or projectile_scene == null or not projectile_scene.can_instantiate():
		push_error("Demande de projectile invalide ou conteneur Actors/Projectiles absent.")
		return
	var projectile := projectile_scene.instantiate() as Projectile2D
	if projectile == null:
		push_error("La scène demandée doit produire un Projectile2D.")
		return
	root.add_child(projectile)
	projectile.global_transform = spawn_transform
	projectile.launch(direction, shooter)
	projectile_spawned.emit(projectile)
	projectile.resolve_muzzle_obstruction(clearance_origin)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if map_host() == null:
		warnings.append("Assigner un MissionMapHost2D valide.")
	if actor_spawner() == null:
		warnings.append("Assigner un MissionActorSpawner2D valide.")
	if str(projectile_root_name).is_empty():
		warnings.append("Projectile Root Name est obligatoire.")
	return warnings
