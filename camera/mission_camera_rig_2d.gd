@tool
class_name MissionCameraRig2D
extends Node2D

signal target_bound(player: PlayerCharacter2D)
signal progression_changed(center_x: float)

@export_category("Authority")
## Profil partagé contrôlant anticipation horizontale, verrou de progression et lissage.
@export var profile: RunAndGunCameraProfile
## Chemin vers l'hôte fournissant la map courante et ses limites de caméra.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Chemin vers le spawner permettant de suivre le joueur réellement instancié.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../RuntimeSystems/ActorSpawner")

@onready var camera: Camera2D = %Camera2D

var target: PlayerCharacter2D
var map_bounds := Rect2()
var furthest_center_x := -INF


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var host := map_host()
	var spawner := actor_spawner()
	if host == null or spawner == null or profile == null or not profile.is_valid():
		push_error("MissionCameraRig2D exige MapHost, ActorSpawner et un profil valide.")
		set_process(false)
		return
	host.map_loaded.connect(_on_map_loaded)
	spawner.player_spawned.connect(_on_player_spawned)
	if host.current_map != null:
		_on_map_loaded(host.current_map)
	if spawner.current_player != null:
		_on_player_spawned(spawner.current_player, null)
	camera.position_smoothing_enabled = profile.position_smoothing_enabled
	camera.position_smoothing_speed = profile.position_smoothing_speed
	camera.enabled = true


func _process(_delta: float) -> void:
	if target == null or map_bounds.size.x <= 0.0:
		return
	var viewport_size := camera.get_viewport_rect().size / camera.zoom
	var half_view := viewport_size * 0.5
	var minimum_center_x := map_bounds.position.x + half_view.x
	var maximum_center_x := map_bounds.end.x - half_view.x
	var requested_x := clampf(
		target.global_position.x + profile.forward_lookahead,
		minimum_center_x,
		maximum_center_x
	)
	if profile.lock_backward_progression:
		requested_x = maxf(furthest_center_x, requested_x)
	requested_x = minf(requested_x, maximum_center_x)
	if not is_equal_approx(requested_x, furthest_center_x):
		furthest_center_x = requested_x
		progression_changed.emit(furthest_center_x)
	var center_y := lerpf(
		map_bounds.position.y + half_view.y,
		map_bounds.end.y - half_view.y,
		profile.vertical_center_ratio
	)
	global_position = Vector2(requested_x, center_y)


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func actor_spawner() -> MissionActorSpawner2D:
	return get_node_or_null(actor_spawner_path) as MissionActorSpawner2D


func _on_map_loaded(map: MissionMapRoot2D) -> void:
	map_bounds = map.camera_bounds
	var viewport_size := camera.get_viewport_rect().size / camera.zoom if camera != null else Vector2(1280, 720)
	furthest_center_x = map_bounds.position.x + viewport_size.x * 0.5


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	target = player
	target_bound.emit(player)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if profile == null or not profile.is_valid():
		warnings.append("Assigner un RunAndGunCameraProfile valide.")
	if map_host() == null:
		warnings.append("Assigner le MissionMapHost2D de cet écran.")
	if actor_spawner() == null:
		warnings.append("Assigner le MissionActorSpawner2D de cet écran.")
	return warnings
