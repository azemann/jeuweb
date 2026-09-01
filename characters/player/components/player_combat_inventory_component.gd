class_name PlayerCombatInventoryComponent
extends Node

signal ammo_changed(current: int, maximum: int)
signal armor_changed(current: float, maximum: float)
signal overdrive_changed(remaining: float)

@export_category("Authority")
## Capacités et réglages de surpuissance de l'inventaire de combat.
@export var profile: PlayerCombatInventoryProfile

var special_ammo := 0
var armor := 0.0
var overdrive_remaining := 0.0


func _ready() -> void:
	set_process(not Engine.is_editor_hint() and profile != null and profile.is_valid())


func _process(delta: float) -> void:
	if overdrive_remaining <= 0.0:
		return
	overdrive_remaining = maxf(0.0, overdrive_remaining - delta)
	overdrive_changed.emit(overdrive_remaining)


func add_ammo(amount: int) -> bool:
	if profile == null or amount <= 0:
		return false
	var previous := special_ammo
	special_ammo = mini(profile.maximum_special_ammo, special_ammo + amount)
	if special_ammo == previous:
		return false
	ammo_changed.emit(special_ammo, profile.maximum_special_ammo)
	return true


func consume_ammo(amount: int) -> bool:
	if amount <= 0:
		return true
	if special_ammo < amount:
		return false
	special_ammo -= amount
	ammo_changed.emit(special_ammo, profile.maximum_special_ammo)
	return true


func add_armor(amount: float) -> bool:
	if profile == null or amount <= 0.0:
		return false
	var previous := armor
	armor = minf(profile.maximum_armor, armor + amount)
	if is_equal_approx(armor, previous):
		return false
	armor_changed.emit(armor, profile.maximum_armor)
	return true


func absorb_damage(amount: float) -> float:
	if amount <= 0.0 or armor <= 0.0:
		return amount
	var absorbed := minf(armor, amount)
	armor -= absorbed
	armor_changed.emit(armor, profile.maximum_armor)
	return amount - absorbed


func activate_overdrive(duration: float = 0.0) -> bool:
	if profile == null:
		return false
	var added := duration if duration > 0.0 else profile.overdrive_duration
	overdrive_remaining = minf(profile.overdrive_duration * 2.0, overdrive_remaining + added)
	overdrive_changed.emit(overdrive_remaining)
	return true


func fire_interval_multiplier() -> float:
	return profile.overdrive_fire_interval_multiplier if profile != null and overdrive_remaining > 0.0 else 1.0


func validation_errors() -> PackedStringArray:
	return PackedStringArray() if profile != null and profile.is_valid() else PackedStringArray(["PlayerCombatInventoryProfile est obligatoire."])


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
