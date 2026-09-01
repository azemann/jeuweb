@tool
class_name ServiceStation2D
extends StaticBody2D

signal service_used(actor: PlayerCharacter2D, remaining_uses: int)
signal exhausted

@export_category("Definition")
## Resource autoritaire de présentation, collision, effet et capacité.
@export var data: ServiceStationData:
	set(value):
		data = value
		_sync_from_data()
		update_configuration_warnings()

@export_category("Author Preview")
## Affiche dans l'éditeur le service et l'arme accordée sans devenir une seconde autorité.
@export var show_author_preview := true:
	set(value):
		show_author_preview = value
		_sync_author_preview()

@onready var presentation: Sprite2D = %Presentation
@onready var body_shape: CollisionShape2D = %BodyShape
@onready var interaction_area: Area2D = %InteractionArea
@onready var author_preview: Label = %AuthorPreview

var remaining_uses := 0


func _ready() -> void:
	_sync_from_data()
	_sync_author_preview()
	remaining_uses = data.maximum_uses if data != null else 0


func can_interact(actor: PlayerCharacter2D) -> bool:
	return not Engine.is_editor_hint() and actor != null and data != null and remaining_uses > 0


func interact(actor: PlayerCharacter2D) -> bool:
	if not can_interact(actor):
		return false
	var accepted := false
	match data.service:
		ServiceStationData.Service.HEALTH:
			var health := actor.health_component()
			accepted = health != null and health.heal(data.amount)
		ServiceStationData.Service.AMMO:
			var inventory := actor.combat_inventory_component()
			accepted = inventory != null and inventory.add_ammo(roundi(data.amount))
		ServiceStationData.Service.ARMORY:
			var loadout := actor.loadout_component()
			var weapon_component := actor.weapon_component()
			accepted = loadout != null and loadout.equip_weapon(data.granted_weapon)
			if not accepted:
				accepted = weapon_component != null and weapon_component.equip_weapon(data.granted_weapon)
			var inventory := actor.combat_inventory_component()
			if accepted and inventory != null and data.amount > 0.0:
				inventory.add_ammo(roundi(data.amount))
	if not accepted:
		return false
	remaining_uses -= 1
	service_used.emit(actor, remaining_uses)
	if remaining_uses <= 0:
		interaction_area.collision_layer = 0
		exhausted.emit()
	return true


func get_interaction_prompt() -> String:
	return data.interaction_prompt if data != null else "UTILISER"


func _sync_from_data() -> void:
	if not is_node_ready() or data == null:
		return
	presentation.texture = data.texture
	presentation.centered = false
	presentation.position = -data.pivot_px
	body_shape.position = data.collision_offset
	var rectangle := body_shape.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = data.collision_size
	_sync_author_preview()


func author_preview_text() -> String:
	if data == null:
		return "station: <none>\nservice: <none>\nweapon: <none>\nprojectile: <none>"
	var weapon_id := "<none>"
	var projectile_id := "<none>"
	if data.granted_weapon != null:
		weapon_id = str(data.granted_weapon.weapon_id)
		var projectile := data.granted_weapon.projectile_scene.instantiate() as Projectile2D if data.granted_weapon.projectile_scene != null else null
		if projectile != null and projectile.data != null:
			projectile_id = str(projectile.data.projectile_id)
		if projectile != null:
			projectile.free()
	return "station: %s\nservice: %s\nweapon: %s\nprojectile: %s" % [
		data.station_id,
		ServiceStationData.Service.keys()[data.service],
		weapon_id,
		projectile_id,
	]


func _sync_author_preview() -> void:
	if not is_node_ready() or author_preview == null:
		return
	author_preview.text = author_preview_text()
	author_preview.visible = show_author_preview and Engine.is_editor_hint()


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray() if data != null and data.is_valid() else PackedStringArray(["ServiceStationData est obligatoire et valide."])
