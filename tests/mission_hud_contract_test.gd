extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var theme_profile := load("res://ui/hud/themes/toxic_commando_hud_theme.tres") as MissionHUDTheme
	_check(theme_profile != null and theme_profile.is_valid(), "Le thème Toxic Commando doit être une Resource valide.")
	if theme_profile != null:
		_check(theme_profile.theme_id == &"toxic_commando", "Le thème HUD doit conserver son identifiant stable.")
		_check(theme_profile.player_portrait != theme_profile.health_icon, "Portrait joueur et icône de vie doivent rester deux représentations distinctes.")
		_check(theme_profile.player_portrait.get_size() == Vector2(192, 192), "Le portrait HUD doit utiliser son export normalisé 192 × 192.")

	var hud_scene := load("res://ui/hud/mission_hud.tscn") as PackedScene
	var player_scene := load("res://characters/player/player_character_2d.tscn") as PackedScene
	var hud := hud_scene.instantiate() as MissionHUD if hud_scene != null else null
	var player := player_scene.instantiate() as PlayerCharacter2D if player_scene != null else null
	_check(hud != null and player != null, "MissionHUD et PlayerCharacter2D doivent être instanciables.")
	if hud != null and player != null:
		root.add_child(player)
		root.add_child(hud)
		await process_frame
		hud.bind_player(player)
		var portrait := hud.get_node("PlayerStatus/PlayerPortrait") as TextureRect
		var health_icon := hud.get_node("PlayerStatus/HealthIcon") as TextureRect
		_check(portrait.texture == theme_profile.player_portrait, "Le grand cercle doit afficher le portrait canonique du commando.")
		_check(health_icon.texture == theme_profile.health_icon and health_icon.size.x < portrait.size.x, "Le cœur doit rester un petit repère adjacent à la barre de vie.")
		_check(hud.get_node_or_null("BossStatus/BossIcon") == null, "Le cadre Boss possède déjà son emblème et ne doit pas recevoir une icône dupliquée.")
		_check(hud.get_node_or_null("OverdriveStatus/OverdriveIcon") == null, "Le tube Overdrive possède déjà son pictogramme et ne doit pas être doublé.")
		var weapon_preview := hud.get_node("WeaponStatus/WeaponPreview") as TextureRect
		_check(weapon_preview.texture == player.weapon_component().weapon.weapon_texture, "La fenêtre arme doit consommer le bitmap de la WeaponData équipée.")
		var inventory := player.combat_inventory_component()
		var wheel := hud.get_node_or_null("WeaponWheel") as Control
		_check(wheel != null and wheel.has_method(&"open_wheel") and wheel.has_method(&"close_wheel"), "Le HUD doit exposer la roue d'armes dans son SceneTree.")
		if wheel != null:
			wheel.call(&"open_wheel")
			_check(wheel.visible, "La roue d'armes doit pouvoir s'ouvrir pour les tests d'arsenal.")
			wheel.call(&"_select_from_vector", Vector2.UP)
			wheel.call(&"close_wheel", true)
			_check(player.loadout_component().equipped_slot_index == 0, "Relâcher la roue doit équiper le segment sélectionné.")
			wheel.call(&"open_wheel")
			wheel.call(&"_select_from_vector", Vector2.RIGHT)
			wheel.call(&"close_wheel", true)
			_check(player.loadout_component().equipped_slot_index == 1, "La roue doit pouvoir équiper une arme spéciale depuis le Loadout.")
			_check(inventory.special_ammo == inventory.profile.maximum_special_ammo, "La roue de test doit remplir la réserve spéciale pour pouvoir tirer le projectile choisi.")
			_check(player.weapon_component().can_fire(), "Une arme spéciale choisie par la roue doit pouvoir tirer immédiatement son projectile.")
			inventory.consume_ammo(inventory.special_ammo - 12)
		inventory.add_armor(35.0)
		inventory.activate_overdrive(2.0)
		_check(hud.get_node("PlayerStatus/Armor").value == 35.0, "La barre d'armure doit observer CombatInventory.")
		_check(hud.get_node("OverdriveStatus").visible, "Le tube de surcharge doit apparaître uniquement pendant l'Overdrive.")
		var special_weapon := load("res://weapons/data/acid_sprayer.tres") as WeaponData
		_check(player.weapon_component().equip_weapon(special_weapon), "Une arme spéciale valide doit pouvoir être équipée.")
		_check(hud.get_node("WeaponStatus/WeaponName").text == special_weapon.display_name.to_upper(), "Le nom affiché doit suivre la WeaponData équipée.")
		_check(hud.get_node("WeaponStatus/AmmoValue").text == "12 / 40", "Le compteur doit afficher la réserve spéciale uniquement quand l'arme la consomme.")
		for weapon_path in [
			"res://weapons/data/primary_field_cannon.tres",
			"res://weapons/data/acid_sprayer.tres",
			"res://weapons/data/electric_coil_rifle.tres",
			"res://weapons/data/vacuum_imploder_cannon.tres",
			"res://weapons/data/demolition_launcher.tres",
		]:
			var arsenal_weapon := load(weapon_path) as WeaponData
			_check(arsenal_weapon != null and player.weapon_component().equip_weapon(arsenal_weapon), "%s doit être présentable par le HUD générique." % weapon_path)
			_check(weapon_preview.texture == arsenal_weapon.weapon_texture, "La fenêtre arme doit changer de bitmap pour %s." % weapon_path)
			_check(hud.get_node("WeaponStatus/WeaponName").text == arsenal_weapon.display_name.to_upper(), "Le libellé HUD doit changer pour %s." % weapon_path)
		player.queue_free()
		hud.queue_free()

	if _failures.is_empty():
		print("MISSION_HUD_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MISSION_HUD_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
