extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var player := (load("res://characters/player/player_character_2d.tscn") as PackedScene).instantiate() as PlayerCharacter2D
	var crate := (load("res://props/supply_crate/military_supply_crate_2d.tscn") as PackedScene).instantiate() as SupplyCrate2D
	root.add_child(player)
	root.add_child(crate)
	crate.position = Vector2(50, 0)
	crate.scale = Vector2(0.45, 0.45)
	await create_timer(0.05).timeout

	var interaction := player.interaction_component()
	var prompt := player.get_node("InteractionPrompt") as Label
	_check(interaction != null and interaction.validation_errors().is_empty(), "Le joueur doit exposer une Interaction valide.")
	_check(interaction.current_target == crate.get_node("InteractionArea"), "La zone joueur doit sélectionner la caisse proche.")
	_check(prompt.visible, "Une cible valide doit afficher le prompt auteur.")

	var health := player.health_component()
	_check(player.apply_damage(50.0), "Le joueur doit perdre des PV avant le soin.")
	var health_before_pickup := health.current_health
	_check(interaction.try_interact(), "La commande du joueur doit ouvrir la caisse proche.")
	_check(crate.is_open(), "La cible doit confirmer son ouverture.")
	var pickup := crate.spawned_content() as Pickup2D
	_check(pickup != null and pickup.data != null and pickup.data.is_valid(), "La caisse doit publier un PickupData valide.")
	if pickup != null:
		_check(pickup.global_scale.is_equal_approx(Vector2.ONE), "Le pickup ne doit pas hériter de l'échelle auteur de la caisse.")
		_check(pickup.collect(player), "Le pickup de soin doit être accepté par un joueur blessé.")
		_check(is_equal_approx(health.current_health, health_before_pickup + pickup.data.amount), "PickupData.amount doit être l'unique quantité de soin.")
	_check(not prompt.visible, "Une caisse ouverte ne doit plus rester proposée à l'interaction.")

	crate.queue_free()
	player.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PICKUP_INTERACTION_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("PICKUP_INTERACTION_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
