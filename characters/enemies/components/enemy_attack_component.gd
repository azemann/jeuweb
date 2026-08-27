@tool
class_name EnemyAttackComponent
extends Node

signal attack_started
signal projectile_requested(projectile: Projectile2D)
signal attack_finished

@export_category("Authority")
## Projectile scene et paramètres de cadence sont éditables depuis cette instance.
@export var projectile_scene: PackedScene
## Délai minimal en secondes entre deux séquences d'attaque complètes.
@export_range(0.1, 10.0, 0.05) var attack_cooldown := 2.4
## Distance maximale entre l'ennemi et le joueur pour commencer une attaque.
@export_range(32.0, 1200.0, 8.0) var attack_range := 360.0

@export_category("Correspondence")
## Sprite de locomotion masqué pendant la séquence d'attaque.
@export_node_path("AnimatedSprite2D") var body_sprite_path := NodePath("../../Presentation/SlopeVisual/BodySprite")
## SpriteFrames dédié qui porte les phases temporelles de l'attaque.
@export_node_path("AnimatedSprite2D") var attack_sprite_path := NodePath("../../Presentation/SlopeVisual/AttackSprite")
## Socket auteur depuis lequel le projectile toxique est émis.
@export_node_path("Marker2D") var attack_origin_path := NodePath("../../Presentation/SlopeVisual/AttackOrigin")
## Composant de patrouille suspendu pendant l'attaque puis réactivé à sa fin.
@export_node_path("EnemyPatrolComponent") var patrol_component_path := NodePath("../Patrol")
## Branche runtime recevant le projectile sans le rendre enfant de l'ennemi.
@export_node_path("Node2D") var projectile_root_path := NodePath("../../../Projectiles")

var _sprite: AnimatedSprite2D
var _walk_sprite: AnimatedSprite2D
var _origin: Marker2D
var _patrol: EnemyPatrolComponent
var _actor: Node2D
var _cooldown_remaining := 0.0
var _attacking := false
var _projectile_emitted := false


func _ready() -> void:
	_sprite = get_node_or_null(body_sprite_path) as AnimatedSprite2D
	_walk_sprite = _sprite
	_sprite = get_node_or_null(attack_sprite_path) as AnimatedSprite2D
	_origin = get_node_or_null(attack_origin_path) as Marker2D
	_patrol = get_node_or_null(patrol_component_path) as EnemyPatrolComponent
	_actor = get_parent().get_parent() as Node2D
	if Engine.is_editor_hint():
		return
	if _sprite != null and not _sprite.frame_changed.is_connected(_on_frame_changed):
		_sprite.frame_changed.connect(_on_frame_changed)
	if _sprite != null and not _sprite.animation_finished.is_connected(_on_animation_finished):
		_sprite.animation_finished.connect(_on_animation_finished)
	set_physics_process(_sprite != null and _origin != null and projectile_scene != null)


func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)
	_sync_origin()
	if _attacking or _cooldown_remaining > 0.0:
		return
	var player := get_tree().get_first_node_in_group(&"players") as Node2D
	if player == null or not is_instance_valid(player) or _actor == null or _actor.global_position.distance_to(player.global_position) > attack_range:
		return
	_start_attack()


func _start_attack() -> void:
	_attacking = true
	_projectile_emitted = false
	_cooldown_remaining = attack_cooldown
	if _patrol != null:
		_patrol.set_movement_enabled(false)
	var state := _actor as EnemyCharacter2D
	if state != null and state.state_machine() != null:
		state.state_machine().transition(ActorStateMachineComponent.State.ATTACK)
	_sync_origin()
	_sprite.play(&"toxic_attack")
	_walk_sprite.visible = false
	_sprite.visible = true
	attack_started.emit()


func cancel_attack() -> void:
	if not _attacking:
		return
	_attacking = false
	_projectile_emitted = false
	if _sprite != null:
		_sprite.stop()
		_sprite.visible = false
	if _walk_sprite != null:
		_walk_sprite.visible = true
	if _patrol != null:
		_patrol.set_movement_enabled(true)
	var state := _actor as EnemyCharacter2D
	if state != null and state.state_machine() != null:
		state.state_machine().transition(ActorStateMachineComponent.State.RUN)


func _on_frame_changed() -> void:
	if not _attacking or _projectile_emitted or _sprite.animation != &"toxic_attack":
		return
	if _sprite.frame == 3:
		_spawn_projectile()


func _spawn_projectile() -> void:
	var root := get_node_or_null(projectile_root_path) as Node2D
	if root == null:
		var actors := get_parent().get_parent().get_parent() as Node
		root = actors.get_node_or_null("Projectiles") as Node2D if actors != null else null
	if root == null or projectile_scene == null or not projectile_scene.can_instantiate():
		push_error("EnemyAttackComponent exige Actors/Projectiles et une scène projectile valide.")
		return
	var projectile := projectile_scene.instantiate() as Projectile2D
	if projectile == null:
		push_error("La scène d'attaque doit produire un Projectile2D.")
		return
	root.add_child(projectile)
	var player := get_tree().get_first_node_in_group(&"players") as Node2D
	var direction := Vector2.RIGHT
	if player != null:
		direction = _origin.global_position.direction_to(player.global_position)
	projectile.global_position = _origin.global_position
	projectile.launch(direction, get_parent().get_parent() as Node2D)
	_projectile_emitted = true
	projectile_requested.emit(projectile)


func _on_animation_finished() -> void:
	if not _attacking or _sprite.animation != &"toxic_attack":
		return
	_attacking = false
	if _patrol != null:
		_patrol.set_movement_enabled(true)
	_sprite.visible = false
	_walk_sprite.visible = true
	_walk_sprite.play(&"walk")
	attack_finished.emit()


func _sync_origin() -> void:
	if _origin == null or _sprite == null:
		return
	var facing_left := _walk_sprite.flip_h if _walk_sprite != null else _sprite.flip_h
	_origin.position.x = absf(_origin.position.x) * (-1.0 if facing_left else 1.0)
	if _sprite != null and _walk_sprite != null:
		_sprite.flip_h = _walk_sprite.flip_h


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if projectile_scene == null or not projectile_scene.can_instantiate():
		errors.append("Projectile scene valide obligatoire.")
	if get_node_or_null(body_sprite_path) == null:
		errors.append("BodySprite doit être assigné.")
	if get_node_or_null(attack_sprite_path) == null:
		errors.append("AttackSprite doit être assigné.")
	if get_node_or_null(attack_origin_path) == null:
		errors.append("AttackOrigin doit être assigné.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
