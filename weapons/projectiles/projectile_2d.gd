class_name Projectile2D
extends Area2D

signal impacted(target: Node, damage: float)
signal terrain_carved(terrain: DestructibleTerrain2D, affected_chunks: int)
signal expired

@export_category("Definition")
## Définition autoritaire du vol, de l'impact, du terrain et de la présentation du projectile.
@export var data: ProjectileData

var direction := Vector2.RIGHT
var shooter: Node2D
var _resolved := false

@onready var collision_shape: CollisionShape2D = %CollisionShape
@onready var tracer: Polygon2D = %Tracer
@onready var core: Polygon2D = %Core
@onready var lifetime_timer: Timer = %Lifetime


func _ready() -> void:
	if data == null or not data.is_valid():
		push_error("Projectile2D exige une ProjectileData valide.")
		set_physics_process(false)
		return
	_apply_presentation()
	lifetime_timer.start(data.lifetime)


func launch(requested_direction: Vector2, source: Node2D = null) -> void:
	direction = requested_direction.normalized() if not requested_direction.is_zero_approx() else Vector2.RIGHT
	shooter = source
	rotation = direction.angle()


## Empêche un canon long de faire naître sa balle derrière une paroi proche.
## Retourne vrai lorsque la trajectoire interne origine → Muzzle était obstruée.
func resolve_muzzle_obstruction(clearance_origin: Vector2) -> bool:
	if _resolved or not is_inside_tree() or clearance_origin.is_equal_approx(global_position):
		return false
	var query := PhysicsRayQueryParameters2D.create(
		clearance_origin, global_position, collision_mask, _ray_exclusions()
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.hit_from_inside = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return false
	global_position = result.get(&"position", clearance_origin) as Vector2
	_resolve_impact(_damage_receiver(result.get(&"collider") as Node))
	return true


func _physics_process(delta: float) -> void:
	var next_position := global_position + direction * data.speed * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next_position, collision_mask, _ray_exclusions())
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		global_position = result.get(&"position", next_position) as Vector2
		var collider := result.get(&"collider") as Node
		if not _belongs_to_shooter(collider):
			_resolve_impact(_damage_receiver(collider))
			return
	global_position = next_position


func _on_body_entered(body: Node2D) -> void:
	if _belongs_to_shooter(body):
		return
	_resolve_impact(body)


func _on_area_entered(area: Area2D) -> void:
	if _belongs_to_shooter(area):
		return
	_resolve_impact(_damage_receiver(area))


func _resolve_impact(target: Node) -> void:
	if _resolved:
		return
	_resolved = true
	if data.has_explosion():
		_spawn_explosion()
	else:
		if target != null and target.has_method(&"apply_damage"):
			target.call(&"apply_damage", data.damage)
		_apply_terrain_impact()
	impacted.emit(target, data.damage)
	_spawn_impact()
	queue_free()


func _apply_terrain_impact() -> void:
	if not data.affects_destructible_terrain or not is_inside_tree():
		return
	for candidate in get_tree().get_nodes_in_group(&"destructible_terrains"):
		if candidate is not DestructibleTerrain2D:
			continue
		var terrain := candidate as DestructibleTerrain2D
		var affected := terrain.carve_circle(global_position, data.terrain_radius)
		if affected > 0:
			terrain_carved.emit(terrain, affected)


func _spawn_impact() -> void:
	if data.impact_scene == null or get_parent() == null:
		return
	var impact := data.impact_scene.instantiate() as Node2D
	if impact == null:
		return
	get_parent().add_child(impact)
	impact.global_position = global_position
	impact.rotation = rotation


func _spawn_explosion() -> void:
	if not data.has_explosion() or get_parent() == null:
		return
	var explosion := data.explosion_scene.instantiate() as Explosion2D
	if explosion == null:
		return
	explosion.data = data.explosion_data
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	explosion.global_rotation = global_rotation
	explosion.detonate()


func _damage_receiver(source: Node) -> Node:
	var current := source
	for _depth in 4:
		if current == null:
			break
		if current.has_method(&"apply_damage"):
			return current
		current = current.get_parent()
	return source


func _belongs_to_shooter(candidate: Node) -> bool:
	return shooter != null and (candidate == shooter or shooter.is_ancestor_of(candidate))


func _ray_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = [get_rid()]
	if shooter is CollisionObject2D:
		exclusions.append((shooter as CollisionObject2D).get_rid())
	if shooter != null:
		for child in shooter.find_children("*", "CollisionObject2D", true, false):
			exclusions.append((child as CollisionObject2D).get_rid())
	return exclusions


func _apply_presentation() -> void:
	var half_length := data.tracer_length * 0.5
	var half_width := data.tracer_width * 0.5
	tracer.polygon = PackedVector2Array([
		Vector2(-half_length, -half_width), Vector2(half_length, -half_width),
		Vector2(half_length, half_width), Vector2(-half_length, half_width),
	])
	tracer.color = data.tracer_color
	core.polygon = PackedVector2Array([
		Vector2(-half_length * 0.35, -half_width * 0.45), Vector2(half_length, -half_width * 0.45),
		Vector2(half_length, half_width * 0.45), Vector2(-half_length * 0.35, half_width * 0.45),
	])
	core.color = data.core_color
	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = Vector2(data.tracer_length, maxf(2.0, data.tracer_width))


func _on_lifetime_timeout() -> void:
	if _resolved:
		return
	_resolved = true
	expired.emit()
	queue_free()
