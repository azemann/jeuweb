extends SceneTree

const GroundPieceDefinitionType = preload("res://terrain/ground_pieces/ground_piece_definition.gd")
const GroundBreakableProfileType = preload("res://terrain/ground_pieces/ground_breakable_profile.gd")
const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

var _failures: Array[String] = []
var _break_count := 0


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _opaque_texture(color: Color) -> ImageTexture:
	var image := Image.create(32, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	image.fill_rect(Rect2i(2, 2, 28, 22), color)
	return ImageTexture.create_from_image(image)


func _run() -> void:
	var packed := load("res://terrain/ground_pieces/ground_piece_2d.tscn") as PackedScene
	_check(packed != null and packed.can_instantiate(), "La scène GroundPiece2D doit être instanciable.")
	if packed == null:
		_finish()
		return
	var piece := packed.instantiate()
	var profile := GroundBreakableProfileType.new()
	profile.maximum_health = 40.0
	profile.remove_collision_when_broken = true
	var definition := GroundPieceDefinitionType.new()
	definition.piece_id = &"mode_test_piece"
	definition.display_name = "Mode test piece"
	definition.texture = _opaque_texture(Color("6b7d32"))
	definition.damaged_texture = _opaque_texture(Color("594b2d"))
	definition.destroyed_texture = _opaque_texture(Color("3a3028"))
	definition.pivot_px = Vector2(16, 12)
	definition.breakable_profile = profile
	piece.definition = definition
	root.add_child(piece)

	piece.ground_mode = GroundPiece2DType.GroundMode.PERMANENT
	piece.sync_from_authority()
	_check(piece.is_permanent_collision_active(), "Permanent doit activer sa collision.")
	_check(not piece.is_carvable_stamp_active(), "Permanent ne doit pas produire de stamp.")
	_check(not piece.is_breakable_active(), "Permanent ne doit pas activer la vie cassable.")

	piece.ground_mode = GroundPiece2DType.GroundMode.CARVABLE
	piece.sync_from_authority()
	_check(not piece.is_permanent_collision_active(), "Carvable interdit la double collision locale.")
	_check(piece.is_carvable_stamp_active(), "Carvable doit exposer son stamp.")
	_check(not piece.is_breakable_active(), "Carvable ne doit pas activer la vie cassable.")

	piece.ground_mode = GroundPiece2DType.GroundMode.BREAKABLE
	piece.sync_from_authority()
	_check(piece.is_permanent_collision_active(), "Breakable conserve une collision locale avant destruction.")
	_check(not piece.is_carvable_stamp_active(), "Breakable ne doit pas contaminer le masque global.")
	_check(piece.is_breakable_active(), "Breakable doit activer son composant de vie.")
	piece.piece_broken.connect(func() -> void: _break_count += 1)
	_check(piece.apply_damage(30.0), "Les dégâts non létaux doivent être acceptés.")
	_check(piece.presentation_sprite().texture == definition.damaged_texture, "Le seuil de vie doit afficher la variante endommagée.")
	_check(piece.apply_damage(10.0), "Les dégâts létaux doivent être acceptés.")
	_check(_break_count == 1, "La rupture doit être émise exactement une fois.")
	_check(not piece.is_permanent_collision_active(), "La collision doit disparaître après rupture.")
	_check(piece.presentation_sprite().texture == definition.destroyed_texture, "La variante détruite doit devenir visible.")
	_check(not piece.apply_damage(1.0), "Une pièce déjà détruite doit refuser les dégâts.")
	_check(_break_count == 1, "La rupture ne doit jamais être réémise.")

	piece.free()
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("GROUND_PIECE_MODES_TEST: PASS")
		quit(0)
	else:
		print("GROUND_PIECE_MODES_TEST: FAIL (%d)" % _failures.size())
		quit(1)
