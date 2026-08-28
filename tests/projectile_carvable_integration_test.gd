extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var map_scene := load("res://maps/missions/toxic_coast/toxic_coast.tscn") as PackedScene
	var projectile_scene := load("res://weapons/projectiles/field_round_2d.tscn") as PackedScene
	_check(map_scene != null and projectile_scene != null, "La map et le projectile doivent être chargeables.")
	if map_scene == null or projectile_scene == null:
		_finish()
		return

	var map := map_scene.instantiate() as MissionMapRoot2D
	root.add_child(map)
	await process_frame
	var terrain := map.destructible_terrain()
	var impact_position := Vector2(920, 625)
	_check(terrain != null and terrain.is_solid_at(impact_position), "Le point de test doit commencer dans la matière Carvable.")

	var projectile := projectile_scene.instantiate() as Projectile2D
	map.add_child(projectile)
	projectile.global_position = impact_position
	var observations := {"carves": 0}
	projectile.terrain_carved.connect(func(_terrain: DestructibleTerrain2D, chunks: int) -> void:
		if chunks > 0:
			observations.carves += 1
	)
	projectile.call(&"_resolve_impact", terrain)
	_check(observations.carves == 1, "La munition doit demander exactement un creusement au terrain touché.")
	_check(not terrain.is_solid_at(impact_position), "Le centre de l'impact doit devenir traversable façon Worms.")
	_check(terrain.is_solid_at(impact_position + Vector2(18, 0)), "Une balle ne doit retirer qu'un petit disque local.")

	map.free()
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("PROJECTILE_CARVABLE_INTEGRATION_TEST: PASS")
		quit(0)
	else:
		print("PROJECTILE_CARVABLE_INTEGRATION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
