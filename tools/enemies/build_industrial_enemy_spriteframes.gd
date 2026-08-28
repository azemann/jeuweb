extends SceneTree

const ROSTER := {
	&"vacuum_grunt": ["res://art/enemies/industrial_toxic/vacuum-grunt-animation-4x4-v001.png", Vector2i(320, 256)],
	&"vacuum_flying": ["res://art/enemies/industrial_toxic/vacuum-flying-animation-4x4-v001.png", Vector2i(256, 256)],
	&"vacuum_boss": ["res://art/enemies/industrial_toxic/vacuum-boss-animation-4x4-v001.png", Vector2i(384, 320)],
	&"vacuum_pilot_saboteur": ["res://art/enemies/industrial_toxic/vacuum-pilot-saboteur-animation-4x4-v001.png", Vector2i(192, 192)],
}


func _initialize() -> void:
	for archetype_id: StringName in ROSTER:
		build_frames(archetype_id, ROSTER[archetype_id][0], ROSTER[archetype_id][1])
	quit(0)


func build_frames(archetype_id: StringName, texture_path: String, frame_size: Vector2i) -> void:
	var atlas := load(texture_path) as Texture2D
	if atlas == null:
		push_error("Atlas ennemi introuvable : %s" % texture_path)
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	add_animation(frames, atlas, frame_size, &"walk", 0, true, 7.142857, [1.0, 1.0, 1.0, 1.0])
	add_animation(frames, atlas, frame_size, &"attack", 1, false, 10.0, [1.7, 2.1, 1.5, 2.4])
	add_animation(frames, atlas, frame_size, &"hit", 2, false, 10.0, [0.9, 1.1, 1.3, 1.7])
	add_animation(frames, atlas, frame_size, &"death", 3, false, 10.0, [1.6, 1.9, 2.4, 5.2])
	var directory := "res://characters/enemies/%s" % archetype_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var error := ResourceSaver.save(frames, "%s/%s_frames.tres" % [directory, archetype_id])
	if error != OK:
		push_error("Échec SpriteFrames %s : %s" % [archetype_id, error_string(error)])
		quit(1)


func add_animation(frames: SpriteFrames, atlas: Texture2D, frame_size: Vector2i, animation: StringName, row: int, looped: bool, speed: float, durations: Array) -> void:
	frames.add_animation(animation)
	frames.set_animation_loop(animation, looped)
	frames.set_animation_speed(animation, speed)
	for column in 4:
		var texture := AtlasTexture.new()
		texture.atlas = atlas
		texture.region = Rect2(Vector2(column * frame_size.x, row * frame_size.y), Vector2(frame_size))
		frames.add_frame(animation, texture, durations[column])
