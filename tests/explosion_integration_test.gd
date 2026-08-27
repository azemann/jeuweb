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
	var map := map_scene.instantiate() as MissionMapRoot2D
	root.add_child(map)
	var terrain := map.get_node("DestructibleTerrain") as DestructibleTerrain2D
	var explosion := map.get_node("Actors/Effects/TerrainDemoExplosion") as Explosion2D

	_check(explosion != null, "Côte toxique doit exposer une explosion de démonstration dans Actors/Effects.")
	_check(explosion.data != null and explosion.data.is_valid(), "L'explosion doit consommer une ExplosionData valide.")
	_check(terrain.is_solid_at(explosion.global_position), "L'explosion de démonstration doit être placée dans la matière destructible.")

	var observations := {"carved_events": 0, "affected_chunks": 0}
	if explosion != null:
		explosion.terrain_carved.connect(func(_terrain: DestructibleTerrain2D, chunks: int) -> void:
			observations.carved_events += 1
			observations.affected_chunks += chunks
		)
		explosion.apply_impact_now()

	_check(not terrain.is_solid_at(explosion.global_position), "L'impact doit creuser la matière à son origine.")
	_check(observations.carved_events == 1, "L'explosion doit signaler chaque terrain effectivement creusé.")
	_check(observations.affected_chunks >= 1, "L'explosion doit reconstruire au moins un chunk touché.")
	map.free()

	if _failures.is_empty():
		print("EXPLOSION_INTEGRATION_TEST: PASS")
		quit(0)
	else:
		print("EXPLOSION_INTEGRATION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
