extends SceneTree

const DestructibleTerrainType = preload("res://terrain/destructible_terrain_2d.gd")
const DestructibleTerrainProfileType = preload("res://terrain/destructible_terrain_profile.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	await _check_isolated_chunk_alignment()
	await _check_toxic_coast_muzzle_alignment()
	_finish()


func _check_isolated_chunk_alignment() -> void:
	var map := Node2D.new()
	var gameplay := Node2D.new()
	gameplay.name = "Gameplay"
	map.add_child(gameplay)
	var zones := Node2D.new()
	zones.name = "DestructibleZones"
	gameplay.add_child(zones)
	var zone := Area2D.new()
	zone.position = Vector2(160, 360)
	zones.add_child(zone)
	var shape_node := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(64, 64)
	shape_node.shape = rectangle
	zone.add_child(shape_node)

	var profile := DestructibleTerrainProfileType.new()
	profile.world_size = Vector2i(1280, 720)
	profile.chunk_size = 128
	profile.minimum_polygon_area = 1.0
	var terrain := DestructibleTerrainType.new()
	terrain.name = "DestructibleTerrain"
	terrain.profile = profile
	terrain.authored_zones_path = NodePath("../Gameplay/DestructibleZones")
	terrain.ground_pieces_path = NodePath()
	map.add_child(terrain)
	root.add_child(map)
	await physics_frame
	await physics_frame

	_check(terrain.is_solid_at(Vector2(128, 360)), "Le bord gauche du masque doit être solide à x=128.")
	var query := PhysicsRayQueryParameters2D.create(Vector2(0, 360), Vector2(300, 360), 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := terrain.get_world_2d().direct_space_state.intersect_ray(query)
	_check(not hit.is_empty(), "Le rayon doit rencontrer la collision du terrain Carvable.")
	if not hit.is_empty():
		var hit_x := (hit.get(&"position") as Vector2).x
		_check(
			absf(hit_x - 128.0) <= 2.0,
			"La collision doit commencer au bord visuel x=128, pas au milieu (impact x=%.2f)." % hit_x
		)

	map.free()


func _check_toxic_coast_muzzle_alignment() -> void:
	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	for _frame in 90:
		await physics_frame
	var viewport_root := screen.get_node("MissionViewportContainer/MissionViewport")
	var actor_spawner := viewport_root.get_node("RuntimeSystems/ActorSpawner") as MissionActorSpawner2D
	var map_host := viewport_root.get_node("MapHost") as MissionMapHost2D
	var player := actor_spawner.current_player
	var map := map_host.current_map
	var terrain := map.destructible_terrain()
	var muzzle := player.get_node("Visuals/AimPivot/Muzzle") as Marker2D
	player.aim_component().set_aim_direction(Vector2.RIGHT)
	var start := muzzle.global_position
	var expected_x := -1.0
	for x in range(ceili(start.x), mini(terrain.profile.world_size.x, ceili(start.x + 1800.0))):
		if terrain.is_solid_at(Vector2(x, start.y)):
			expected_x = float(x)
			break
	var query := PhysicsRayQueryParameters2D.create(start, start + Vector2(1800, 0), 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := terrain.get_world_2d().direct_space_state.intersect_ray(query)
	if expected_x >= 0.0:
		_check(not hit.is_empty(), "Une matière visible devant le canon doit posséder une collision World.")
	if expected_x >= 0.0 and not hit.is_empty():
		var hit_position := hit.get(&"position") as Vector2
		_check(
			absf(hit_position.x - expected_x) <= 3.0,
			"L'impact réel doit suivre le premier pixel solide : masque x=%.2f, collision x=%.2f, tir y=%.2f."
			% [expected_x, hit_position.x, start.y]
		)
	screen.free()


func _finish() -> void:
	if _failures.is_empty():
		print("DESTRUCTIBLE_TERRAIN_COLLISION_ALIGNMENT_TEST: PASS")
		quit(0)
	else:
		print("DESTRUCTIBLE_TERRAIN_COLLISION_ALIGNMENT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
