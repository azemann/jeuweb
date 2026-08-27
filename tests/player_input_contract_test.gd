extends SceneTree

const ACTIONS := [
	&"player_move_left",
	&"player_move_right",
	&"player_jump",
	&"player_aim_left",
	&"player_aim_right",
	&"player_aim_up",
	&"player_aim_down",
	&"player_fire",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	for action in ACTIONS:
		_check(InputMap.has_action(action), "Action Input Map absente : %s" % action)

	_check(_has_event_type(&"player_move_left", InputEventKey), "Le déplacement doit conserver une liaison clavier.")
	_check(_has_joy_motion(&"player_move_left", JOY_AXIS_LEFT_X, -1.0), "Le stick gauche doit déplacer vers la gauche.")
	_check(_has_joy_button(&"player_move_left", JOY_BUTTON_DPAD_LEFT), "La croix directionnelle doit déplacer vers la gauche.")
	_check(_has_joy_motion(&"player_move_right", JOY_AXIS_LEFT_X, 1.0), "Le stick gauche doit déplacer vers la droite.")
	_check(_has_joy_button(&"player_jump", JOY_BUTTON_A), "Le bouton principal de manette doit sauter.")
	_check(_has_joy_motion(&"player_aim_left", JOY_AXIS_RIGHT_X, -1.0), "Le stick droit doit viser vers la gauche.")
	_check(_has_joy_motion(&"player_aim_right", JOY_AXIS_RIGHT_X, 1.0), "Le stick droit doit viser vers la droite.")
	_check(_has_joy_motion(&"player_aim_up", JOY_AXIS_RIGHT_Y, -1.0), "Le stick droit doit viser vers le haut.")
	_check(_has_joy_motion(&"player_aim_down", JOY_AXIS_RIGHT_Y, 1.0), "Le stick droit doit viser vers le bas.")
	_check(_has_mouse_button(&"player_fire", MOUSE_BUTTON_LEFT), "Le clic gauche doit pouvoir tirer.")
	_check(_has_joy_button(&"player_fire", JOY_BUTTON_X), "Le bouton X de manette doit pouvoir tirer.")
	_check(_has_joy_motion(&"player_fire", JOY_AXIS_TRIGGER_RIGHT, 1.0), "La gâchette droite doit pouvoir tirer.")

	var mobile_scene := load("res://ui/mobile/mobile_controls.tscn") as PackedScene
	_check(mobile_scene != null, "La scène canonique MobileControls doit être lisible.")
	var mobile := mobile_scene.instantiate() as MobileControls
	root.add_child(mobile)
	await process_frame
	var touch_actions := {
		"Left": &"player_move_left",
		"Right": &"player_move_right",
		"Up": &"player_aim_up",
		"Down": &"player_aim_down",
		"Jump": &"player_jump",
		"Fire": &"player_fire",
	}
	for node_name in touch_actions:
		var button := mobile.get_node_or_null(node_name) as TouchScreenButton
		_check(button != null, "Bouton tactile absent : %s" % node_name)
		if button != null:
			_check(button.action == touch_actions[node_name], "Action tactile incorrecte pour %s." % node_name)
	mobile.free()

	var player_scene := load("res://characters/player/player_character_2d.tscn") as PackedScene
	var player := player_scene.instantiate() as PlayerCharacter2D
	root.add_child(player)
	await process_frame
	var aim := player.aim_component()
	var pivot := player.get_node("Presentation/AimPivot") as Node2D
	_check(aim.profile.allow_pointer_aim, "Le profil de visée doit autoriser la souris.")
	_check(aim.aim_toward_global(pivot.global_position + Vector2(-120.0, -60.0)), "La commande de visée pointeur doit accepter une cible distante.")
	_check(aim.aim_direction.x < 0.0 and aim.aim_direction.y < 0.0, "La cible pointeur doit produire la bonne direction.")
	player.free()

	var screen_scene := load("res://screens/prototype/prototype_mission_screen.tscn") as PackedScene
	var screen := screen_scene.instantiate()
	root.add_child(screen)
	await process_frame
	_check(screen.get_node_or_null("MobileControls") is MobileControls, "L'écran de mission doit exposer MobileControls dans son SceneTree.")
	var screen_mobile := screen.get_node("MobileControls") as MobileControls
	for node_name in touch_actions:
		var touch_button := screen_mobile.get_node(node_name) as TouchScreenButton
		var radius := (touch_button.shape as CircleShape2D).radius
		_check(touch_button.position.x - radius >= 0.0, "%s doit rester dans le bord gauche." % node_name)
		_check(touch_button.position.y - radius >= 0.0, "%s doit rester dans le bord haut." % node_name)
		_check(touch_button.position.x + radius <= screen_mobile.size.x, "%s doit rester dans le bord droit." % node_name)
		_check(touch_button.position.y + radius <= screen_mobile.size.y, "%s doit rester dans le bord bas." % node_name)
	screen.free()

	if _failures.is_empty():
		print("PLAYER_INPUT_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("PLAYER_INPUT_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _has_event_type(action: StringName, event_type: Variant) -> bool:
	for event in InputMap.action_get_events(action):
		if is_instance_of(event, event_type):
			return true
	return false


func _has_mouse_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button_index:
			return true
	return false


func _has_joy_motion(action: StringName, axis: int, direction: float) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis and signf(event.axis_value) == signf(direction):
			return true
	return false


func _has_joy_button(action: StringName, button_index: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return true
	return false
