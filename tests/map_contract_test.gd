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
		_check(definition.world_size == Vector2i(7680, 720), "Côte toxique doit offrir trois actes de progression de 2560 px.")
		_check(definition.destruction_policy == MissionMapDefinition.DestructionPolicy.AUTHORED_ZONES, "La première carte doit limiter la destruction aux zones auteur.")
		_check(definition.hud_theme != null and definition.hud_theme.theme_id == &"toxic_commando", "La définition de mission doit choisir son thème HUD sans le coder dans l'écran.")

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
		_check(map.runtime_root() != null and map.actors_root() != null and map.projectiles_root() != null and map.effects_root() != null, "Runtime doit séparer Actors, Projectiles et Effects.")
		_check(map.actors_root().get_parent() == map.runtime_root() and map.projectiles_root().get_parent() == map.runtime_root(), "Les conteneurs runtime doivent être enfants directs de Runtime.")
		_check(map.player_spawn_points_root() != null and map.encounter_markers_root() != null, "Gameplay doit exposer PlayerSpawnPoints et EncounterMarkers.")
		_check(map.get_node_or_null("Gameplay/CombatGates") == null, "Le mode Flux Libre ne doit contenir aucune branche CombatGates.")
		_check(map.get_node_or_null("Gameplay/SpawnPoints") == null and map.get_node_or_null("Gameplay/EnemySpawns") == null and map.get_node_or_null("Gameplay/Encounters") == null, "Les anciennes branches ambiguës ne doivent plus exister.")
		_check(map.get_node_or_null("Actors") == null and map.get_node_or_null("DestructibleTerrain") == null, "Les instances runtime ne doivent plus être mélangées aux branches auteur de la racine.")
		_check(map.find_spawn(&"player_start") != null, "Le spawn joueur initial est obligatoire.")
		_check(map.find_spawn(&"checkpoint_bridge") != null, "Le checkpoint du pont est obligatoire.")
		_check(map.find_spawn(&"checkpoint_foundry") != null, "Le checkpoint de la fonderie est obligatoire.")
		var landing_marker := map.get_node_or_null("Gameplay/EncounterMarkers/LandingCadence") as MapEncounterMarker2D
		var bridge_marker := map.get_node_or_null("Gameplay/EncounterMarkers/BridgeGauntlet") as MapEncounterMarker2D
		var boss_marker := map.get_node_or_null("Gameplay/EncounterMarkers/FoundryBossGate") as MapEncounterMarker2D
		_check(map.encounter_markers_root().get_child_count() == 3, "La partition doit exposer exactement ses trois actes canoniques, sans déclencheur parasite.")
		for marker in [landing_marker, bridge_marker, boss_marker]:
			_check(marker != null and marker.enabled and marker.encounter_data != null and marker.encounter_data.validation_errors().is_empty(), "Chaque rencontre canonique de Côte toxique doit rester activée et structurellement valide.")
		_check(landing_marker != null and landing_marker.encounter_data.authored_enemy_count() == 3 and landing_marker.position.x - landing_marker.activation_distance > 470.0, "Landing doit commencer après la caisse et composer deux Troopers puis un Grunt.")
		_check(bridge_marker != null and bridge_marker.encounter_data.encounter_kind == EncounterData.EncounterKind.GAUNTLET and bridge_marker.encounter_data.authored_enemy_count() == 6 and bridge_marker.position.x - bridge_marker.activation_distance > 2560.0, "Le Pont doit déclencher dans son acte un Gauntlet de six ennemis.")
		_check(boss_marker != null and boss_marker.encounter_data.encounter_kind == EncounterData.EncounterKind.ARENA and boss_marker.encounter_data.authored_enemy_count() == 4 and boss_marker.position.x - boss_marker.activation_distance > 5120.0, "La Fonderie doit conserver une finale Arena sans porte physique.")
		_check(landing_marker != null and not landing_marker.encounter_data.blocks_mission_exit, "Landing doit rester facultatif pour la victoire.")
		_check(bridge_marker != null and not bridge_marker.encounter_data.blocks_mission_exit, "Le Pont doit rester facultatif pour la victoire.")
		_check(boss_marker != null and boss_marker.encounter_data.blocks_mission_exit, "La finale Boss doit être le seul objectif obligatoire.")
		_check(map.camera_bounds == Rect2(0, 0, 7680, 720), "Les limites caméra doivent couvrir le niveau complet.")
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
		_check(map.destructible_terrain() is DestructibleTerrain2D, "La carte doit exposer Runtime/DestructibleTerrain.")
		var bridge_checkpoint := map.get_node_or_null("Gameplay/Interactions/BridgeCheckpoint") as MissionCheckpoint2D
		var foundry_checkpoint := map.get_node_or_null("Gameplay/Interactions/FoundryCheckpoint") as MissionCheckpoint2D
		_check(bridge_checkpoint != null and bridge_checkpoint.spawn_id == &"checkpoint_bridge", "Le checkpoint du pont doit correspondre à son spawn auteur.")
		_check(foundry_checkpoint != null and foundry_checkpoint.spawn_id == &"checkpoint_foundry", "Le checkpoint de la fonderie doit correspondre à son spawn auteur.")
		_check(map.get_node_or_null("Gameplay/Exits/MissionEnd") is Marker2D, "La sortie auteur MissionEnd est obligatoire.")
		var bridge_barrel := map.get_node_or_null("Gameplay/Interactions/BridgeExplosiveBarrel") as ExplosiveProp2D
		var foundry_barrel := map.get_node_or_null("Gameplay/Interactions/FoundryExplosiveBarrel") as ExplosiveProp2D
		_check(bridge_barrel != null and bridge_barrel.data != null and bridge_barrel.data.is_valid(), "Le Pont doit offrir un baril explosif valide pendant sa pression terrestre.")
		_check(foundry_barrel != null and foundry_barrel.data != null and foundry_barrel.data.is_valid(), "La Fonderie doit réemployer le baril comme opportunité de maîtrise.")
		if bridge_barrel != null and bridge_barrel.data != null and foundry_barrel != null and foundry_barrel.data != null:
			_check(bridge_barrel.data.prop_id == &"toxic_standard_explosive_barrel", "Le Pont doit choisir une définition d'objet explosif standard.")
			_check(bridge_barrel.data.explosion_data.explosion_id == &"barrel_standard", "Le Pont doit déclencher l'explosion standard.")
			_check(foundry_barrel.data.prop_id == &"toxic_heavy_explosive_barrel", "La Fonderie doit choisir une définition d'objet explosif lourd.")
			_check(foundry_barrel.data.explosion_data.explosion_id == &"barrel_heavy", "La Fonderie doit déclencher l'explosion lourde.")
		for node_name in ["LandingGuardTower", "LandingPipeArch", "BridgeWestAbutment", "FoundryWestPlatform", "FoundryBreakableWall"]:
			var architecture_piece := map.get_node_or_null("Gameplay/GroundPieces/%s" % node_name) as GroundPiece2D
			_check(architecture_piece != null and architecture_piece.definition != null and architecture_piece.definition.is_valid(), "%s doit intégrer une Ground Piece inédite valide." % node_name)
		for node_name in ["LandingMedicalStation", "BridgeAmmoLocker", "LandingAcidArmory", "BridgeElectricArmory", "FoundryImploderArmory", "FoundryDemolitionArmory"]:
			var station := map.get_node_or_null("Gameplay/Interactions/%s" % node_name) as ServiceStation2D
			_check(station != null and station.data != null and station.data.is_valid(), "%s doit exposer sa configuration Inspector." % node_name)
		_check(map.get_node_or_null("Gameplay/Interactions/LandingFloodlight") is WorldProp2D, "Le projecteur militaire doit baliser l'acte 1.")
		_check(map.get_node_or_null("Gameplay/Interactions/FoundryRadioRelay") is WorldProp2D, "Le relais radio doit servir de landmark final.")
		_check(map.get_node_or_null("Gameplay/Interactions/BridgeMine") is ProximityMine2D, "La mine doit enrichir la traversée du pont.")
		_check(map.get_node_or_null("Gameplay/Hazards/BridgePressureVent") is DamageHazard2D, "L'évent toxique doit enrichir le pont.")
		_check(map.get_node_or_null("Gameplay/Interactions/BridgeAmmoPickup") is Pickup2D, "Le pickup munitions doit être placé dans l'acte 2.")
		_check(map.get_node_or_null("Gameplay/Interactions/FoundryArmorPickup") is Pickup2D, "Le pickup armure doit préparer la fonderie.")
		_check(map.get_node_or_null("Gameplay/Interactions/FoundryOverdrivePickup") is Pickup2D, "Le noyau Overdrive doit soutenir le climax.")
		_check(map.projectiles_root() is Node2D, "La branche Runtime doit exposer Projectiles.")
		var editor_preview := map.editor_preview_root()
		var preview_actors := map.get_node_or_null("EditorPreview/EnemySilhouettes") as Node2D
		var toxic_pool_preview := map.get_node_or_null("Gameplay/Hazards/ToxicPool/Preview") as Polygon2D
		var runoff_preview := map.get_node_or_null("Gameplay/Hazards/FoundryRunoff/Preview") as Polygon2D
		_check(editor_preview != null and editor_preview.is_in_group(&"map_authoring_preview") and preview_actors != null, "Les silhouettes de placement doivent appartenir à EditorPreview.")
		_check(toxic_pool_preview != null and toxic_pool_preview.is_in_group(&"map_authoring_preview"), "L'aperçu de la fosse toxique doit rester réservé à l'éditeur.")
		_check(runoff_preview != null and runoff_preview.is_in_group(&"map_authoring_preview"), "L'aperçu du ruissellement doit rester réservé à l'éditeur.")
		root.add_child(map)
		var terrain := map.destructible_terrain() as DestructibleTerrain2D
		_check(terrain.performance_budget_errors().is_empty(), "Le terrain initial doit respecter les budgets physiques du profil : %s" % "; ".join(terrain.performance_budget_errors()))
		_check(terrain.collision_shape_count() <= terrain.profile.maximum_collision_shapes, "Le budget de formes physiques doit être vérifiable automatiquement.")
		_check(not editor_preview.visible and not preview_actors.is_visible_in_tree(), "EditorPreview et ses silhouettes doivent être masqués pendant le jeu.")
		_check(not toxic_pool_preview.visible and not runoff_preview.visible, "Les aperçus de danger doivent être masqués pendant le jeu.")
		var background_root := map.get_node_or_null("Visual/SegmentBackgrounds") as Node2D
		_check(background_root != null and background_root.get_child_count() == 5, "Les trois backgrounds et leurs deux transitions doivent rester explicites.")
		var background_expectations := {
			"LandingZoneBackground": Vector2(1280, 360),
			"AcidBridgeBackground": Vector2(3840, 360),
			"VacuumFoundryBackground": Vector2(6400, 360),
		}
		for background_name in background_expectations:
			var background := background_root.get_node_or_null(background_name) as Sprite2D
			_check(background != null and background.texture != null, "%s doit consommer son bitmap publié." % background_name)
			if background != null and background.texture != null:
				_check(background.position == background_expectations[background_name], "%s doit être centré sur son acte de 2560 px." % background_name)
				_check(background.texture.get_size() == Vector2(2560, 720), "%s doit couvrir son acte sans répétition ni étirement." % background_name)
		var transition_expectations := {
			"LandingToBridgeTransition": Vector2(2560, 360),
			"BridgeToFoundryTransition": Vector2(5120, 360),
		}
		for transition_name in transition_expectations:
			var transition := background_root.get_node_or_null(transition_name) as Sprite2D
			_check(transition != null and transition.texture != null, "%s doit couvrir la frontière entre deux actes." % transition_name)
			if transition != null and transition.texture != null:
				_check(transition.position == transition_expectations[transition_name], "%s doit être centrée sur la frontière auteur." % transition_name)
				_check(transition.texture.get_size() == Vector2(384, 720), "%s doit conserver sa largeur de raccord pipeline." % transition_name)
		var parallax_layers := map.find_children("*", "Parallax2D", true, false)
		_check(parallax_layers.size() == 2, "Deux parallaxes décoratifs doivent compléter sans remplacer les backgrounds segmentés.")
		_check(map.get_node_or_null("Visual/MidgroundParallax/IndustrialJungle") is Sprite2D, "Le midground transparent historique doit enrichir la profondeur.")
		_check(map.get_node_or_null("Visual/ForegroundParallax/EdgeFraming") is Sprite2D, "Le foreground transparent historique doit cadrer le plan proche.")
		_check(map.get_node_or_null("Visual/EnvironmentFX").get_child_count() == 3, "Les trois actes doivent exposer leurs effets environnementaux.")
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

	var marker_parent := Node2D.new()
	var original_marker := MapEncounterMarker2D.new()
	original_marker.name = "LandingCadence"
	original_marker.encounter_id = &"landing_cadence"
	marker_parent.add_child(original_marker)
	var duplicated_marker := MapEncounterMarker2D.new()
	duplicated_marker.name = "LandingCadence2"
	duplicated_marker.encounter_id = &"landing_cadence"
	marker_parent.add_child(duplicated_marker)
	var duplicate_warning := "Encounter ID 'landing_cadence' est déjà utilisé par LandingCadence. Utiliser « Générer un Encounter ID unique » après une duplication."
	_check(duplicated_marker._get_configuration_warnings().has(duplicate_warning), "Un Marker dupliqué doit signaler immédiatement son Encounter ID partagé dans l'éditeur.")
	duplicated_marker.editor_generate_unique_id()
	_check(duplicated_marker.encounter_id == &"landing_cadence_2", "L'action auteur doit dériver un Encounter ID unique depuis le nom du Marker.")
	marker_parent.free()

	if _failures.is_empty():
		print("MAP_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("MAP_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
