@tool
class_name SupplyCrate2D
extends StaticBody2D

signal opened(crate: SupplyCrate2D)

@export_category("Definition")
## Resource-panneau autoritaire pour les visuels, modes d'ouverture et collisions.
@export var data: SupplyCrateData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var solid_shape: CollisionShape2D = %SolidShape
@onready var interaction_shape: CollisionShape2D = %InteractionShape

var _health := 0.0
var _is_open := false
var _nearby_players := 0


func _ready() -> void:
	_sync_from_data()
	if data != null:
		_health = data.maximum_health
	set_process(not Engine.is_editor_hint())


func _process(_delta: float) -> void:
	if (
		_is_open
		or data == null
		or not data.accepts_interaction()
		or _nearby_players <= 0
		or not InputMap.has_action(data.interaction_action)
	):
		return
	if Input.is_action_just_pressed(data.interaction_action):
		open()


func apply_damage(amount: float) -> bool:
	if Engine.is_editor_hint() or _is_open or data == null or not data.accepts_shot() or amount <= 0.0:
		return false
	_health = maxf(0.0, _health - amount)
	if is_zero_approx(_health):
		open()
	return true


func open() -> bool:
	if _is_open or data == null:
		return false
	_is_open = true
	presentation.texture = data.open_texture
	if not data.keep_collision_when_open:
		collision_layer = 0
		solid_shape.set_deferred(&"disabled", true)
	opened.emit(self)
	return true


func is_open() -> bool:
	return _is_open


func _on_interaction_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"players"):
		_nearby_players += 1


func _on_interaction_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"players"):
		_nearby_players = maxi(0, _nearby_players - 1)


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.open_texture if _is_open else data.closed_texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	solid_shape.position = data.collision_offset
	var rectangle := solid_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = data.collision_size
	var circle := interaction_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = data.interaction_radius


func _get_configuration_warnings() -> PackedStringArray:
	if data == null:
		return PackedStringArray(["SupplyCrateData est obligatoire."])
	return PackedStringArray() if data.is_valid() else PackedStringArray(["SupplyCrateData est incomplète."])
