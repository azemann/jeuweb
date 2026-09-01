class_name PlayerWeaponComponent
extends Node

signal projectile_requested(
	projectile_scene: PackedScene,
	spawn_transform: Transform2D,
	direction: Vector2,
	shooter: Node2D,
	clearance_origin: Vector2,
)
signal fired(direction: Vector2)
signal weapon_changed(weapon: WeaponData)

@export_category("Authority")
## Définition de l'arme équipée : projectile, cadence, mode automatique et animation de tir.
@export var weapon: WeaponData
## Joueur propriétaire transmis au projectile pour éviter les impacts contre le tireur.
@export_node_path("PlayerCharacter2D") var player_path := NodePath("../..")
## Composant fournissant la direction de visée quantifiée au moment du tir.
@export_node_path("PlayerAimComponent") var aim_component_path := NodePath("../Aim")
## Point extérieur du canon où le projectile doit normalement apparaître.
@export_node_path("Marker2D") var muzzle_path := NodePath("../../Visuals/AimPivot/Muzzle")
## Origine interne du canon utilisée pour vérifier que le Muzzle n'a pas traversé un mur.
@export_node_path("Node2D") var clearance_origin_path := NodePath("../../Visuals/AimPivot")
## AnimationPlayer chargé du recul et des retours visuels synchronisés avec chaque tir.
@export_node_path("AnimationPlayer") var feedback_player_path := NodePath("../../Visuals/AimPivot/WeaponFeedback")
## Timer natif imposant la cadence décrite par Fire Interval dans la WeaponData.
@export_node_path("Timer") var cooldown_timer_path := NodePath("FireCooldown")
## Autorité de l'arme équipée lorsque l'arsenal joueur est actif.
@export_node_path("PlayerLoadoutComponent") var loadout_component_path := NodePath("../Loadout")
## Réserve de munitions et multiplicateur d'Overdrive du joueur.
@export_node_path("PlayerCombatInventoryComponent") var inventory_component_path := NodePath("../CombatInventory")
## Présentation remplacée lorsque l'arme équipée fournit un bitmap.
@export_node_path("Sprite2D") var weapon_sprite_path := NodePath("../../Visuals/AimPivot/WeaponSprite")

var _player: PlayerCharacter2D
var _aim: PlayerAimComponent
var _muzzle: Marker2D
var _clearance_origin: Node2D
var _feedback_player: AnimationPlayer
var _cooldown: Timer
var _loadout: PlayerLoadoutComponent
var _inventory: PlayerCombatInventoryComponent
var _weapon_sprite: Sprite2D


func _ready() -> void:
	_player = get_node_or_null(player_path) as PlayerCharacter2D
	_aim = get_node_or_null(aim_component_path) as PlayerAimComponent
	_muzzle = get_node_or_null(muzzle_path) as Marker2D
	_clearance_origin = get_node_or_null(clearance_origin_path) as Node2D
	_feedback_player = get_node_or_null(feedback_player_path) as AnimationPlayer
	_cooldown = get_node_or_null(cooldown_timer_path) as Timer
	_loadout = get_node_or_null(loadout_component_path) as PlayerLoadoutComponent
	_inventory = get_node_or_null(inventory_component_path) as PlayerCombatInventoryComponent
	_weapon_sprite = get_node_or_null(weapon_sprite_path) as Sprite2D
	if _loadout != null:
		if not _loadout.weapon_equipped.is_connected(_on_loadout_weapon_equipped):
			_loadout.weapon_equipped.connect(_on_loadout_weapon_equipped)
		if _loadout.equipped_weapon != null:
			weapon = _loadout.equipped_weapon
	_sync_weapon_presentation()
	set_process(not Engine.is_editor_hint() and validation_errors().is_empty() and InputMap.has_action(&"player_fire"))


func _process(_delta: float) -> void:
	var requested := Input.is_action_pressed(&"player_fire") if weapon.automatic else Input.is_action_just_pressed(&"player_fire")
	if requested:
		fire_once()


func can_fire() -> bool:
	return weapon != null and weapon.is_valid() and _cooldown != null and _cooldown.is_stopped() and (not weapon.uses_special_ammo or (_inventory != null and _inventory.special_ammo >= weapon.ammo_cost))


func fire_once() -> bool:
	if not can_fire() or _player == null or _aim == null or _muzzle == null:
		return false
	if weapon.uses_special_ammo and (_inventory == null or not _inventory.consume_ammo(weapon.ammo_cost)):
		return false
	var direction := _aim.aim_direction.normalized()
	var interval_multiplier := _inventory.fire_interval_multiplier() if _inventory != null else 1.0
	_cooldown.start(weapon.fire_interval * interval_multiplier)
	if _feedback_player != null and _feedback_player.has_animation(weapon.fire_animation):
		_feedback_player.play(weapon.fire_animation)
	var clearance_position := _clearance_origin.global_position if _clearance_origin != null else _player.global_position
	projectile_requested.emit(weapon.projectile_scene, _muzzle.global_transform, direction, _player, clearance_position)
	fired.emit(direction)
	var state := _player.state_machine()
	if state != null and not state.is_in(ActorStateMachineComponent.State.DEAD):
		state.transition(ActorStateMachineComponent.State.SHOOT)
	return true


func equip_weapon(value: WeaponData) -> bool:
	if value == null or not value.is_valid():
		return false
	if _loadout != null:
		return _loadout.equip_weapon(value)
	weapon = value
	_sync_weapon_presentation()
	weapon_changed.emit(weapon)
	return true


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if weapon == null or not weapon.is_valid():
		errors.append("WeaponData absente ou invalide.")
	if get_node_or_null(player_path) == null:
		errors.append("PlayerCharacter2D est introuvable.")
	if get_node_or_null(aim_component_path) == null:
		errors.append("PlayerAimComponent est introuvable.")
	if get_node_or_null(muzzle_path) == null:
		errors.append("Le Marker2D Muzzle est introuvable.")
	if get_node_or_null(clearance_origin_path) == null:
		errors.append("L'origine de contrôle interne du canon est introuvable.")
	if get_node_or_null(cooldown_timer_path) == null:
		errors.append("Le Timer FireCooldown est obligatoire.")
	if get_node_or_null(loadout_component_path) == null:
		errors.append("PlayerLoadoutComponent est obligatoire.")
	if get_node_or_null(inventory_component_path) == null:
		errors.append("PlayerCombatInventoryComponent est obligatoire.")
	if get_node_or_null(weapon_sprite_path) == null:
		errors.append("WeaponSprite est obligatoire.")
	return errors


func _sync_weapon_presentation() -> void:
	if _weapon_sprite == null or weapon == null or weapon.weapon_texture == null:
		return
	_weapon_sprite.texture = weapon.weapon_texture
	_weapon_sprite.scale = Vector2.ONE * weapon.weapon_visual_scale


func _on_loadout_weapon_equipped(value: WeaponData, _slot_index: int) -> void:
	weapon = value
	_sync_weapon_presentation()
	weapon_changed.emit(weapon)
