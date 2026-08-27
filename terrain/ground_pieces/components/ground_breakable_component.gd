@tool
class_name GroundBreakableComponent
extends Node

const GroundBreakableProfileType = preload("res://terrain/ground_pieces/ground_breakable_profile.gd")

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal piece_broken

var profile: GroundBreakableProfileType
var current_health := 0.0
var broken := false


func configure(value: GroundBreakableProfileType) -> void:
	profile = value
	broken = false
	current_health = profile.maximum_health if profile != null else 0.0
	if profile != null:
		health_changed.emit(current_health, profile.maximum_health)


func configured_profile() -> GroundBreakableProfileType:
	return profile


func is_broken() -> bool:
	return broken


func reset_state() -> void:
	broken = false


func apply_damage(amount: float) -> bool:
	if profile == null or amount <= 0.0 or broken:
		return false
	current_health = maxf(0.0, current_health - amount)
	damaged.emit(amount)
	health_changed.emit(current_health, profile.maximum_health)
	if current_health <= 0.0:
		broken = true
		piece_broken.emit()
	return true
