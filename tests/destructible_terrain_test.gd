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
	var terrain := map.get_node("DestructibleTerrain") as DestructibleTerrain2D
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
		_check(affected >= 1 and affected <= 4, "Un petit cratère doit reconstruire entre un et quatre chunks.")
		_check(terrain.collision_bitmap_build_count == 1, "Une explosion locale ne doit pas reconstruire le bitmap complet.")
	map.free()

	if _failures.is_empty():
		print("DESTRUCTIBLE_TERRAIN_TEST: PASS")
		quit(0)
	else:
		print("DESTRUCTIBLE_TERRAIN_TEST: FAIL (%d)" % _failures.size())
		quit(1)
