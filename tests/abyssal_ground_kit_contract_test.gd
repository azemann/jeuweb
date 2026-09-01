extends SceneTree

const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var catalog := load("res://terrain/kits/abyssal/abyssal_ground_kit.tres") as GroundKitCatalog
	_check(catalog != null, "Le catalogue Ground Kit Abysses doit être chargeable.")
	if catalog != null:
		_check(catalog.kit_id == &"abyssal", "Le kit abyssal doit garder son kit_id stable.")
		_check(catalog.validation_errors().is_empty(), "Le catalogue abyssal doit être valide : %s" % "; ".join(catalog.validation_errors()))
		var expected_ids := [
			&"abyssal_black_coral_platform_medium",
			&"abyssal_black_coral_slope_connector",
			&"abyssal_tide_engine_bridge_medium",
			&"abyssal_destructible_pearl_wall_medium",
		]
		for piece_id in expected_ids:
			var packed := catalog.scene_for(piece_id)
			_check(packed != null and packed.can_instantiate(), "Le kit abyssal doit résoudre %s." % piece_id)
			if packed == null:
				continue
			var piece := packed.instantiate() as GroundPiece2D
			_check(piece != null and piece.definition != null, "%s doit produire une GroundPiece2D configurée." % piece_id)
			if piece != null and piece.definition != null:
				_check(piece.definition.piece_id == piece_id, "%s doit conserver son piece_id Resource-first." % piece_id)
				_check(
					piece.definition.texture != null and piece.definition.texture.resource_path.begins_with("res://art/terrain/pieces/abyssal/"),
					"%s doit référencer un PNG runtime publié sous art/." % piece_id
				)
				_check(
					piece.definition.texture == null or piece.definition.texture.resource_path.find("res://" + "pipeline/") == -1,
					"%s ne doit jamais référencer le pipeline auteur." % piece_id
				)
				_check(piece.definition.collision_source == GroundPieceDefinition.CollisionSource.AUTHORED_OUTLINE, "%s doit posséder un contour auteur inspectable." % piece_id)
				_check(piece.definition.walk_surface().size() >= 2, "%s doit exposer une surface de marche auteur." % piece_id)
			if piece != null:
				piece.free()

	var wall_scene := catalog.scene_for(&"abyssal_destructible_pearl_wall_medium") if catalog != null else null
	if wall_scene != null:
		var wall := wall_scene.instantiate() as GroundPiece2D
		_check(wall.ground_mode == GroundPiece2DType.GroundMode.BREAKABLE, "Le mur nacré doit être prêt à tester en Breakable.")
		_check(wall.definition.breakable_profile != null and wall.definition.breakable_profile.is_valid(), "Le mur nacré doit posséder son profil de rupture externe.")
		wall.free()

	var definition := load("res://maps/definitions/mission_2.tres") as MissionMapDefinition
	_check(definition != null and definition.is_valid(), "La définition Mission 2 doit être valide.")
	if definition != null:
		_check(definition.map_id == &"mission_2_abyssal", "Le map_id de Mission 2 doit rester stable.")
		_check(definition.world_size == Vector2i(2560, 720), "Le premier blockout Mission 2 doit couvrir un acte de 2560 px.")

	var map_catalog := load("res://maps/definitions/mission_map_catalog.tres") as MissionMapCatalog
	_check(map_catalog != null and map_catalog.find_map(&"mission_2_abyssal") == definition, "Le catalogue de missions doit résoudre Mission 2.")

	var packed_map := load("res://maps/missions/mission2/mission_2.tscn") as PackedScene
	_check(packed_map != null and packed_map.can_instantiate(), "La scène Mission 2 doit être instanciable.")
	var map := packed_map.instantiate() as MissionMapRoot2D if packed_map != null else null
	_check(map != null, "Mission 2 doit produire un MissionMapRoot2D.")
	if map != null:
		_check(map.validation_errors().is_empty(), "Mission 2 doit respecter le contrat de carte : %s" % "; ".join(map.validation_errors()))
		_check(map.camera_bounds == Rect2(0, 0, 2560, 720), "Les limites caméra Mission 2 doivent suivre world_size.")
		_check(map.authored_segments().size() == 1, "Le blockout Mission 2 doit exposer un acte auteur.")
		_check(map.find_spawn(&"player_start") != null, "Mission 2 doit exposer un spawn joueur initial.")
		var visual_root := map.get_node_or_null("Visual") as Node2D
		var abyssal_tint := map.get_node_or_null("Visual/FarBackground/AbyssalTint") as ColorRect
		var mid_glow := map.get_node_or_null("Visual/MidGlow") as ColorRect
		_check(visual_root != null and visual_root.z_index < -10, "Le fond Mission 2 doit rester derrière le gameplay.")
		_check(abyssal_tint != null and abyssal_tint.z_index < -10 and abyssal_tint.color.a < 0.5, "L'aplat abyssal ne doit plus masquer les Ground Pieces dans l'éditeur.")
		_check(mid_glow != null and mid_glow.z_index < -10 and mid_glow.color.a < 0.35, "La lueur de blockout doit rester décorative et légère.")
		var pieces_root := map.get_node_or_null("Gameplay/GroundPieces")
		_check(pieces_root != null and pieces_root.get_child_count() == 5, "Mission 2 doit placer les cinq premières occurrences de Ground Pieces.")
		for node_name in ["EntryBlackCoral", "FirstDropSlope", "TideEngineBridge", "PearlWallGate", "ExitBlackCoral"]:
			var piece := map.get_node_or_null("Gameplay/GroundPieces/%s" % node_name) as GroundPiece2D
			_check(piece != null and piece.definition != null and piece.definition.is_valid(), "%s doit rester une Ground Piece éditable dans la scène." % node_name)
		map.free()

	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("ABYSSAL_GROUND_KIT_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("ABYSSAL_GROUND_KIT_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
