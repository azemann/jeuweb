extends SceneTree

var _failures: Array[String] = []
var _ejected_pilot: EnemyCharacter2D

const INDUSTRIAL_ROSTER := [
	&"vacuum_grunt",
	&"vacuum_flying",
	&"vacuum_boss",
	&"vacuum_pilot_saboteur",
]


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var profile := load("res://characters/enemies/data/vacuum_trooper_profile.tres") as EnemyArchetypeProfile
	_check(profile != null and profile.is_valid(), "Le profil Vacuum Trooper doit être valide.")
	_check(profile.archetype_id == &"vacuum_trooper", "L'identité d'archétype doit rester stable.")

	var catalog := load("res://characters/enemies/data/enemy_catalog.tres") as EnemyCatalog
	_check(catalog != null and catalog.validation_errors().is_empty(), "Le catalogue ennemi doit être valide.")
	_check(catalog.find_scene(&"vacuum_trooper") != null, "Le catalogue doit résoudre Vacuum Trooper.")
	for archetype_id: StringName in INDUSTRIAL_ROSTER:
		var roster_scene := catalog.find_scene(archetype_id) if catalog != null else null
		_check(roster_scene != null, "Le catalogue doit résoudre %s." % archetype_id)
		var roster_enemy := roster_scene.instantiate() as EnemyCharacter2D if roster_scene != null else null
		_check(roster_enemy != null, "%s doit produire un EnemyCharacter2D." % archetype_id)
		if roster_enemy != null:
			_check(roster_enemy.profile.archetype_id == archetype_id, "La scène %s doit consommer son profil autoritaire." % archetype_id)
			_check(roster_enemy.validation_errors().is_empty(), "La scène %s doit respecter l'arbre canonique : %s" % [archetype_id, "; ".join(roster_enemy.validation_errors())])
			var roster_frames := (roster_enemy.get_node_or_null("Presentation/SlopeVisual/BodySprite") as AnimatedSprite2D)
			if roster_frames == null:
				roster_frames = roster_enemy.get_node_or_null("Presentation/BodySprite") as AnimatedSprite2D
			_check(roster_frames != null, "%s doit exposer son AnimatedSprite2D." % archetype_id)
			if roster_frames != null:
				for animation in [&"walk", &"attack", &"hit", &"death"]:
					_check(roster_frames.sprite_frames.has_animation(animation) and roster_frames.sprite_frames.get_frame_count(animation) == 4, "%s/%s doit publier quatre poses." % [archetype_id, animation])
					var roster_texture := roster_frames.sprite_frames.get_frame_texture(animation, 0) as AtlasTexture
					_check(roster_texture != null and roster_texture.atlas.resource_path.ends_with("-v002.png"), "%s/%s doit consommer l'atlas ennemi v002 publié." % [archetype_id, animation])
			roster_enemy.free()

	var frames := load("res://characters/enemies/vacuum_trooper/vacuum_trooper_frames.tres") as SpriteFrames
	_check(frames != null and frames.has_animation(&"walk"), "La marche Vacuum Trooper doit être publiée.")
	if frames != null and frames.has_animation(&"walk"):
		_check(frames.get_frame_count(&"walk") == 8, "La marche doit contenir huit poses.")
		_check(is_equal_approx(frames.get_animation_speed(&"walk"), 6.25), "La cadence doit rester à 160 ms par pose.")
		var walk_texture := frames.get_frame_texture(&"walk", 0) as AtlasTexture
		_check(walk_texture != null and walk_texture.atlas.resource_path.ends_with("-v002.png"), "La marche Vacuum Trooper doit consommer l'atlas v002 publié.")
	_check(frames != null and frames.has_animation(&"hit"), "L'impact Vacuum Trooper doit être publié.")
	_check(frames != null and frames.has_animation(&"death"), "La mort Vacuum Trooper doit être publiée.")
	if frames != null and frames.has_animation(&"hit") and frames.has_animation(&"death"):
		_check(frames.get_frame_count(&"hit") == 4 and not frames.get_animation_loop(&"hit"), "L'impact doit contenir quatre poses non bouclées.")
		_check(frames.get_frame_count(&"death") == 4 and not frames.get_animation_loop(&"death"), "La mort doit contenir quatre poses non bouclées.")
		var hit_durations := [0.9, 0.8, 1.3, 1.6]
		var death_durations := [1.2, 1.6, 2.2, 6.0]
		for index in 4:
			_check(is_equal_approx(frames.get_frame_duration(&"hit", index), hit_durations[index]), "Le timing relatif d'impact doit rester autoritaire dans SpriteFrames.")
			_check(is_equal_approx(frames.get_frame_duration(&"death", index), death_durations[index]), "Le timing relatif de mort doit rester autoritaire dans SpriteFrames.")
		var hit_texture := frames.get_frame_texture(&"hit", 0) as AtlasTexture
		_check(hit_texture != null and hit_texture.atlas.resource_path.ends_with("-v002.png"), "Les réactions Vacuum Trooper doivent consommer l'atlas v002 publié.")

	var attack_frames := load("res://characters/enemies/vacuum_trooper/vacuum_trooper_attack_frames.tres") as SpriteFrames
	_check(attack_frames != null and attack_frames.has_animation(&"toxic_attack") and attack_frames.get_frame_count(&"toxic_attack") == 8, "L'attaque Vacuum Trooper doit conserver ses huit poses.")
	if attack_frames != null and attack_frames.has_animation(&"toxic_attack"):
		var attack_texture := attack_frames.get_frame_texture(&"toxic_attack", 0) as AtlasTexture
		_check(attack_texture != null and attack_texture.atlas.resource_path.ends_with("-v002.png"), "L'attaque Vacuum Trooper doit consommer l'atlas v002 publié.")

	var enemy_scene := catalog.find_scene(&"vacuum_trooper") if catalog != null else null
	var enemy := enemy_scene.instantiate() as EnemyCharacter2D if enemy_scene != null else null
	_check(enemy != null, "La scène Vacuum Trooper doit produire un EnemyCharacter2D.")
	if enemy != null:
		_check(enemy.validation_errors().is_empty(), "L'arbre canonique de l'ennemi doit être valide.")
		root.add_child(enemy)
		await process_frame
		_check(enemy.health_component().current_health == profile.maximum_health, "Health doit initialiser les PV depuis le profil.")
		_check(enemy.apply_damage(10.0), "Le projectile doit pouvoir transmettre des dégâts à l'ennemi.")
		_check(enemy.health_component().current_health == profile.maximum_health - 10.0, "Health doit rester l'autorité des PV courants.")
		enemy.queue_free()
		await process_frame

	var reaction_enemy := enemy_scene.instantiate() as EnemyCharacter2D if enemy_scene != null else null
	_check(reaction_enemy != null, "Le scénario de réaction doit être instanciable.")
	if reaction_enemy != null:
		root.add_child(reaction_enemy)
		await process_frame
		_check(reaction_enemy.apply_damage(10.0), "Un dégât non létal doit être accepté.")
		_check(reaction_enemy.get_node("Presentation/SlopeVisual/BodySprite").animation == &"hit", "Un dégât accepté doit jouer hit immédiatement.")
		_check(not reaction_enemy.patrol_component().movement_enabled, "La patrouille doit se suspendre pendant hit.")
		await create_timer(0.55).timeout
		_check(reaction_enemy.get_node("Presentation/SlopeVisual/BodySprite").animation == &"walk", "La marche doit reprendre après hit.")
		_check(reaction_enemy.patrol_component().movement_enabled, "La patrouille doit reprendre après hit.")
		reaction_enemy.queue_free()
		await process_frame

	var dying_enemy := enemy_scene.instantiate() as EnemyCharacter2D if enemy_scene != null else null
	_check(dying_enemy != null, "Le scénario de mort doit être instanciable.")
	if dying_enemy != null:
		root.add_child(dying_enemy)
		var ejection := dying_enemy.get_node("Components/Ejection") as EnemyEjectionComponent
		ejection.ejected.connect(_on_pilot_ejected)
		await process_frame
		_check(dying_enemy.apply_damage(profile.maximum_health), "Un dégât létal doit être accepté.")
		_check(is_instance_valid(dying_enemy) and not dying_enemy.is_queued_for_deletion(), "La mort ne doit plus supprimer l'ennemi immédiatement.")
		_check(dying_enemy.get_node("Presentation/SlopeVisual/BodySprite").animation == &"death", "Zéro PV doit jouer death.")
		_check(dying_enemy.collision_layer == 0, "Une coque mourante ne doit plus recevoir de projectiles.")
		_check(not dying_enemy.patrol_component().movement_enabled, "La patrouille doit rester suspendue pendant death.")
		await create_timer(0.75).timeout
		_check(_ejected_pilot != null and _ejected_pilot.profile.archetype_id == &"vacuum_pilot_saboteur", "La mort du Trooper doit éjecter la scène canonique du Saboteur.")
		await create_timer(0.45).timeout
		_check(not is_instance_valid(dying_enemy), "L'ennemi doit être supprimé seulement après la dernière pose de mort.")
		if is_instance_valid(_ejected_pilot):
			_ejected_pilot.queue_free()

	var projectile_scene := load("res://weapons/projectiles/field_round_2d.tscn") as PackedScene
	var target := enemy_scene.instantiate() as EnemyCharacter2D if enemy_scene != null else null
	var projectile := projectile_scene.instantiate() as Projectile2D if projectile_scene != null else null
	_check(target != null and projectile != null, "Le scénario projectile vers ennemi doit être instanciable.")
	if target != null and projectile != null:
		root.add_child(target)
		target.global_position = Vector2(180, 100)
		target.patrol_component().set_physics_process(false)
		root.add_child(projectile)
		projectile.global_position = Vector2(0, 73)
		var health_before_projectile := target.health_component().current_health
		projectile.launch(Vector2.RIGHT)
		for _frame in 20:
			await physics_frame
		_check(target.health_component().current_health < health_before_projectile, "Un vrai FieldRound2D doit retirer des PV au Vacuum Trooper.")
		target.queue_free()
		if is_instance_valid(projectile):
			projectile.queue_free()
		await process_frame

	var boss_scene := catalog.find_scene(&"vacuum_boss") if catalog != null else null
	var boss_target := boss_scene.instantiate() as EnemyCharacter2D if boss_scene != null else null
	var boss_projectile := projectile_scene.instantiate() as Projectile2D if projectile_scene != null else null
	_check(boss_target != null and boss_projectile != null, "Le scénario FieldRound vers Boss doit être instanciable.")
	if boss_target != null and boss_projectile != null:
		root.add_child(boss_target)
		boss_target.global_position = Vector2(220, 220)
		boss_target.patrol_component().set_physics_process(false)
		_check(boss_target.collision_layer == 0 and boss_target.hurtbox() != null and boss_target.hurtbox().collision_layer == 4, "La Hurtbox doit être l'unique autorité de réception étendue du Boss.")
		root.add_child(boss_projectile)
		boss_projectile.global_position = Vector2(0, 50)
		var boss_health_before := boss_target.health_component().current_health
		var boss_projectile_damage := boss_projectile.data.damage
		boss_projectile.launch(Vector2.RIGHT)
		for _frame in 24:
			await physics_frame
		_check(boss_target.health_component().current_health == boss_health_before - boss_projectile_damage, "Un FieldRound visant le bord visible supérieur doit toucher la Hurtbox du Boss et retirer ses dégâts.")
		boss_target.queue_free()
		if is_instance_valid(boss_projectile):
			boss_projectile.queue_free()
		await process_frame

	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	await process_frame
	await physics_frame
	await physics_frame
	var viewport := screen.get_node("MissionViewportContainer/MissionViewport")
	var host := viewport.get_node("MapHost") as MissionMapHost2D
	var enemy_spawner := viewport.get_node("EnemySpawner") as MissionEnemySpawner2D
	_check(host.current_map != null, "La mission doit charger Côte toxique.")
	_check(enemy_spawner.catalog == catalog, "L'écran doit exposer le catalogue ennemi dans l'Inspector.")
	if host.current_map != null:
		var marker := host.current_map.get_node("Gameplay/EnemySpawns/LandingCadence") as MapEncounterMarker2D
		var first_pattern := marker.encounter_data.waves[0].spawn_patterns[0]
		_check(first_pattern.spawn_count() == 2 and marker.global_position.x < 1280.0, "La première pression doit demander deux Troopers dans le premier écran.")
		await create_timer(0.35).timeout
		var runtime_enemies := host.current_map.get_node("Actors").find_children("landing_cadence_*", "EnemyCharacter2D", true, false)
		_check(runtime_enemies.size() == 2, "La première pression doit générer exactement deux Troopers avant la vague Release.")
		var actual_origins: Array[float] = []
		for runtime_enemy in runtime_enemies:
			_check(runtime_enemy.get_parent() == host.current_map.actors_root(), "Chaque ennemi runtime doit appartenir à Actors.")
			_check(runtime_enemy.global_position.x < 1280.0, "La première patrouille doit rester dans les 1280 premiers pixels.")
			actual_origins.append(runtime_enemy.patrol_component().origin_x)
		actual_origins.sort()
		var offsets := first_pattern.authored_offsets()
		for index in offsets.size():
			var expected_origin := marker.global_position.x + offsets[index].x
			_check(is_equal_approx(actual_origins[index], expected_origin), "Patrol doit dériver son origine du marqueur et de son espacement auteur.")
	screen.free()

	if _failures.is_empty():
		print("ENEMY_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("ENEMY_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _on_pilot_ejected(pilot: EnemyCharacter2D) -> void:
	_ejected_pilot = pilot
