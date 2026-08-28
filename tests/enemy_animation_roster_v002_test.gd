extends SceneTree

var _failures: Array[String] = []

const INDUSTRIAL_FRAMES := {
	&"vacuum_grunt": "res://characters/enemies/vacuum_grunt/vacuum_grunt_frames.tres",
	&"vacuum_flying": "res://characters/enemies/vacuum_flying/vacuum_flying_frames.tres",
	&"vacuum_boss": "res://characters/enemies/vacuum_boss/vacuum_boss_frames.tres",
	&"vacuum_pilot_saboteur": "res://characters/enemies/vacuum_pilot_saboteur/vacuum_pilot_saboteur_frames.tres",
}

const INDUSTRIAL_ATLAS_SIZES := {
	&"vacuum_grunt": Vector2i(1280, 1024),
	&"vacuum_flying": Vector2i(1024, 1024),
	&"vacuum_boss": Vector2i(1536, 1280),
	&"vacuum_pilot_saboteur": Vector2i(768, 768),
}


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _check_v002_texture(frames: SpriteFrames, animation: StringName, message: String) -> void:
	var texture := frames.get_frame_texture(animation, 0) as AtlasTexture
	_check(texture != null and texture.atlas.resource_path.ends_with("-v002.png"), message)


func _run() -> void:
	for archetype_id: StringName in INDUSTRIAL_FRAMES:
		var frames := load(INDUSTRIAL_FRAMES[archetype_id]) as SpriteFrames
		_check(frames != null, "%s doit charger ses SpriteFrames." % archetype_id)
		if frames == null:
			continue
		for animation in [&"walk", &"attack", &"hit", &"death"]:
			_check(frames.has_animation(animation), "%s/%s doit exister." % [archetype_id, animation])
			if not frames.has_animation(animation):
				continue
			_check(frames.get_frame_count(animation) == 4, "%s/%s doit publier quatre poses." % [archetype_id, animation])
			_check_v002_texture(frames, animation, "%s/%s doit consommer l'atlas v002." % [archetype_id, animation])
			var texture := frames.get_frame_texture(animation, 0) as AtlasTexture
			if texture != null:
				_check(Vector2i(texture.atlas.get_size()) == INDUSTRIAL_ATLAS_SIZES[archetype_id], "%s doit conserver les dimensions d'atlas attendues par ses régions." % archetype_id)

	var trooper_frames := load("res://characters/enemies/vacuum_trooper/vacuum_trooper_frames.tres") as SpriteFrames
	_check(trooper_frames != null, "Vacuum Trooper doit charger ses SpriteFrames locomotion/réactions.")
	if trooper_frames != null:
		_check(trooper_frames.get_frame_count(&"walk") == 8, "Vacuum Trooper/walk doit conserver huit poses.")
		_check(trooper_frames.get_frame_count(&"hit") == 4, "Vacuum Trooper/hit doit conserver quatre poses.")
		_check(trooper_frames.get_frame_count(&"death") == 4, "Vacuum Trooper/death doit conserver quatre poses.")
		for animation in [&"walk", &"hit", &"death"]:
			_check_v002_texture(trooper_frames, animation, "Vacuum Trooper/%s doit consommer l'atlas v002." % animation)
			var texture := trooper_frames.get_frame_texture(animation, 0) as AtlasTexture
			if texture != null:
				_check(Vector2i(texture.atlas.get_size()) == Vector2i(1024, 384), "Les atlas Vacuum Trooper doivent rester compatibles avec leurs régions 256×192.")

	var attack_frames := load("res://characters/enemies/vacuum_trooper/vacuum_trooper_attack_frames.tres") as SpriteFrames
	_check(attack_frames != null and attack_frames.get_frame_count(&"toxic_attack") == 8, "Vacuum Trooper/toxic_attack doit publier huit poses.")
	if attack_frames != null and attack_frames.has_animation(&"toxic_attack"):
		_check_v002_texture(attack_frames, &"toxic_attack", "Vacuum Trooper/toxic_attack doit consommer l'atlas v002.")
		var attack_texture := attack_frames.get_frame_texture(&"toxic_attack", 0) as AtlasTexture
		if attack_texture != null:
			_check(Vector2i(attack_texture.atlas.get_size()) == Vector2i(1024, 384), "L'atlas toxic_attack doit rester compatible avec ses régions 256×192.")

	if _failures.is_empty():
		print("ENEMY_ANIMATION_ROSTER_V002_TEST: PASS")
		quit(0)
	else:
		print("ENEMY_ANIMATION_ROSTER_V002_TEST: FAIL (%d)" % _failures.size())
		quit(1)
