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
	root.add_child(player)
	await process_frame
	var presentation := player.presentation_component()
	var state := player.state_machine()
	var sprite := player.get_node("Visuals/GroundPivot/BodySprite") as AnimatedSprite2D
	var feedback := player.get_node("AnimationPlayer") as AnimationPlayer
	_check(presentation != null and presentation.validation_errors().is_empty(), "Le composant Animation doit exposer un feedback valide.")
	_check(feedback.has_animation(&"damage") and feedback.has_animation(&"death"), "AnimationPlayer doit porter les timings Damage et Death.")

	_check(player.apply_damage(10.0), "Un premier dégât doit être accepté.")
	await process_frame
	_check(state.is_in(ActorStateMachineComponent.State.HURT), "Un dégât accepté doit placer le joueur en Hurt.")
	_check(sprite.animation == &"hurt", "Le feedback de dégâts doit afficher la pose Hurt publiée.")
	_check(feedback.current_animation == &"damage", "Le flash de dégâts doit être joué par AnimationPlayer.")
	await create_timer(0.3).timeout
	_check(not state.is_in(ActorStateMachineComponent.State.HURT), "La fin du feedback doit rendre la locomotion au joueur.")
	_check(feedback.current_animation == &"idle", "Le feedback ambiant doit reprendre après Damage.")

	player.health_component().reset_health()
	_check(player.apply_damage(player.health_component().profile.maximum_health), "Un dégât létal doit être accepté.")
	await process_frame
	_check(state.is_in(ActorStateMachineComponent.State.DEAD), "Zéro PV doit placer le joueur en Dead.")
	_check(sprite.animation == &"hurt", "Sans atlas de mort publié, la pose Hurt doit rester la présentation de mort autoritaire.")
	_check(feedback.current_animation == &"death", "La disparition de mort doit être jouée par AnimationPlayer.")
	await create_timer(0.5).timeout
	_check(player.get_node("Visuals").modulate.a < 1.0, "Death doit rendre la disparition visible avant le respawn.")
	player.free()

	if _failures.is_empty():
		print("PLAYER_FEEDBACK_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("PLAYER_FEEDBACK_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
