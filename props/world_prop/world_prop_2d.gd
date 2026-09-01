@tool
class_name WorldProp2D
extends StaticBody2D

@export_category("Definition")
## Resource autoritaire pour identité, présentation et collision.
@export var data: WorldPropData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var body_shape: CollisionShape2D = %BodyShape


func _ready() -> void:
	_sync_from_data()


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	body_shape.position = data.collision_offset
	body_shape.disabled = not data.collision_enabled
	collision_layer = 1 if data.collision_enabled else 0
	var rectangle := body_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = data.collision_size


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray() if data != null and data.is_valid() else PackedStringArray(["WorldPropData est obligatoire et valide."])
