extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var packed := load("res://maps/missions/toxic_coast/toxic_coast.tscn") as PackedScene
	var map := packed.instantiate() as MissionMapRoot2D
	root.add_child(map)
	await physics_frame
	var terrain := map.destructible_terrain()
	var impact_position := Vector2(920, 625)
	var observations := {
		"callback_count": 0,
		"flushes_during_callback": -1,
		"affected_chunks": 0,
		"rebuilt_chunks": 0,
	}
	terrain.collision_chunks_rebuilt.connect(func(chunk_count: int) -> void:
		observations.rebuilt_chunks += chunk_count
	)

	var probe := Area2D.new()
	probe.collision_layer = 0
	probe.collision_mask = terrain.collision_layer
	var probe_shape := CollisionShape2D.new()
	var probe_circle := CircleShape2D.new()
	probe_circle.radius = 3.0
	probe_shape.shape = probe_circle
	probe.add_child(probe_shape)
	probe.body_entered.connect(func(body: Node2D) -> void:
		if observations.callback_count > 0 or body.get_parent() != terrain:
			return
		observations.callback_count += 1
		var first := terrain.carve_circle(impact_position, 48.0)
		var second := terrain.carve_circle(impact_position, 48.0)
		observations.affected_chunks = first
		observations.flushes_during_callback = terrain.collision_flush_count
		_check(second == first, "Deux impacts identiques doivent désigner le même ensemble de chunks.")
		_check(terrain.pending_collision_chunk_count() == first, "Les chunks sales doivent être dédupliqués avant le flush.")
	)
	map.add_child(probe)
	probe.global_position = impact_position

	for _frame in 4:
		await physics_frame
		await process_frame
		if observations.callback_count > 0 and terrain.collision_flush_count > 0:
			break

	_check(observations.callback_count == 1, "Le test doit creuser depuis une vraie callback body_entered.")
	_check(observations.flushes_during_callback == 0, "Aucune collision ne doit être reconstruite pendant body_entered.")
	_check(not terrain.is_solid_at(impact_position), "Le masque doit être modifié immédiatement pendant l'impact.")
	_check(terrain.collision_flush_count == 1, "Deux impacts dans la même callback doivent partager un seul flush différé.")
	_check(terrain.collision_chunk_rebuild_count == observations.affected_chunks, "Chaque chunk sale doit être reconstruit exactement une fois.")
	_check(observations.rebuilt_chunks == observations.affected_chunks, "Le signal de synchronisation doit publier le nombre réel de chunks reconstruits.")
	_check(observations.rebuilt_chunks <= terrain.profile.maximum_chunks_per_flush, "Un impact de référence doit rester sous le budget de chunks reconstruits par flush.")
	_check(not terrain.has_pending_collision_rebuild() and terrain.pending_collision_chunk_count() == 0, "La file de chunks sales doit être vide après synchronisation.")

	map.free()
	if _failures.is_empty():
		print("DESTRUCTIBLE_TERRAIN_DEFERRED_REBUILD_TEST: PASS")
		quit(0)
	else:
		print("DESTRUCTIBLE_TERRAIN_DEFERRED_REBUILD_TEST: FAIL (%d)" % _failures.size())
		quit(1)
