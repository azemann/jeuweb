class_name EnemyHealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

@export_category("Authority")
## Profil d'archétype qui fixe le maximum de PV et l'invulnérabilité.
@export var profile: EnemyArchetypeProfile

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
