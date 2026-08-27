extends SceneTree

const GroundPieceDefinitionType = preload("res://terrain/ground_pieces/ground_piece_definition.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	image.fill_rect(Rect2i(2, 4, 12, 12), Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	var definition := GroundPieceDefinitionType.new()
	definition.piece_id = &"test_ledge"
	definition.display_name = "Test ledge"
	definition.texture = texture
	definition.pivot_px = Vector2(8, 12)
	var polygons := definition.geometry_polygons()
	_check(definition.validation_errors().is_empty(), "La définition alpha doit être valide.")
	_check(not polygons.is_empty(), "L'alpha doit produire au moins un polygone.")
	if not polygons.is_empty():
		var bounds := Rect2(polygons[0][0], Vector2.ZERO)
		for point in polygons[0]:
			bounds = bounds.expand(point)
		_check(
			bounds.position.x < 0.0 and bounds.end.x > 0.0,
			"Le pivot doit décaler le contour en espace local."
		)

	definition.collision_source = GroundPieceDefinitionType.CollisionSource.AUTHORED_OUTLINE
	definition.authored_outline = PackedVector2Array([Vector2.ZERO, Vector2.RIGHT])
	_check(
		definition.validation_errors().has("Authored Outline exige au moins trois points."),
		"Le contour auteur incomplet doit être signalé."
	)
	definition.authored_outline = PackedVector2Array([Vector2(-8, 0), Vector2(8, 0), Vector2(8, 8), Vector2(-8, 8)])
	definition.walk_surface_point_count = 2
	_check(definition.walk_surface() == PackedVector2Array([Vector2(-8, 0), Vector2(8, 0)]), "La surface de marche doit dériver des premiers points du contour unique.")
	definition.piece_id = &""
	_check(
		definition.validation_errors().has("Piece ID ne peut pas être vide."),
		"L'identifiant vide doit être signalé."
	)
	definition.piece_id = &"test_ledge"
	definition.texture = null
	_check(
		definition.validation_errors().has("Texture est obligatoire."),
		"La texture absente doit être signalée."
	)
	definition.texture = texture
	definition.collision_source = GroundPieceDefinitionType.CollisionSource.ALPHA
	definition.recommended_mode = GroundPieceDefinitionType.RecommendedMode.BREAKABLE
	definition.breakable_profile = null
	_check(
		definition.validation_errors().has(
			"Breakable Profile est obligatoire pour le mode conseillé Breakable."
		),
		"Le profil cassable absent doit être signalé."
	)

	var wrong_size_mask := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	wrong_size_mask.fill(Color.WHITE)
	definition.material_mask = ImageTexture.create_from_image(wrong_size_mask)
	_check(
		definition.validation_errors().has("Material Mask doit avoir la même taille que Texture."),
		"Un masque de mauvaise taille doit être signalé."
	)

	if _failures.is_empty():
		print("GROUND_PIECE_DEFINITION_TEST: PASS")
		quit(0)
	else:
		print("GROUND_PIECE_DEFINITION_TEST: FAIL (%d)" % _failures.size())
		quit(1)
