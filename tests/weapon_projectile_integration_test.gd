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
	_validate_field_round_published_assets(projectile_data)
	_validate_demolition_rocket_explosion()
	await _check_animated_projectile_presentation()
	await _check_optional_explosion_binding(projectile_data)
	await _check_freed_shooter_reference(projectile_data)

	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame
	var viewport_root := screen.get_node("MissionViewportContainer/MissionViewport")
	var actor_spawner := viewport_root.get_node("RuntimeSystems/ActorSpawner") as MissionActorSpawner2D
	var projectile_spawner := viewport_root.get_node("RuntimeSystems/ProjectileSpawner") as MissionProjectileSpawner2D
	var encounter_controller := viewport_root.get_node("RuntimeSystems/EncounterController") as MissionEncounterController
	encounter_controller.set_physics_process(false)
	var player := actor_spawner.current_player
	for actor in actor_spawner.map_host().current_map.actors_root().get_children():
		if actor is EnemyCharacter2D:
			actor.queue_free()
	for projectile in projectile_spawner.projectile_root().get_children():
		if projectile is Projectile2D:
			projectile.queue_free()
	await process_frame
	_check(player != null, "Le joueur runtime doit être disponible pour tester le tir.")
	_check(projectile_spawner != null and projectile_spawner.projectile_root() != null, "Le spawner doit résoudre Runtime/Projectiles.")
	if player != null and projectile_spawner != null:
		for _frame in 90:
			await physics_frame
		var weapon := player.weapon_component()
		var recoil := player.recoil_component()
		var camera_rig := viewport_root.get_node("MissionCameraRig") as MissionCameraRig2D
		var aim_pivot := player.get_node("Visuals/AimPivot") as Node2D
		var body_pivot := player.get_node("Visuals/GroundPivot") as Node2D
		var muzzle := player.get_node("Visuals/AimPivot/Muzzle") as Marker2D
		_check(weapon != null and weapon.validation_errors().is_empty(), "Le composant Weapon du joueur doit être valide.")
		_check(recoil != null and recoil.validation_errors().is_empty(), "Le composant Recoil du joueur doit être valide.")
		var spawned: Array[Projectile2D] = []
		projectile_spawner.projectile_spawned.connect(func(projectile: Projectile2D) -> void: spawned.append(projectile))
		player.aim_component().set_aim_direction(Vector2.RIGHT)
		var muzzle_position := muzzle.global_position
		var body_origin := body_pivot.position
		var aim_origin := aim_pivot.position
		var camera_progression_before_fire := camera_rig.global_position
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
		_check(recoil.get_node("RecoilAnimationPlayer").current_animation == &"recoil", "Un tir accepté doit jouer la courbe de recul.")
		_check(is_zero_approx(weapon.weapon.camera_shake_strength), "Le canon automatique doit garder la caméra stable.")
		_check(is_zero_approx(camera_rig.shake_remaining()), "Le canon automatique ne doit demander aucune secousse caméra.")
		_check(not weapon.fire_once(), "Le cooldown doit bloquer un second tir immédiat.")
		_check(spawned.size() == 1, "Une demande doit produire exactement un projectile.")
		if spawned.size() == 1:
			var projectile := spawned[0]
			var observations := {"impacts": 0}
			projectile.impacted.connect(func(_target: Node, _damage: float) -> void: observations.impacts += 1)
			_check(projectile.get_parent() == projectile_spawner.projectile_root(), "Le projectile doit être indépendant du joueur sous Runtime/Projectiles.")
			_check(projectile.global_position.is_equal_approx(muzzle_position), "Le projectile doit naître au Marker2D Muzzle.")
			_check(projectile.direction.is_equal_approx(Vector2.RIGHT), "Le projectile doit suivre la visée du joueur.")
			var initial_x := projectile.global_position.x
			await physics_frame
			_check(is_instance_valid(projectile) and projectile.global_position.x > initial_x, "Le projectile doit progresser indépendamment vers la droite.")
			await create_timer(0.02).timeout
			_check(body_pivot.position != body_origin and aim_pivot.position != aim_origin, "Le recul doit déplacer ensemble corps et canon hors de leur origine auteur.")
			_check(camera_rig.camera.offset.is_zero_approx(), "Le tir automatique doit conserver un offset caméra nul.")
			_check(camera_rig.global_position.is_equal_approx(camera_progression_before_fire), "Le tir ne doit pas modifier l'autorité de progression du CameraRig.")
			for _frame in 12:
				await physics_frame
			_check(body_pivot.position.is_equal_approx(body_origin) and aim_pivot.position.is_equal_approx(aim_origin), "La fin de Recoil doit restaurer exactement les positions auteur.")
			_check(camera_rig.camera.offset.is_zero_approx(), "La caméra doit rester stable pendant toute la rafale.")
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


func _check_optional_explosion_binding(base_data: ProjectileData) -> void:
	var incomplete_data := base_data.duplicate(true) as ProjectileData
	incomplete_data.explosion_scene = load("res://effects/explosions/explosion_2d.tscn") as PackedScene
	incomplete_data.explosion_data = null
	_check(not incomplete_data.is_valid(), "ProjectileData doit refuser une scène d'explosion sans ExplosionData.")

	var explosive_data := base_data.duplicate(true) as ProjectileData
	explosive_data.projectile_id = &"explosive_contract_probe"
	explosive_data.damage = 0.0
	explosive_data.affects_destructible_terrain = false
	explosive_data.explosion_scene = load("res://effects/explosions/explosion_2d.tscn") as PackedScene
	explosive_data.explosion_data = load("res://effects/explosions/data/field_shell_explosion.tres") as ExplosionData
	_check(explosive_data.has_explosion() and explosive_data.is_valid(), "ProjectileData doit accepter une correspondance d'explosion optionnelle valide.")

	var projectile := (load("res://weapons/projectiles/field_round_2d.tscn") as PackedScene).instantiate() as Projectile2D
	projectile.data = explosive_data
	projectile.position = Vector2(420.0, 260.0)
	projectile.rotation = deg_to_rad(-18.0)
	root.add_child(projectile)
	var expected_position := projectile.global_position
	projectile.call(&"_resolve_impact", null)
	var explosion := root.get_node_or_null("Explosion2D") as Explosion2D
	_check(explosion != null, "Une munition explosive doit instancier Explosion2D à l'impact.")
	if explosion != null:
		_check(explosion.data == explosive_data.explosion_data, "La munition doit injecter son style ExplosionData.")
		_check(explosion.global_position.is_equal_approx(expected_position), "L'explosion d'une munition doit naître au point d'impact mondial.")
		explosion.queue_free()
	await process_frame


func _validate_field_round_published_assets(projectile_data: ProjectileData) -> void:
	if projectile_data == null:
		return
	_check(projectile_data.texture != null, "Le canon de campagne doit consommer un bitmap de projectile publié.")
	if projectile_data.texture != null:
		_check(projectile_data.texture.resource_path == "res://art/weapons/projectiles/field/field-round-v001.png", "Le projectile du canon doit pointer vers l'asset runtime field.")
	var impact := projectile_data.impact_scene.instantiate() if projectile_data.impact_scene != null else null
	_check(impact is AnimatedProjectileImpact2D, "L'impact du canon de campagne doit utiliser la scène animée canonique.")
	if impact != null:
		var visuals := impact.get_node_or_null("Visuals") as AnimatedSprite2D
		_check(visuals != null and visuals.scale.x <= 0.5 and visuals.scale.y <= 0.5, "L'impact du canon de base doit rester compact et ne pas lire comme une explosion lourde.")
		impact.free()
	var projectile := (load("res://weapons/projectiles/field_round_2d.tscn") as PackedScene).instantiate() as Projectile2D
	_check(projectile != null and projectile.get_node_or_null("AuthorPreview") is Label, "La scène projectile doit exposer AuthorPreview aux auteurs.")
	if projectile != null:
		var preview := projectile.author_preview_text()
		_check(preview.contains("field_round") and preview.contains("field_round_impact_2d"), "AuthorPreview doit afficher projectile et impact branchés.")
		projectile.free()


func _validate_demolition_rocket_explosion() -> void:
	var rocket := load("res://weapons/projectiles/data/demolition_rocket.tres") as ProjectileData
	_check(rocket != null and rocket.is_valid(), "La roquette de démolition doit rester une ProjectileData valide.")
	if rocket == null or rocket.explosion_data == null:
		return
	_check(rocket.explosion_data.explosion_id == &"demolition_rocket_burst", "La roquette doit utiliser son ExplosionData de munition dédiée.")
	_check(rocket.explosion_data.family_id == &"munition_demolition", "L'explosion de roquette ne doit pas appartenir aux familles baril ou obus de campagne.")


func _check_animated_projectile_presentation() -> void:
	var projectile := (load("res://weapons/projectiles/toxic_pressure_2d.tscn") as PackedScene).instantiate() as Projectile2D
	root.add_child(projectile)
	await process_frame
	var animated_visual := projectile.get_node_or_null("Visual") as AnimatedSprite2D
	_check(animated_visual != null and animated_visual.is_playing(), "Un projectile animé doit conserver sa présentation sans exiger le Sprite2D bitmap optionnel.")
	_check(projectile.visual == null, "La présentation bitmap optionnelle ne doit pas usurper l'AnimatedSprite2D toxique.")
	projectile.free()


func _check_freed_shooter_reference(projectile_data: ProjectileData) -> void:
	var projectile := (load("res://weapons/projectiles/field_round_2d.tscn") as PackedScene).instantiate() as Projectile2D
	projectile.data = projectile_data
	root.add_child(projectile)
	var temporary_shooter := CharacterBody2D.new()
	root.add_child(temporary_shooter)
	projectile.launch(Vector2.RIGHT, temporary_shooter)
	temporary_shooter.free()
	var exclusions := projectile.call(&"_ray_exclusions") as Array[RID]
	_check(exclusions.size() == 1, "Un projectile doit oublier sans erreur un tireur déjà libéré.")
	_check(not projectile.call(&"_belongs_to_shooter", root), "Un tireur libéré ne doit correspondre à aucun collider.")
	projectile.free()
