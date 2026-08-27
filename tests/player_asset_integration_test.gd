extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var frames := load("res://characters/player/data/player_visual_frames.tres") as SpriteFrames
	_check(frames != null, "La bibliothèque SpriteFrames du joueur doit être lisible.")
	for animation in [&"idle", &"move", &"jump_rise", &"fall", &"crouch", &"aim_up", &"recoil", &"hurt"]:
		_check(frames.has_animation(animation), "Pose/animation publiée absente : %s" % animation)
	if frames != null:
		_check(frames.get_frame_count(&"move") == 4, "La candidate de locomotion doit exposer quatre poses clés.")
		var texture := frames.get_frame_texture(&"idle", 0)
		_check(texture != null and texture.get_size() == Vector2(192, 192), "Chaque région joueur doit mesurer 192 × 192.")

	var player := (load("res://characters/player/player_character_2d.tscn") as PackedScene).instantiate() as PlayerCharacter2D
	_check(player.validation_errors().is_empty(), "Le remplacement visuel ne doit pas casser le contrat joueur.")
	var body_sprite := player.get_node("Presentation/SlopeVisual/BodySprite") as AnimatedSprite2D
	var weapon_sprite := player.get_node("Presentation/AimPivot/WeaponSprite") as Sprite2D
	var muzzle := player.get_node("Presentation/AimPivot/Muzzle") as Marker2D
	_check(body_sprite.sprite_frames == frames, "BodySprite doit consommer la Resource SpriteFrames publiée.")
	_check(weapon_sprite.texture != null and weapon_sprite.texture.get_size() == Vector2(768, 384), "WeaponSprite doit consommer le canon normalisé.")
	var source_muzzle := weapon_sprite.get_meta(&"source_muzzle_px", Vector2.ZERO) as Vector2
	var expected_muzzle := weapon_sprite.position + source_muzzle * weapon_sprite.scale
	_check(muzzle.position.is_equal_approx(expected_muzzle), "Muzzle doit suivre la transformation finale du canon dans la scène maîtresse.")
	player.free()

	if _failures.is_empty():
		print("PLAYER_ASSET_INTEGRATION_TEST: PASS")
		quit(0)
	else:
		print("PLAYER_ASSET_INTEGRATION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
