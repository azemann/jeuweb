class_name PlayerPresentationComponent
extends Node

@export_category("Scene Correspondence")
## Corps physique dont la vitesse et l'état au sol pilotent les animations.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")
## AnimatedSprite2D recevant les animations et le retournement de présentation.
@export_node_path("AnimatedSprite2D") var body_sprite_path := NodePath("../../Visuals/GroundPivot/BodySprite")
## Machine d'états dont les transitions Hurt et Dead suspendent la locomotion visuelle.
@export_node_path("ActorStateMachineComponent") var state_machine_path := NodePath("../StateMachine")
## AnimationPlayer autoritaire pour les timings de flash, secousse et disparition.
@export_node_path("AnimationPlayer") var feedback_player_path := NodePath("../../AnimationPlayer")

@export_category("Animation Mapping")
## Nom de l'animation jouée lorsque le joueur est immobile au sol.
@export var idle_animation: StringName = &"idle"
## Nom de l'animation jouée quand la vitesse horizontale dépasse Movement Threshold.
@export var move_animation: StringName = &"move"
## Nom de l'animation aérienne utilisée pendant la phase ascendante du saut.
@export var jump_animation: StringName = &"jump_rise"
## Nom de l'animation aérienne utilisée lorsque la vitesse verticale devient descendante.
@export var fall_animation: StringName = &"fall"
## Pose non bouclée affichée pendant le feedback d'un dégât accepté.
@export var hurt_animation: StringName = &"hurt"
## Vitesse horizontale minimale, en pixels par seconde, avant de quitter l'animation Idle.
@export_range(1.0, 200.0, 1.0) var movement_threshold := 12.0

@export_category("Feedback Mapping")
## Animation de flash et secousse jouée lors de l'entrée dans l'état Hurt.
@export var damage_feedback_animation: StringName = &"damage"
## Animation de disparition jouée lors de l'entrée dans l'état Dead.
@export var death_feedback_animation: StringName = &"death"
## Animation ambiante restaurée après la fin du feedback de dégâts.
@export var ambient_feedback_animation: StringName = &"idle"

var _body: CharacterBody2D
var _sprite: AnimatedSprite2D
var _state_machine: ActorStateMachineComponent
var _feedback_player: AnimationPlayer


func _ready() -> void:
	_body = get_node_or_null(body_path) as CharacterBody2D
	_sprite = get_node_or_null(body_sprite_path) as AnimatedSprite2D
	_state_machine = get_node_or_null(state_machine_path) as ActorStateMachineComponent
	_feedback_player = get_node_or_null(feedback_player_path) as AnimationPlayer
	if not Engine.is_editor_hint() and _state_machine != null:
		_state_machine.state_changed.connect(_on_state_changed)
	if not Engine.is_editor_hint() and _feedback_player != null:
		_feedback_player.animation_finished.connect(_on_feedback_animation_finished)
	set_process(not Engine.is_editor_hint() and validation_errors().is_empty())


func _process(_delta: float) -> void:
	if _state_machine.is_in(ActorStateMachineComponent.State.HURT) or _state_machine.is_in(ActorStateMachineComponent.State.DEAD):
		return
	_play_locomotion_animation()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if get_node_or_null(body_path) == null:
		errors.append("Le CharacterBody2D de présentation est introuvable.")
	var sprite := get_node_or_null(body_sprite_path) as AnimatedSprite2D
	if sprite == null:
		errors.append("Le BodySprite de présentation est introuvable.")
	elif not sprite.sprite_frames.has_animation(hurt_animation):
		errors.append("La pose Hurt est absente des SpriteFrames.")
	if get_node_or_null(state_machine_path) == null:
		errors.append("La StateMachine de présentation est introuvable.")
	var feedback := get_node_or_null(feedback_player_path) as AnimationPlayer
	if feedback == null:
		errors.append("L'AnimationPlayer de feedback est introuvable.")
	else:
		for animation in [damage_feedback_animation, death_feedback_animation, ambient_feedback_animation]:
			if not feedback.has_animation(animation):
				errors.append("Animation de feedback absente : %s." % animation)
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()


func _play_locomotion_animation() -> void:
	var requested := idle_animation
	if not _body.is_on_floor():
		requested = jump_animation if _body.velocity.y < 0.0 else fall_animation
	elif absf(_body.velocity.x) >= movement_threshold:
		requested = move_animation
	if _sprite.animation != requested:
		_sprite.play(requested)


func _on_state_changed(_previous: ActorStateMachineComponent.State, current: ActorStateMachineComponent.State) -> void:
	match current:
		ActorStateMachineComponent.State.HURT:
			_sprite.play(hurt_animation)
			_feedback_player.play(damage_feedback_animation)
		ActorStateMachineComponent.State.DEAD:
			_sprite.play(hurt_animation)
			_feedback_player.play(death_feedback_animation)


func _on_feedback_animation_finished(animation: StringName) -> void:
	if animation != damage_feedback_animation or not _state_machine.is_in(ActorStateMachineComponent.State.HURT):
		return
	var next_state := ActorStateMachineComponent.State.IDLE
	if not _body.is_on_floor():
		next_state = ActorStateMachineComponent.State.JUMP if _body.velocity.y < 0.0 else ActorStateMachineComponent.State.FALL
	elif absf(_body.velocity.x) >= movement_threshold:
		next_state = ActorStateMachineComponent.State.RUN
	_state_machine.transition(next_state)
	_feedback_player.play(ambient_feedback_animation)
	_play_locomotion_animation()
