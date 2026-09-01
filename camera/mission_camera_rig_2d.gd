@tool
class_name MissionCameraRig2D
extends Node2D

signal target_bound(player: PlayerCharacter2D)
signal progression_changed(center_x: float)

@export_category("Authority")
## Profil partagé contrôlant anticipation horizontale, retour arrière optionnel et lissage.
@export var profile: RunAndGunCameraProfile
## Chemin vers l'hôte fournissant la map courante et ses limites de caméra.
@export_node_path("MissionMapHost2D") var map_host_path := NodePath("../MapHost")
## Chemin vers le spawner permettant de suivre le joueur réellement instancié.
@export_node_path("MissionActorSpawner2D") var actor_spawner_path := NodePath("../RuntimeSystems/ActorSpawner")

@onready var camera: Camera2D = %Camera2D

var target: PlayerCharacter2D
var map_bounds := Rect2()
var current_center_x := -INF
var _shake_strength := 0.0
var _shake_duration := 0.0
var _shake_remaining := 0.0
var _shake_phase := 0.0


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


func _process(delta: float) -> void:
	_update_shake(delta)
	if target == null or map_bounds.size.x <= 0.0:
		return
	var viewport_size := camera.get_viewport_rect().size / camera.zoom
	var half_view := viewport_size * 0.5
	var minimum_center_x := map_bounds.position.x + half_view.x
	var maximum_center_x := map_bounds.end.x - half_view.x
	var facing := target.aim_component().facing if target.aim_component() != null else 1.0
	var requested_x := clampf(
		target.global_position.x + profile.forward_lookahead * facing,
		minimum_center_x,
		maximum_center_x
	)
	if profile.lock_backward_progression:
		requested_x = maxf(current_center_x, requested_x)
	requested_x = minf(requested_x, maximum_center_x)
	if not is_equal_approx(requested_x, current_center_x):
		current_center_x = requested_x
		progression_changed.emit(current_center_x)
	var center_y := lerpf(
		map_bounds.position.y + half_view.y,
		map_bounds.end.y - half_view.y,
		profile.vertical_center_ratio
	)
	global_position = Vector2(current_center_x, center_y)


func map_host() -> MissionMapHost2D:
	return get_node_or_null(map_host_path) as MissionMapHost2D


func actor_spawner() -> MissionActorSpawner2D:
	return get_node_or_null(actor_spawner_path) as MissionActorSpawner2D


func request_shake(strength: float, duration: float) -> bool:
	if strength <= 0.0 or duration <= 0.0 or profile == null:
		return false
	_shake_strength = minf(maxf(_shake_strength, strength), profile.maximum_shake_offset)
	_shake_duration = maxf(_shake_duration, duration)
	_shake_remaining = maxf(_shake_remaining, duration)
	return true


func shake_remaining() -> float:
	return _shake_remaining


func _on_map_loaded(map: MissionMapRoot2D) -> void:
	map_bounds = map.camera_bounds
	var viewport_size := camera.get_viewport_rect().size / camera.zoom if camera != null else Vector2(1280, 720)
	current_center_x = map_bounds.position.x + viewport_size.x * 0.5


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	if target != null and is_instance_valid(target):
		var previous_weapon := target.weapon_component()
		if previous_weapon != null and previous_weapon.fired.is_connected(_on_player_weapon_fired):
			previous_weapon.fired.disconnect(_on_player_weapon_fired)
	target = player
	var weapon := target.weapon_component()
	if weapon != null and not weapon.fired.is_connected(_on_player_weapon_fired):
		weapon.fired.connect(_on_player_weapon_fired)
	target_bound.emit(player)


func _on_player_weapon_fired(_direction: Vector2) -> void:
	if target == null:
		return
	var weapon_component := target.weapon_component()
	if weapon_component == null or weapon_component.weapon == null:
		return
	request_shake(
		weapon_component.weapon.camera_shake_strength,
		weapon_component.weapon.camera_shake_duration,
	)


func _update_shake(delta: float) -> void:
	if camera == null:
		return
	if _shake_remaining <= 0.0 or _shake_duration <= 0.0:
		camera.offset = Vector2.ZERO
		_shake_strength = 0.0
		_shake_duration = 0.0
		_shake_remaining = 0.0
		return
	_shake_remaining = maxf(0.0, _shake_remaining - delta)
	_shake_phase += delta * profile.shake_frequency * TAU
	var envelope := _shake_remaining / _shake_duration
	var sample := Vector2(sin(_shake_phase * 1.17), cos(_shake_phase * 1.73)).normalized()
	camera.offset = sample * _shake_strength * envelope


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if profile == null or not profile.is_valid():
		warnings.append("Assigner un RunAndGunCameraProfile valide.")
	if map_host() == null:
		warnings.append("Assigner le MissionMapHost2D de cet écran.")
	if actor_spawner() == null:
		warnings.append("Assigner le MissionActorSpawner2D de cet écran.")
	return warnings
