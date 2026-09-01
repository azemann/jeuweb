@tool
class_name PlayerRecoilComponent
extends Node

@export_category("Correspondence")
## Composant d'arme dont le signal Fired fournit direction et WeaponData autoritaire.
@export_node_path("PlayerWeaponComponent") var weapon_component_path := NodePath("../Weapon")
## Pivot du corps déplacé localement sans modifier sa rotation de pente.
@export_node_path("Node2D") var body_pivot_path := NodePath("../../Visuals/GroundPivot")
## Pivot de visée déplacé avec le corps sans concurrencer Aim sur rotation et miroir.
@export_node_path("Node2D") var aim_pivot_path := NodePath("../../Visuals/AimPivot")
## AnimationPlayer autoritaire pour la courbe temporelle normalisée du recul.
@export_node_path("AnimationPlayer") var animation_player_path := NodePath("RecoilAnimationPlayer")

var recoil_weight := 0.0:
	set(value):
		recoil_weight = clampf(value, 0.0, 1.0)
		_apply_offset()

var _weapon: PlayerWeaponComponent
var _body_pivot: Node2D
var _aim_pivot: Node2D
var _animation_player: AnimationPlayer
var _body_origin := Vector2.ZERO
var _aim_origin := Vector2.ZERO
var _recoil_direction := Vector2.RIGHT
var _recoil_distance := 0.0


func _ready() -> void:
	_weapon = get_node_or_null(weapon_component_path) as PlayerWeaponComponent
	_body_pivot = get_node_or_null(body_pivot_path) as Node2D
	_aim_pivot = get_node_or_null(aim_pivot_path) as Node2D
	_animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	if _body_pivot != null:
		_body_origin = _body_pivot.position
	if _aim_pivot != null:
		_aim_origin = _aim_pivot.position
	if not Engine.is_editor_hint() and validation_errors().is_empty():
		_weapon.fired.connect(_on_weapon_fired)


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if get_node_or_null(weapon_component_path) == null:
		errors.append("Le PlayerWeaponComponent de recul est introuvable.")
	if get_node_or_null(body_pivot_path) == null:
		errors.append("Le GroundPivot de recul est introuvable.")
	if get_node_or_null(aim_pivot_path) == null:
		errors.append("Le AimPivot de recul est introuvable.")
	var player := get_node_or_null(animation_player_path) as AnimationPlayer
	if player == null or not player.has_animation(&"recoil"):
		errors.append("RecoilAnimationPlayer doit exposer l'animation recoil.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()


func _on_weapon_fired(direction: Vector2) -> void:
	if _weapon.weapon == null or direction.is_zero_approx():
		return
	_recoil_direction = direction.normalized()
	_recoil_distance = _weapon.weapon.body_recoil_distance
	_animation_player.stop()
	recoil_weight = 0.0
	_animation_player.play(&"recoil")


func _apply_offset() -> void:
	if _body_pivot == null or _aim_pivot == null:
		return
	var offset := -_recoil_direction * _recoil_distance * recoil_weight
	_body_pivot.position = _body_origin + offset
	_aim_pivot.position = _aim_origin + offset
