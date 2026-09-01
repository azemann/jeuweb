@tool
class_name Pickup2D
extends Area2D

signal collected(pickup: Pickup2D, actor: PlayerCharacter2D)

@export_category("Definition")
## Resource autoritaire pour identité, présentation, effet et rayon de collecte.
@export var data: PickupData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@onready var presentation: Sprite2D = %Presentation
@onready var collection_shape: CollisionShape2D = %CollectionShape

var _collected := false


func _ready() -> void:
	_sync_from_data()
	body_entered.connect(_on_body_entered)


func collect(actor: PlayerCharacter2D) -> bool:
	if Engine.is_editor_hint() or _collected or actor == null or data == null:
		return false
	var accepted := false
	var combat_inventory := actor.combat_inventory_component()
	match data.effect:
		PickupData.Effect.HEALTH:
			var health := actor.health_component()
			accepted = health != null and health.heal(data.amount)
		PickupData.Effect.AMMO:
			accepted = combat_inventory != null and combat_inventory.add_ammo(roundi(data.amount))
		PickupData.Effect.ARMOR:
			accepted = combat_inventory != null and combat_inventory.add_armor(data.amount)
		PickupData.Effect.OVERDRIVE:
			accepted = combat_inventory != null and combat_inventory.activate_overdrive(data.amount)
	if not accepted:
		return false
	_collected = true
	monitoring = false
	visible = false
	collected.emit(self, actor)
	queue_free()
	return true


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter2D:
		collect(body as PlayerCharacter2D)


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.scale = Vector2.ONE * data.visual_scale
	var circle := collection_shape.shape as CircleShape2D
	if circle != null:
		circle.radius = data.collection_radius


func _get_configuration_warnings() -> PackedStringArray:
	if data == null:
		return PackedStringArray(["PickupData est obligatoire."])
	return PackedStringArray() if data.is_valid() else PackedStringArray(["PickupData est incomplète."])
