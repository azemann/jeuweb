@tool
class_name DamageHazard2D
extends Node2D

signal target_damaged(target: Node, damage: float)

@export_category("Definition")
## Resource-panneau autoritaire pour l'apparence, la zone, les dégâts et le rythme.
@export var data: HazardData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var damage_area: Area2D = %DamageArea
@onready var damage_shape: CollisionShape2D = %DamageShape
@onready var tick_timer: Timer = %TickTimer


func _ready() -> void:
	_sync_from_data()
	if not Engine.is_editor_hint() and data != null and data.is_valid():
		tick_timer.start(data.tick_interval)


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	damage_shape.position = data.damage_zone_offset
	var rectangle := damage_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = data.damage_zone_size
	tick_timer.wait_time = data.tick_interval


func _on_body_entered(body: Node2D) -> void:
	if not Engine.is_editor_hint():
		_damage_target(body)


func _on_tick_timeout() -> void:
	for body in damage_area.get_overlapping_bodies():
		_damage_target(body)


func _damage_target(source: Node) -> void:
	var target := _damage_receiver(source)
	if target != null and data != null and target.call(&"apply_damage", data.damage_per_tick):
		target_damaged.emit(target, data.damage_per_tick)


func _damage_receiver(source: Node) -> Node:
	var current := source
	for _depth in 4:
		if current == null:
			return null
		if current.has_method(&"apply_damage"):
			return current
		current = current.get_parent()
	return null


func _get_configuration_warnings() -> PackedStringArray:
	if data == null:
		return PackedStringArray(["HazardData est obligatoire."])
	return PackedStringArray() if data.is_valid() else PackedStringArray(["HazardData est incomplète."])
