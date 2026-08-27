extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var weapon_data := load("res://weapons/data/primary_field_cannon.tres") as WeaponData
	var projectile_data := load("res://weapons/projectiles/data/field_round.tres") as ProjectileData
	_check(weapon_data != null and weapon_data.is_valid(), "Le canon doit consommer une WeaponData valide.")
	_check(projectile_data != null and projectile_data.is_valid(), "La munition doit consommer une ProjectileData valide.")

	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame
	var viewport_root := screen.get_node("MissionViewportContainer/MissionViewport")
	var actor_spawner := viewport_root.get_node("ActorSpawner") as MissionActorSpawner2D
	var projectile_spawner := viewport_root.get_node("ProjectileSpawner") as MissionProjectileSpawner2D
	var player := actor_spawner.current_player
	_check(player != null, "Le joueur runtime doit être disponible pour tester le tir.")
	_check(projectile_spawner != null and projectile_spawner.projectile_root() != null, "Le spawner doit résoudre Actors/Projectiles.")
	if player != null and projectile_spawner != null:
		for _frame in 90:
			await physics_frame
		var weapon := player.weapon_component()
		var aim_pivot := player.get_node("Presentation/AimPivot") as Node2D
		var muzzle := player.get_node("Presentation/AimPivot/Muzzle") as Marker2D
		_check(weapon != null and weapon.validation_errors().is_empty(), "Le composant Weapon du joueur doit être valide.")
		var spawned: Array[Projectile2D] = []
		projectile_spawner.projectile_spawned.connect(func(projectile: Projectile2D) -> void: spawned.append(projectile))
		player.aim_component().set_aim_direction(Vector2.RIGHT)
		var muzzle_position := muzzle.global_position
		var collision_target := StaticBody2D.new()
		collision_target.collision_layer = 1
		collision_target.collision_mask = 0
		var target_shape := CollisionShape2D.new()
		var target_rectangle := RectangleShape2D.new()
		target_rectangle.size = Vector2(20, 120)
		target_shape.shape = target_rectangle
		collision_target.add_child(target_shape)
		projectile_spawner.projectile_root().add_child(collision_target)
		collision_target.global_position = muzzle_position + Vector2(180, 0)
		_check(weapon.fire_once(), "Le premier appui doit déclencher un tir.")
		_check(not weapon.fire_once(), "Le cooldown doit bloquer un second tir immédiat.")
		_check(spawned.size() == 1, "Une demande doit produire exactement un projectile.")
		if spawned.size() == 1:
			var projectile := spawned[0]
			var observations := {"impacts": 0}
			projectile.impacted.connect(func(_target: Node, _damage: float) -> void: observations.impacts += 1)
			_check(projectile.get_parent() == projectile_spawner.projectile_root(), "Le projectile doit être indépendant du joueur sous Actors/Projectiles.")
			_check(projectile.global_position.is_equal_approx(muzzle_position), "Le projectile doit naître au Marker2D Muzzle.")
			_check(projectile.direction.is_equal_approx(Vector2.RIGHT), "Le projectile doit suivre la visée du joueur.")
			var initial_x := projectile.global_position.x
			await physics_frame
			_check(is_instance_valid(projectile) and projectile.global_position.x > initial_x, "Le projectile doit progresser indépendamment vers la droite.")
			for _frame in 12:
				await physics_frame
			_check(observations.impacts == 1, "Le projectile doit détecter un obstacle World et produire un impact.")

		for _frame in 4:
			await physics_frame
		player.aim_component().set_aim_direction(Vector2.DOWN)
		_check(weapon.fire_once(), "Le canon doit pouvoir retirer après son intervalle auteur.")
		var downward: Projectile2D = spawned.back() as Projectile2D
		_check(downward.direction.is_equal_approx(Vector2.DOWN), "Le tir doit également suivre une visée verticale.")

		for _frame in 12:
			await physics_frame
		player.aim_component().set_aim_direction(Vector2.RIGHT)
		var muzzle_blocker := StaticBody2D.new()
		muzzle_blocker.collision_layer = 1
		muzzle_blocker.collision_mask = 0
		var blocker_shape := CollisionShape2D.new()
		var blocker_rectangle := RectangleShape2D.new()
		blocker_rectangle.size = Vector2(8, 80)
		blocker_shape.shape = blocker_rectangle
		muzzle_blocker.add_child(blocker_shape)
		projectile_spawner.projectile_root().add_child(muzzle_blocker)
		muzzle_blocker.global_position = aim_pivot.global_position.lerp(muzzle.global_position, 0.45)
		await physics_frame
		var blocked_impact := {"position": Vector2.INF}
		var before_blocked_count := spawned.size()
		projectile_spawner.projectile_spawned.connect(func(projectile: Projectile2D) -> void:
			if spawned.size() > before_blocked_count:
				projectile.impacted.connect(func(_target: Node, _damage: float) -> void:
					blocked_impact.position = projectile.global_position
				)
		)
		_check(weapon.fire_once(), "Le tir à bout portant doit être accepté par l'arme.")
		_check(blocked_impact.position != Vector2.INF, "Un obstacle entre la base du canon et le Muzzle doit recevoir l'impact immédiatement.")
		if blocked_impact.position != Vector2.INF:
			_check(
				blocked_impact.position.x < muzzle.global_position.x - 20.0,
				"L'impact à bout portant doit rester devant la paroi, jamais naître au milieu du terrain."
			)

	screen.free()
	if _failures.is_empty():
		print("WEAPON_PROJECTILE_INTEGRATION_TEST: PASS")
		quit(0)
	else:
		print("WEAPON_PROJECTILE_INTEGRATION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
