extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var player_scene := load("res://characters/player/player_character_2d.tscn") as PackedScene
	_check(player_scene != null, "La scène canonique PlayerCharacter2D doit être lisible.")
	var player := player_scene.instantiate() as PlayerCharacter2D
	_check(player != null, "La scène joueur doit produire un PlayerCharacter2D.")
	if player != null:
		_check(player.validation_errors().is_empty(), "Le contrat structurel du joueur doit être valide.")
		_check(player.movement_component().profile.is_valid(), "Le panneau de mouvement doit être valide.")
		_check(player.aim_component().profile.is_valid(), "Le panneau de visée doit être valide.")
		_check(player.health_component().profile.is_valid(), "Le panneau de santé doit être valide.")
		_check(player.weapon_component().weapon.is_valid(), "Le panneau d'arme doit être valide.")
		_check(player.get_node_or_null("Components/Loadout") is PlayerLoadoutComponent, "Components/Loadout doit rendre l'arsenal visible dans le SceneTree.")
		_check(player.loadout_component().validation_errors().is_empty(), "Components/Loadout doit posséder un profil d'arsenal valide.")
		_check(player.loadout_component().available_weapons().size() == 5, "Le profil d'arsenal standard doit exposer les cinq WeaponData jouables.")
		_check(player.get_node_or_null("Components/Animation") is PlayerPresentationComponent, "Components/Animation doit piloter les animations du joueur.")
		_check(player.get_node_or_null("Components/Recoil") is PlayerRecoilComponent, "Components/Recoil doit rendre le recul visible dans le SceneTree.")
		_check(player.recoil_component().validation_errors().is_empty(), "Components/Recoil doit posséder des correspondances valides.")
		_check(player.get_node_or_null("Components/Interaction") is PlayerInteractionComponent, "Components/Interaction doit rendre l'action visible dans le SceneTree.")
		_check(player.interaction_component().validation_errors().is_empty(), "Components/Interaction doit posséder zone et prompt valides.")
		_check(player.get_node_or_null("Visuals/GroundPivot") is Node2D, "Visuals/GroundPivot doit isoler l'inclinaison visuelle du joueur.")
		_check(player.get_node_or_null("Presentation") == null and player.get_node_or_null("Components/Presentation") == null, "L'ancien doublon Presentation ne doit plus exister.")
		_check(player.get_node_or_null("Visuals/AimPivot/Muzzle") is Marker2D, "Visuals doit exposer un Muzzle.")
		_check(player.get_node_or_null("AnimationPlayer") is AnimationPlayer, "Le timing visuel doit appartenir à AnimationPlayer.")
		player.free()

	for action in [&"player_move_left", &"player_move_right", &"player_jump", &"player_aim_left", &"player_aim_right", &"player_aim_up", &"player_aim_down", &"player_fire"]:
		_check(InputMap.has_action(action), "Action Input Map absente : %s" % action)

	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	await process_frame
	await process_frame
	var host := screen.get_node("MissionViewportContainer/MissionViewport/MapHost") as MissionMapHost2D
	var runtime_systems := screen.get_node("MissionViewportContainer/MissionViewport/RuntimeSystems")
	var spawner := screen.get_node("MissionViewportContainer/MissionViewport/RuntimeSystems/ActorSpawner") as MissionActorSpawner2D
	_check(runtime_systems != null and runtime_systems.get_child_count() == 5, "RuntimeSystems doit regrouper les cinq services de mission.")
	_check(host.current_map != null, "L'écran de mission doit charger sa carte.")
	_check(spawner.current_player != null, "ActorSpawner doit créer le joueur depuis le spawn auteur.")
	var hud := screen.get_node("MissionHUD") as MissionHUD
	_check(hud != null and hud.theme_profile != null and hud.theme_profile.is_valid(), "L'écran doit instancier un MissionHUD profilé.")
	_check(hud.get_node("PlayerStatus/Health").value == 100.0, "Le HUD doit refléter le HealthComponent du joueur.")
	_check(hud.get_node("PlayerStatus/PlayerPortrait").texture == hud.theme_profile.player_portrait, "Le grand cercle doit contenir le portrait du joueur, jamais l'icône de vie.")
	_check(hud.get_node("WeaponStatus/WeaponPreview").texture == spawner.current_player.weapon_component().weapon.weapon_texture, "La fenêtre arme doit présenter la WeaponData équipée.")
	_check(not screen.get_node("BackButton").visible, "Le bouton Retour ne doit pas encombrer le gameplay.")
	if host.current_map != null and spawner.current_player != null:
		_check(spawner.current_player.get_parent() == host.current_map.actors_root(), "Le joueur runtime doit appartenir à la branche Actors de la carte.")
		_check(spawner.current_player.name == "RuntimePlayer", "L'instance runtime doit être identifiable dans le SceneTree.")
		_check(host.current_map.projectiles_root() is Node2D, "La carte doit exposer Runtime/Projectiles.")
		for _frame in 90:
			await physics_frame
		_check(spawner.current_player.is_on_floor(), "Le joueur doit atterrir sur la géométrie de la carte.")
		var initial_x := spawner.current_player.global_position.x
		Input.action_press(&"player_move_right", 1.0)
		for _frame in 10:
			await physics_frame
		Input.action_release(&"player_move_right")
		_check(spawner.current_player.global_position.x > initial_x + 1.0, "Le composant Movement doit déplacer le CharacterBody2D.")
		for _frame in 4:
			await physics_frame
		Input.action_press(&"player_jump", 1.0)
		await physics_frame
		Input.action_release(&"player_jump")
		await physics_frame
		_check(spawner.current_player.velocity.y < 0.0, "Le saut doit appliquer une vitesse verticale ascendante.")
	screen.free()

	if _failures.is_empty():
		print("PLAYER_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("PLAYER_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
