extends SceneTree

const GroundKitCatalogType = preload("res://terrain/ground_pieces/ground_kit_catalog.gd")
const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var catalog := load("res://terrain/kits/toxic_coast/toxic_coast_ground_kit.tres")
	_check(catalog != null, "Le catalogue Côte toxique doit être chargeable.")
	if catalog == null:
		_finish()
		return
	_check(catalog.validation_errors().is_empty(), "Le catalogue publié doit être valide.")
	var packed: PackedScene = catalog.scene_for(&"natural_ledge_medium")
	_check(packed != null and packed.can_instantiate(), "Le catalogue doit résoudre natural_ledge_medium.")
	if packed != null:
		var piece := packed.instantiate()
		_check(piece.get_script() == GroundPiece2DType, "La scène du kit doit produire la scène canonique GroundPiece2D.")
		_check(piece.definition != null, "La scène glissable doit référencer sa définition.")
		if piece.definition != null:
			_check(piece.definition.piece_id == &"natural_ledge_medium", "Le piece_id publié doit rester stable.")
			_check(
				piece.definition.texture.resource_path == "res://art/terrain/pieces/toxic_coast/natural/natural-ledge-medium-v001.png",
				"La définition doit référencer uniquement le bitmap runtime publié."
			)
			_check(piece.definition.pivot_px == Vector2(384, 64), "Le pivot de surface publié doit être conservé.")
			_check(piece.definition.damaged_texture != null, "La corniche doit publier son état visuel endommagé.")
			_check(piece.definition.destroyed_texture != null, "La corniche doit publier son état visuel détruit.")
			_check(piece.definition.breakable_profile != null, "La corniche doit pouvoir être passée en mode Breakable depuis l'Inspector.")
			if piece.definition.breakable_profile != null:
				_check(piece.definition.breakable_profile.is_valid(), "Le profil Breakable publié doit être valide.")
				_check(
					piece.definition.breakable_profile.resource_path == "res://terrain/kits/toxic_coast/breakables/natural_ledge_breakable.tres",
					"La résistance partagée doit rester une Resource externe retrouvable."
				)
				if not piece.definition.breakable_profile.remove_after_break:
					_check(piece.definition.destroyed_texture != null, "Conserver une ruine exige une variante détruite.")
		_check(piece.ground_mode == GroundPiece2DType.GroundMode.CARVABLE, "La scène naturelle doit conseiller Carvable.")
		piece.free()

	var duplicate_catalog := GroundKitCatalogType.new()
	duplicate_catalog.kit_id = &"duplicate_test"
	duplicate_catalog.display_name = "Duplicate test"
	duplicate_catalog.pieces = [packed, packed]
	_check(
		duplicate_catalog.validation_errors().has("piece_id 'natural_ledge_medium' est dupliqué dans le kit."),
		"Le catalogue doit refuser deux scènes portant le même piece_id."
	)
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("GROUND_KIT_CATALOG_TEST: PASS")
		quit(0)
	else:
		print("GROUND_KIT_CATALOG_TEST: FAIL (%d)" % _failures.size())
		quit(1)
