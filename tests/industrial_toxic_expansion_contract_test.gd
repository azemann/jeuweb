extends SceneTree

const PUBLISHED_ASSETS := [
	"res://art/terrain/pieces/toxic_coast/military/acid-bridge-abutment-v001.png",
	"res://art/terrain/pieces/toxic_coast/military/destructible-military-wall-v001.png",
	"res://art/terrain/pieces/toxic_coast/military/guard-tower-module-v001.png",
	"res://art/terrain/pieces/toxic_coast/metal/vacuum-foundry-platform-v001.png",
	"res://art/terrain/pieces/toxic_coast/pipes/walk-under-pipe-arch-v001.png",
	"res://art/props/toxic_coast/ammo-resupply-locker-v001.png",
	"res://art/props/toxic_coast/field-medical-station-v001.png",
	"res://art/props/toxic_coast/military-floodlight-v001.png",
	"res://art/props/toxic_coast/portable-barricade-v001.png",
	"res://art/props/toxic_coast/proximity-blast-mine-v001.png",
	"res://art/props/toxic_coast/radio-relay-antenna-v001.png",
	"res://art/props/toxic_coast/toxic-pressure-vent-v001.png",
	"res://art/pickups/ammo-drum-v001.png",
	"res://art/pickups/armor-plate-v001.png",
	"res://art/pickups/overdrive-vacuum-core-v001.png",
	"res://art/weapons/player/acid-sprayer-v001.png",
	"res://art/weapons/player/electric-coil-rifle-v001.png",
	"res://art/weapons/player/vacuum-imploder-cannon-v001.png",
	"res://art/weapons/player/demolition-launcher-v001.png",
	"res://art/weapons/projectiles/acid/acid-capsule-v001.png",
	"res://art/weapons/projectiles/electric/electric-coil-bolt-v001.png",
	"res://art/weapons/projectiles/implosion/vacuum-implosion-core-v001.png",
	"res://art/weapons/projectiles/rocket/demolition-rocket-v001.png",
	"res://art/effects/weapons/acid/acid-impact-3x2-v001.png",
	"res://art/effects/weapons/electric/electric-impact-3x2-v001.png",
	"res://art/effects/weapons/implosion/vacuum-implosion-impact-3x2-v001.png",
	"res://art/effects/weapons/rocket/demolition-impact-3x2-v001.png",
]
const GROUND_IDS := [
	&"acid_bridge_abutment",
	&"destructible_military_wall",
	&"guard_tower_module",
	&"vacuum_foundry_platform",
	&"walk_under_pipe_arch",
	&"portable_barricade",
]
const PICKUP_SCENES := [
	"res://pickups/ammo_drum_2d.tscn",
	"res://pickups/armor_plate_2d.tscn",
	"res://pickups/overdrive_vacuum_core_2d.tscn",
]
const ARMORY_SCENES := [
	"res://props/service_station/acid_sprayer_armory_2d.tscn",
	"res://props/service_station/electric_coil_armory_2d.tscn",
	"res://props/service_station/vacuum_imploder_armory_2d.tscn",
	"res://props/service_station/demolition_launcher_armory_2d.tscn",
]
const WORLD_PROP_SCENES := [
	"res://props/world_prop/military_floodlight_2d.tscn",
	"res://props/world_prop/radio_relay_antenna_2d.tscn",
]
const WEAPON_PATHS := [
	"res://weapons/data/acid_sprayer.tres",
	"res://weapons/data/electric_coil_rifle.tres",
	"res://weapons/data/vacuum_imploder_cannon.tres",
	"res://weapons/data/demolition_launcher.tres",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	_validate_pipeline()
	_validate_ground_kit()
	_validate_pickups()
	await _validate_loadout()
	_validate_weapons_and_armories()
	_validate_props_and_hazards()
	await process_frame
	if _failures.is_empty():
		print("INDUSTRIAL_TOXIC_EXPANSION_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("INDUSTRIAL_TOXIC_EXPANSION_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _validate_pipeline() -> void:
	_check(PUBLISHED_ASSETS.size() == 27, "Le contrat consommateur doit recenser exactement 27 assets inédits.")
	for path in PUBLISHED_ASSETS:
		_check(ResourceLoader.exists(path), "L'asset publié doit être importable : %s" % path)


func _validate_ground_kit() -> void:
	var catalog := load("res://terrain/kits/toxic_coast/toxic_coast_ground_kit.tres") as GroundKitCatalog
	_check(catalog != null and catalog.validation_errors().is_empty(), "Le Ground Kit étendu doit être valide.")
	if catalog == null:
		return
	for piece_id in GROUND_IDS:
		var scene := catalog.scene_for(piece_id)
		_check(scene != null and scene.can_instantiate(), "Le kit doit résoudre %s." % piece_id)
		if scene != null:
			var piece := scene.instantiate() as GroundPiece2D
			_check(piece != null and piece.definition != null and piece.definition.is_valid(), "%s doit produire une GroundPiece valide." % piece_id)
			piece.free()


func _validate_pickups() -> void:
	for path in PICKUP_SCENES:
		var pickup := (load(path) as PackedScene).instantiate() as Pickup2D
		_check(pickup != null and pickup.data != null and pickup.data.is_valid(), "Le pickup doit être valide : %s" % path)
		pickup.free()
	var profile := load("res://characters/player/data/standard_combat_inventory.tres") as PlayerCombatInventoryProfile
	var inventory := PlayerCombatInventoryComponent.new()
	inventory.profile = profile
	_check(inventory.add_ammo(12) and inventory.special_ammo == 12, "Le pickup munitions doit alimenter l'autorité d'inventaire.")
	_check(inventory.add_armor(30.0) and is_equal_approx(inventory.absorb_damage(45.0), 15.0), "L'armure doit absorber les dégâts avant la vie.")
	_check(inventory.activate_overdrive() and inventory.fire_interval_multiplier() < 1.0, "Le noyau Overdrive doit accélérer la cadence.")
	inventory.free()


func _validate_loadout() -> void:
	var profile := load("res://characters/player/data/standard_loadout.tres") as PlayerLoadoutProfile
	_check(profile != null and profile.is_valid(), "Le profil d'arsenal standard doit être valide.")
	if profile == null:
		return
	_check(profile.primary_weapon.weapon_id == &"primary_field_cannon", "Le canon principal doit rester l'arme primaire gratuite.")
	_check(profile.weapons().size() == 5, "L'arsenal standard doit contenir le canon et les quatre armes spéciales.")
	for path in WEAPON_PATHS:
		var weapon := load(path) as WeaponData
		_check(profile.has_weapon(weapon), "Chaque arme spéciale publiée doit être autorisée par le PlayerLoadoutProfile : %s" % path)
	var component := PlayerLoadoutComponent.new()
	component.profile = profile
	root.add_child(component)
	await process_frame
	_check(component.equipped_weapon == profile.primary_weapon, "Le Loadout doit équiper l'arme de départ au démarrage.")
	_check(component.equip_weapon(load("res://weapons/data/demolition_launcher.tres") as WeaponData), "Le Loadout doit accepter une arme publiée dans son profil.")
	var rejected := (load("res://weapons/data/primary_field_cannon.tres") as WeaponData).duplicate(true) as WeaponData
	rejected.weapon_id = &"debug_unlisted_weapon"
	_check(not component.equip_weapon(rejected), "Le Loadout doit refuser une arme absente de l'arsenal.")
	component.free()


func _validate_weapons_and_armories() -> void:
	for path in WEAPON_PATHS:
		var weapon := load(path) as WeaponData
		_check(weapon != null and weapon.is_valid(), "La WeaponData doit être valide : %s" % path)
		if weapon == null:
			continue
		_check(weapon.uses_special_ammo and weapon.weapon_texture != null, "L'arme spéciale doit déclarer coût et bitmap : %s" % path)
		var projectile := weapon.projectile_scene.instantiate() as Projectile2D
		_check(projectile != null and projectile.data != null and projectile.data.is_valid(), "Le projectile de l'arme doit être valide : %s" % path)
		_check(projectile != null and projectile.get_node_or_null("AuthorPreview") is Label, "Chaque scène projectile doit exposer AuthorPreview : %s" % path)
		if projectile != null:
			_check(projectile.author_preview_text().contains(str(projectile.data.projectile_id)), "AuthorPreview doit afficher le projectile branché : %s" % path)
		if projectile != null and projectile.data.impact_scene != null:
			var impact := projectile.data.impact_scene.instantiate()
			_check(impact is AnimatedProjectileImpact2D, "L'impact publié doit utiliser la scène animée canonique.")
			impact.free()
		projectile.free()
	for path in ARMORY_SCENES:
		var station := (load(path) as PackedScene).instantiate() as ServiceStation2D
		_check(station != null and station.data != null and station.data.is_valid(), "La station d'armurerie doit être valide : %s" % path)
		_check(station.data.service == ServiceStationData.Service.ARMORY, "La variante doit rester une armurerie Resource-driven.")
		_check(station.get_node_or_null("AuthorPreview") is Label, "La station doit exposer AuthorPreview : %s" % path)
		var preview := station.author_preview_text()
		_check(preview.contains(str(station.data.station_id)), "AuthorPreview doit afficher l'identité de station : %s" % path)
		_check(preview.contains(str(station.data.granted_weapon.weapon_id)), "AuthorPreview doit afficher l'arme accordée : %s" % path)
		station.free()


func _validate_props_and_hazards() -> void:
	for path in WORLD_PROP_SCENES:
		var prop := (load(path) as PackedScene).instantiate() as WorldProp2D
		_check(prop != null and prop.data != null and prop.data.is_valid(), "Le WorldProp doit être valide : %s" % path)
		prop.free()
	var mine := (load("res://props/proximity_mine/toxic_proximity_mine_2d.tscn") as PackedScene).instantiate() as ProximityMine2D
	_check(mine != null and mine.data != null and mine.data.is_valid(), "La mine de proximité doit être valide.")
	mine.free()
	var vent := (load("res://terrain/hazards/toxic_pressure_vent_2d.tscn") as PackedScene).instantiate() as DamageHazard2D
	_check(vent != null and vent.data != null and vent.data.is_valid(), "L'évent toxique doit être un danger valide.")
	vent.free()
