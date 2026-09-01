class_name PlayerHealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

@export_category("Authority")
## Profil qui fixe les PV maximum et la fenêtre d'invulnérabilité après chaque impact.
@export var profile: PlayerHealthProfile

var current_health := 0.0
var _invulnerability_remaining := 0.0


func _ready() -> void:
	if profile != null and profile.is_valid():
		current_health = profile.maximum_health
		health_changed.emit(current_health, profile.maximum_health)


func _process(delta: float) -> void:
	_invulnerability_remaining = maxf(0.0, _invulnerability_remaining - delta)


func apply_damage(amount: float) -> bool:
	if profile == null or amount <= 0.0 or current_health <= 0.0 or _invulnerability_remaining > 0.0:
		return false
	current_health = maxf(0.0, current_health - amount)
	_invulnerability_remaining = profile.post_hit_invulnerability
	damaged.emit(amount)
	health_changed.emit(current_health, profile.maximum_health)
	if current_health <= 0.0:
		died.emit()
	return true


func heal(amount: float) -> bool:
	if profile == null or amount <= 0.0 or current_health <= 0.0:
		return false
	var previous := current_health
	current_health = minf(profile.maximum_health, current_health + amount)
	if is_equal_approx(current_health, previous):
		return false
	health_changed.emit(current_health, profile.maximum_health)
	return true


func reset_health() -> void:
	if profile == null or not profile.is_valid():
		return
	_invulnerability_remaining = 0.0
	current_health = profile.maximum_health
	health_changed.emit(current_health, profile.maximum_health)
