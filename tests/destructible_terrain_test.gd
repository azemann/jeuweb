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
	var terrain := map.destructible_terrain()
	_check(terrain != null, "Côte toxique doit contenir DestructibleTerrain2D.")
	if terrain != null:
		_check(terrain.mask_image != null, "Le masque doit être généré depuis les zones auteur.")
		_check(terrain.collision_bitmap != null, "Le bitmap de collision doit être généré.")
		_check(terrain.collision_bitmap_build_count == 1, "Le bitmap complet doit être construit une seule fois.")
		_check(terrain.is_solid_at(Vector2(920, 625)), "Le centre de CentralSoil doit être solide avant impact.")
		_check(not terrain.is_solid_at(Vector2(500, 625)), "La géométrie permanente ne doit pas contaminer le masque destructible.")
		var before := terrain.collision_bitmap.get_true_bit_count()
		var affected := terrain.carve_circle(Vector2(920, 625), 48.0)
		var after := terrain.collision_bitmap.get_true_bit_count()
		_check(not terrain.is_solid_at(Vector2(920, 625)), "Le centre du cratère doit devenir de l'air.")
		_check(after < before, "Un cratère doit retirer de la matière.")
		_check(affected >= 1 and affected <= 4, "Un petit cratère doit salir entre un et quatre chunks.")
		_check(terrain.has_pending_collision_rebuild(), "Le creusement doit planifier la collision sans la reconstruire dans l'appel courant.")
		_check(terrain.collision_flush_count == 0, "La collision ne doit pas être modifiée synchroniquement par carve_circle().")
		await process_frame
		_check(not terrain.has_pending_collision_rebuild() and terrain.pending_collision_chunk_count() == 0, "Le flush différé doit vider tous les chunks sales.")
		_check(terrain.collision_flush_count == 1 and terrain.collision_chunk_rebuild_count == affected, "Un cratère doit produire un seul flush contenant chaque chunk affecté une fois.")
		_check(terrain.collision_bitmap_build_count == 1, "Une explosion locale ne doit pas reconstruire le bitmap complet.")
		var collision_shapes := terrain.find_children("*", "CollisionShape2D", true, false)
		_check(not collision_shapes.is_empty(), "Le terrain doit publier des formes de collision après le cratère.")
		for collision in collision_shapes:
			var shape := (collision as CollisionShape2D).shape
			_check(
				shape is ConvexPolygonShape2D and (shape as ConvexPolygonShape2D).points.size() >= 3,
				"Les contours concaves doivent être découpés en pièces convexes solides."
			)
	map.free()

	if _failures.is_empty():
		print("DESTRUCTIBLE_TERRAIN_TEST: PASS")
		quit(0)
	else:
		print("DESTRUCTIBLE_TERRAIN_TEST: FAIL (%d)" % _failures.size())
		quit(1)
