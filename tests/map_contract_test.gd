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
	var definition := load("res://maps/definitions/toxic_coast.tres") as MissionMapDefinition
	_check(definition != null and definition.is_valid(), "La définition Côte toxique doit être valide.")
	if definition != null:
		_check(definition.map_id == &"toxic_coast", "Le map_id doit rester stable.")
		_check(definition.world_size == Vector2i(3840, 720), "Côte toxique doit offrir trois écrans de progression de 1280 px.")
		_check(definition.destruction_policy == MissionMapDefinition.DestructionPolicy.AUTHORED_ZONES, "La première carte doit limiter la destruction aux zones auteur.")

	var catalog := load("res://maps/definitions/mission_map_catalog.tres") as MissionMapCatalog
	_check(catalog != null, "Le catalogue des cartes doit être chargeable.")
	if catalog != null:
		_check(catalog.validation_errors().is_empty(), "Le catalogue des cartes doit être valide.")
		_check(catalog.find_map(&"toxic_coast") == definition, "Le catalogue doit résoudre Côte toxique.")

	var packed := load("res://maps/missions/toxic_coast/toxic_coast.tscn") as PackedScene
	_check(packed != null and packed.can_instantiate(), "La scène maîtresse Côte toxique doit être instanciable.")
	var map := packed.instantiate() as MissionMapRoot2D if packed != null else null
	_check(map != null, "La scène maîtresse doit produire un MissionMapRoot2D.")
	if map != null:
		_check(map.validation_errors().is_empty(), "Contrat de carte invalide : %s" % "; ".join(map.validation_errors()))
		_check(map.find_spawn(&"player_start") != null, "Le spawn joueur initial est obligatoire.")
		_check(map.find_spawn(&"checkpoint_bridge") != null, "Le checkpoint du pont est obligatoire.")
		_check(map.find_spawn(&"checkpoint_foundry") != null, "Le checkpoint de la fonderie est obligatoire.")
		_check(map.camera_bounds == Rect2(0, 0, 3840, 720), "Les limites caméra doivent couvrir le niveau complet.")
		var segments := map.authored_segments()
		_check(segments.size() == 3, "Côte toxique doit exposer trois segments auteurs.")
		if segments.size() == 3:
			_check(segments[0].segment_id == &"landing_zone", "Le premier segment doit être la zone de débarquement.")
			_check(segments[1].segment_id == &"acid_bridge", "Le deuxième segment doit être le pont acide.")
			_check(segments[2].segment_id == &"vacuum_foundry", "Le troisième segment doit être la fonderie aspirante.")
		_check(map.find_children("*", "TileMapLayer", true, false).size() == 4, "La carte doit exposer quatre TileMapLayer auteur.")
		_check(map.get_node_or_null("Gameplay/DestructibleZones/CentralSoil") is Area2D, "La zone destructible centrale est obligatoire.")
		_check(map.get_node_or_null("Gameplay/DestructibleZones/BridgeSoil") is Area2D, "Le pont destructible est obligatoire.")
		_check(map.get_node_or_null("Gameplay/DestructibleZones/FoundrySoil") is Area2D, "Le sol destructible de la fonderie est obligatoire.")
		var ground_pieces_root := map.get_node_or_null("Gameplay/GroundPieces")
		_check(ground_pieces_root is Node2D, "Gameplay/GroundPieces doit exposer les scènes glissables.")
		var landing_ledge := map.get_node_or_null("Gameplay/GroundPieces/LandingNaturalLedge")
		_check(landing_ledge != null and landing_ledge.get_script() == GroundPiece2DType, "La corniche pilote doit être un GroundPiece2D canonique.")
		if landing_ledge != null and landing_ledge.get_script() == GroundPiece2DType:
			_check(landing_ledge.definition != null and landing_ledge.definition.piece_id == &"natural_ledge_medium", "La corniche pilote doit consommer sa définition stable.")
			_check(landing_ledge.ground_mode == GroundPiece2DType.GroundMode.CARVABLE, "La corniche pilote doit être creusable.")
		var transformed_ledge := map.get_node_or_null("Gameplay/GroundPieces/NaturalLedgeMedium")
		_check(transformed_ledge != null and transformed_ledge.get_script() == GroundPiece2DType, "La corniche transformée auteur doit rester dans la scène maîtresse.")
		if transformed_ledge != null and transformed_ledge.get_script() == GroundPiece2DType:
			_check(is_equal_approx(rad_to_deg(transformed_ledge.rotation), -35.0), "La rotation auteur de −35° doit être conservée.")
			_check(transformed_ledge.validation_errors().is_empty(), "Une rotation Carvable légale ne doit jamais invalider la carte.")
		var permanent_modules := map.find_children("*", "GroundModule2D", true, false)
		_check(permanent_modules.size() == 4, "La structure permanente doit exposer quatre modules de sol canoniques.")
		_check(map.get_node_or_null("Gameplay/IndestructibleGeometry/WorldShell") == null, "L'ancien WorldShell ne doit pas dupliquer les collisions des modules.")
		for module_node in permanent_modules:
			var ground_module := module_node as GroundModule2D
			_check(ground_module != null and ground_module.validation_errors().is_empty(), "Chaque module de sol permanent doit être valide.")
			if ground_module != null:
				_check(ground_module.fill_polygon().polygon == ground_module.collision_polygon().polygon, "Visuel et collision doivent partager le même outline autoritaire.")
		_check(map.get_node_or_null("DestructibleTerrain") is DestructibleTerrain2D, "La carte doit consommer ses zones via DestructibleTerrain2D.")
		_check(map.get_node_or_null("Actors/Projectiles") is Node2D, "La branche Actors doit exposer Projectiles.")
		var preview_actors := map.get_node_or_null("Actors/PreviewActors") as Node2D
		var toxic_pool_preview := map.get_node_or_null("Gameplay/Hazards/ToxicPool/Preview") as Polygon2D
		var runoff_preview := map.get_node_or_null("Gameplay/Hazards/FoundryRunoff/Preview") as Polygon2D
		_check(preview_actors != null and preview_actors.is_in_group(&"map_authoring_preview"), "Les silhouettes de placement doivent appartenir aux aperçus auteur.")
		_check(toxic_pool_preview != null and toxic_pool_preview.is_in_group(&"map_authoring_preview"), "L'aperçu de la fosse toxique doit rester réservé à l'éditeur.")
		_check(runoff_preview != null and runoff_preview.is_in_group(&"map_authoring_preview"), "L'aperçu du ruissellement doit rester réservé à l'éditeur.")
		root.add_child(map)
		_check(not preview_actors.visible, "Les silhouettes auteur doivent être masquées pendant le jeu.")
		_check(not toxic_pool_preview.visible and not runoff_preview.visible, "Les aperçus de danger doivent être masqués pendant le jeu.")
		var far_parallax := map.get_node_or_null("Visual/FarBackgroundParallax") as Parallax2D
		var mid_parallax := map.get_node_or_null("Visual/MidgroundParallax") as Parallax2D
		var foreground_parallax := map.get_node_or_null("Visual/ForegroundParallax") as Parallax2D
		_check(far_parallax != null and far_parallax.repeat_size.x == 1920.0, "Le fond lointain doit se répéter sans être étiré.")
		_check(mid_parallax != null and mid_parallax.repeat_size.x == 1920.0, "Le plan médian doit se répéter sans être étiré.")
		_check(foreground_parallax != null and foreground_parallax.repeat_size.x == 1920.0, "Le premier plan doit se répéter sans être étiré.")
		map.queue_free()

	var host := MissionMapHost2D.new()
	host.load_on_ready = false
	host.definition = definition
	root.add_child(host)
	var loaded := host.load_map()
	_check(loaded != null and loaded.map_id() == &"toxic_coast", "MapHost doit charger la carte demandée.")
	host.unload_map()
	_check(host.current_map == null, "MapHost doit libérer sa carte courante.")
	host.free()

	if _failures.is_empty():
		print("MAP_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MAP_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
