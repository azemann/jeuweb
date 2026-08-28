extends SceneTree

class DamageProbe:
	extends StaticBody2D

	var damage_calls := 0
	var total_damage := 0.0

	func apply_damage(amount: float) -> bool:
		if amount <= 0.0:
			return false
		damage_calls += 1
		total_damage += amount
		return true


var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var map_scene := load("res://maps/missions/toxic_coast/toxic_coast.tscn") as PackedScene
	var map := map_scene.instantiate() as MissionMapRoot2D
	root.add_child(map)
	var terrain := map.destructible_terrain()
	var explosion := map.get_node("EditorPreview/ExplosionPreview") as Explosion2D

	_check(explosion != null, "Côte toxique doit exposer son ExplosionPreview sous EditorPreview.")
	_check(explosion.data != null and explosion.data.is_valid(), "L'explosion doit consommer une ExplosionData valide.")
	_check(not explosion.detonate_on_ready, "Une explosion doit être placée avant sa détonation explicite.")
	_check(terrain.is_solid_at(explosion.global_position), "L'explosion de démonstration doit être placée dans la matière destructible.")

	var probe := _create_damage_probe()
	map.add_child(probe)
	probe.global_position = explosion.global_position
	await physics_frame

	var observations := {"carved_events": 0, "affected_chunks": 0, "damaged_events": 0}
	if explosion != null:
		explosion.terrain_carved.connect(func(_terrain: DestructibleTerrain2D, chunks: int) -> void:
			observations.carved_events += 1
			observations.affected_chunks += chunks
		)
		explosion.target_damaged.connect(func(target: Node2D, damage: float, _impulse: Vector2) -> void:
			if target == probe and is_equal_approx(damage, explosion.data.damage):
				observations.damaged_events += 1
		)
		explosion.apply_impact_now()

	_check(not terrain.is_solid_at(explosion.global_position), "L'impact doit creuser la matière à son origine.")
	_check(observations.carved_events == 1, "L'explosion doit signaler chaque terrain effectivement creusé.")
	_check(observations.affected_chunks >= 1, "L'explosion doit reconstruire au moins un chunk touché.")
	_check(probe.damage_calls == 1, "Body et Hurtbox doivent résoudre un seul Damage Receiver.")
	_check(is_equal_approx(probe.total_damage, explosion.data.damage), "Explosion2D doit appliquer elle-même les dégâts de sa Resource.")
	_check(observations.damaged_events == 1, "target_damaged doit confirmer une unique application acceptée.")
	map.free()

	if _failures.is_empty():
		print("EXPLOSION_INTEGRATION_TEST: PASS")
		quit(0)
	else:
		print("EXPLOSION_INTEGRATION_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _create_damage_probe() -> DamageProbe:
	var probe := DamageProbe.new()
	probe.name = "DamageProbe"
	probe.collision_layer = 2
	probe.collision_mask = 0
	var body_collision := CollisionShape2D.new()
	var body_shape := CircleShape2D.new()
	body_shape.radius = 18.0
	body_collision.shape = body_shape
	probe.add_child(body_collision)

	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 4
	hurtbox.collision_mask = 0
	var hurtbox_collision := CollisionShape2D.new()
	var hurtbox_shape := CircleShape2D.new()
	hurtbox_shape.radius = 18.0
	hurtbox_collision.shape = hurtbox_shape
	hurtbox.add_child(hurtbox_collision)
	probe.add_child(hurtbox)
	return probe
