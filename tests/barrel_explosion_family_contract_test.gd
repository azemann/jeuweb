extends SceneTree

var _failures: Array[String] = []
const EXPLOSIVE_PROP_PATHS := [
	"res://props/explosive/data/toxic_small_explosive_barrel.tres",
	"res://props/explosive/data/toxic_standard_explosive_barrel.tres",
	"res://props/explosive/data/toxic_heavy_explosive_barrel.tres",
]


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var profiles: Array[ExplosionData] = [
		load("res://effects/explosions/data/barrel_small_explosion.tres") as ExplosionData,
		load("res://effects/explosions/data/barrel_standard_explosion.tres") as ExplosionData,
		load("res://effects/explosions/data/barrel_heavy_explosion.tres") as ExplosionData,
	]
	for profile in profiles:
		_check(profile != null and profile.is_valid(), "Chaque profil de baril doit être une ExplosionData valide.")
		if profile == null:
			continue
		_check(profile.family_id == &"barrel", "Les trois profils doivent déclarer explicitement la famille barrel.")
		_check(profile.sprite_frames != null, "Chaque profil de baril doit publier son animation peinte.")
		if profile.sprite_frames != null:
			_check(profile.sprite_frames.get_frame_count(&"detonate") == 8, "Chaque explosion de baril doit conserver huit phases chronologiques.")

	for index in range(profiles.size() - 1):
		var current := profiles[index]
		var next := profiles[index + 1]
		_check(current.terrain_radius < next.terrain_radius, "Le rayon terrain doit croître de petit à lourd.")
		_check(current.damage_radius < next.damage_radius, "Le rayon de dégâts doit croître de petit à lourd.")
		_check(current.damage < next.damage, "Les dégâts doivent croître de petit à lourd.")
		_check(current.impulse < next.impulse, "L'impulsion doit croître de petit à lourd.")
		_check(current.spark_amount < next.spark_amount, "La densité VFX doit croître de petit à lourd.")

	for index in EXPLOSIVE_PROP_PATHS.size():
		var prop_data := load(EXPLOSIVE_PROP_PATHS[index]) as ExplosivePropData
		_check(prop_data != null and prop_data.is_valid(), "Chaque définition d'objet explosif doit être valide : %s" % EXPLOSIVE_PROP_PATHS[index])
		if prop_data == null:
			continue
		_check(prop_data.explosion_data == profiles[index], "Chaque objet explosif doit choisir le palier d'explosion correspondant.")
		_check(prop_data.prop_id != prop_data.explosion_data.explosion_id, "L'ID de l'objet explosif ne doit jamais remplacer l'ID de son explosion.")

	var barrel_data := load("res://props/explosive_barrel/data/toxic_explosive_barrel.tres") as ExplosivePropData
	_check(
		barrel_data != null
		and barrel_data.explosion_data != null
		and barrel_data.explosion_data.explosion_id == &"barrel_standard"
		and barrel_data.explosion_data.family_id == &"barrel",
		"Le baril toxique actuel doit choisir le profil standard, pas celui d'une arme."
	)
	var prop_scene := load("res://props/explosive_barrel/toxic_explosive_barrel_2d.tscn") as PackedScene
	var prop := prop_scene.instantiate() as ExplosiveProp2D
	prop.data = load("res://props/explosive/data/toxic_heavy_explosive_barrel.tres") as ExplosivePropData
	root.add_child(prop)
	_check(prop.get_node_or_null("AuthorPreview") is Label, "La scène d'objet explosif doit exposer un aperçu auteur.")
	_check(prop.author_preview_text().contains("toxic_heavy_explosive_barrel"), "L'aperçu auteur doit montrer le prop_id réellement choisi.")
	_check(prop.author_preview_text().contains("barrel_heavy"), "L'aperçu auteur doit montrer l'explosion_id réellement déclenché.")
	prop.queue_free()

	var explosion_scene := load("res://effects/explosions/explosion_2d.tscn") as PackedScene
	var explosion := explosion_scene.instantiate() as Explosion2D
	explosion.data = profiles[2]
	root.add_child(explosion)
	_check(explosion.get_node_or_null("VisualScale/VisualMotion/ArtSprite") is AnimatedSprite2D, "La scène canonique doit exposer l'animation peinte dans le SceneTree.")
	_check(explosion.get_node_or_null("VisualScale/ShockwaveRoot/ShockwavePrimary") is Sprite2D, "La première onde de choc doit rester visible dans le SceneTree.")
	_check(explosion.get_node_or_null("VisualScale/ShockwaveRoot/ShockwaveSecondary") is Sprite2D, "La seconde onde de choc doit rester visible dans le SceneTree.")
	_check(explosion.get_node_or_null("VisualScale/Sparks") is GPUParticles2D, "Les étincelles doivent être un composant VFX explicite.")
	_check(explosion.get_node_or_null("VisualScale/Debris") is GPUParticles2D, "Les débris doivent être un composant VFX explicite.")
	_check(explosion.get_node_or_null("VisualScale/ToxicDroplets") is GPUParticles2D, "Les gouttes toxiques doivent être un composant VFX explicite.")
	_check(explosion.find_child("Camera2D", true, false) == null, "Une explosion ne doit jamais posséder ni déplacer la caméra.")
	explosion.free()

	if _failures.is_empty():
		print("BARREL_EXPLOSION_FAMILY_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("BARREL_EXPLOSION_FAMILY_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
