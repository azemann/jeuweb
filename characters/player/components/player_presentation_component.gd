class_name PlayerPresentationComponent
extends Node

@export_category("Scene Correspondence")
## Corps physique dont la vitesse et l'état au sol pilotent les animations.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")
## AnimatedSprite2D recevant les animations et le retournement de présentation.
@export_node_path("AnimatedSprite2D") var body_sprite_path := NodePath("../../Visuals/GroundPivot/BodySprite")

@export_category("Animation Mapping")
## Nom de l'animation jouée lorsque le joueur est immobile au sol.
@export var idle_animation: StringName = &"idle"
## Nom de l'animation jouée quand la vitesse horizontale dépasse Movement Threshold.
@export var move_animation: StringName = &"move"
## Nom de l'animation aérienne utilisée pendant la phase ascendante du saut.
@export var jump_animation: StringName = &"jump_rise"
## Nom de l'animation aérienne utilisée lorsque la vitesse verticale devient descendante.
@export var fall_animation: StringName = &"fall"
## Vitesse horizontale minimale, en pixels par seconde, avant de quitter l'animation Idle.
@export_range(1.0, 200.0, 1.0) var movement_threshold := 12.0

var _body: CharacterBody2D
var _sprite: AnimatedSprite2D


func _ready() -> void:
	_body = get_node_or_null(body_path) as CharacterBody2D
	_sprite = get_node_or_null(body_sprite_path) as AnimatedSprite2D
	set_process(not Engine.is_editor_hint() and _body != null and _sprite != null)


func _process(_delta: float) -> void:
	var requested := idle_animation
	if not _body.is_on_floor():
		requested = jump_animation if _body.velocity.y < 0.0 else fall_animation
	elif absf(_body.velocity.x) >= movement_threshold:
		requested = move_animation
	if _sprite.animation != requested:
		_sprite.play(requested)
