@tool
class_name ExplosiveProp2D
extends StaticBody2D

signal health_changed(current: float, maximum: float)
signal exploded

@export_category("Definition")
## Resource-panneau autoritaire pour l'apparence, la résistance, la collision et l'explosion.
@export var data: ExplosivePropData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var collision_shape: CollisionShape2D = %CollisionShape
@onready var explosion_origin: Marker2D = %ExplosionOrigin

var _health := 0.0
var _exploded := false


func _ready() -> void:
	_sync_from_data()
	if data != null:
		_health = data.maximum_health


func apply_damage(amount: float) -> bool:
	if Engine.is_editor_hint() or _exploded or data == null or amount <= 0.0:
		return false
	_health = maxf(0.0, _health - amount)
	health_changed.emit(_health, data.maximum_health)
	if is_zero_approx(_health):
		_detonate()
	return true


func _detonate() -> void:
	_exploded = true
	var parent := get_parent()
	if parent != null and data.explosion_scene != null:
		var explosion := data.explosion_scene.instantiate() as Explosion2D
		if explosion != null:
			explosion.data = data.explosion_data
			parent.add_child(explosion)
			explosion.global_position = explosion_origin.global_position
			explosion.detonate()
	exploded.emit()
	queue_free()


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	collision_shape.position = data.collision_offset
	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = data.collision_size


func _get_configuration_warnings() -> PackedStringArray:
	if data == null:
		return PackedStringArray(["ExplosivePropData est obligatoire."])
	var warnings := PackedStringArray()
	if not data.is_valid():
		warnings.append("ExplosivePropData est incomplète.")
	if get_node_or_null("ExplosionOrigin") is not Marker2D:
		warnings.append("ExplosionOrigin est obligatoire pour placer la détonation.")
	return warnings
