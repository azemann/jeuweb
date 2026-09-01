@tool
class_name SupplyCrate2D
extends StaticBody2D

signal opened(crate: SupplyCrate2D)
signal content_spawned(content: Node2D)

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
@onready var interaction_area: Area2D = %InteractionArea
@onready var contents_origin: Marker2D = %ContentsOrigin

var _health := 0.0
var _is_open := false
var _spawned_content: Node2D


func _ready() -> void:
	_sync_from_data()
	if data != null:
		_health = data.maximum_health


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
	interaction_area.set_deferred(&"monitorable", false)
	interaction_area.collision_layer = 0
	_spawn_contents()
	opened.emit(self)
	return true


func is_open() -> bool:
	return _is_open


func can_interact(_actor: PlayerCharacter2D) -> bool:
	return not _is_open and data != null and data.accepts_interaction()


func interact(actor: PlayerCharacter2D) -> bool:
	return open() if can_interact(actor) else false


func get_interaction_prompt() -> String:
	return "OUVRIR"


func spawned_content() -> Node2D:
	return _spawned_content


func _spawn_contents() -> void:
	if _spawned_content != null or data == null or not data.has_contents():
		return
	var content := data.contents_scene.instantiate() as Node2D
	if content == null:
		return
	contents_origin.add_child(content)
	content.top_level = true
	content.global_position = contents_origin.global_position
	_spawned_content = content
	content_spawned.emit(content)


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
