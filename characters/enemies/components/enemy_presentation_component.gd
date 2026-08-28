class_name EnemyPresentationComponent
extends Node

signal hit_animation_finished
signal death_animation_finished

@export_category("Correspondence")
## AnimatedSprite2D recevant la marche et le retournement horizontal.
@export_node_path("AnimatedSprite2D") var body_sprite_path := NodePath("../../Visuals/GroundPivot/BodySprite")
## Composant de patrouille dont la vélocité pilote la présentation.
@export_node_path("EnemyPatrolComponent") var patrol_component_path := NodePath("../Patrol")

@export_category("Animation Mapping")
## Animation locomotrice utilisée hors réaction.
@export var walk_animation: StringName = &"walk"
## Animation non bouclée jouée après un dégât accepté.
@export var hit_animation: StringName = &"hit"
## Animation non bouclée jouée à zéro PV.
@export var death_animation: StringName = &"death"

var _sprite: AnimatedSprite2D
var _patrol: EnemyPatrolComponent
var _reacting := false
var _dying := false


func _ready() -> void:
	_sprite = get_node_or_null(body_sprite_path) as AnimatedSprite2D
	_patrol = get_node_or_null(patrol_component_path) as EnemyPatrolComponent
	set_process(not Engine.is_editor_hint() and _sprite != null and _patrol != null)
	if _sprite != null:
		if not _sprite.animation_finished.is_connected(_on_animation_finished):
			_sprite.animation_finished.connect(_on_animation_finished)
		_sprite.play(walk_animation)


func _process(_delta: float) -> void:
	if _patrol.direction != 0.0:
		_sprite.flip_h = _patrol.direction < 0.0


func play_hit() -> void:
	if _sprite == null or _dying or not _sprite.sprite_frames.has_animation(hit_animation):
		return
	_reacting = true
	_sprite.play(hit_animation)


func play_death() -> void:
	if _sprite == null or not _sprite.sprite_frames.has_animation(death_animation):
		death_animation_finished.emit()
		return
	_dying = true
	_reacting = false
	_sprite.play(death_animation)


func _on_animation_finished() -> void:
	if _dying and _sprite.animation == death_animation:
		death_animation_finished.emit()
	elif _reacting and _sprite.animation == hit_animation:
		_reacting = false
		_sprite.play(walk_animation)
		hit_animation_finished.emit()
