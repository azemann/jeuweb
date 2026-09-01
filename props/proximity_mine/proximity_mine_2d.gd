@tool
class_name ProximityMine2D
extends Area2D

signal detonated

@export_category("Definition")
## Resource autoritaire de présentation, détection et explosion.
@export var data: ProximityMineData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var trigger_shape: CollisionShape2D = %TriggerShape
var _detonated := false


func _ready() -> void:
	_sync_from_data()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint() or _detonated or not body.is_in_group(&"players"):
		return
	_detonated = true
	var explosion := data.explosion_scene.instantiate() as Explosion2D
	if explosion != null and get_parent() != null:
		explosion.data = data.explosion_data
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.detonate()
	detonated.emit()
	queue_free()


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	var circle := trigger_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = data.trigger_radius


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray() if data != null and data.is_valid() else PackedStringArray(["ProximityMineData est obligatoire et valide."])
