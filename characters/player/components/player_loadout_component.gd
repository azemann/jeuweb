class_name PlayerLoadoutComponent
extends Node

signal weapon_equipped(weapon: WeaponData, slot_index: int)
signal loadout_changed(weapons: Array[WeaponData])

@export_category("Authority")
## Arsenal autorisé du joueur : arme primaire, armes spéciales et arme de départ.
@export var profile: PlayerLoadoutProfile

var equipped_weapon: WeaponData
var equipped_slot_index := -1


func _ready() -> void:
	if profile != null and profile.is_valid():
		equip_weapon(profile.starting_weapon_or_primary())
		loadout_changed.emit(profile.weapons())


func equip_weapon(weapon: WeaponData) -> bool:
	if profile == null or not profile.is_valid() or not profile.has_weapon(weapon):
		return false
	var next_index := _slot_index_for(weapon.weapon_id)
	if next_index < 0:
		return false
	equipped_weapon = weapon
	equipped_slot_index = next_index
	weapon_equipped.emit(equipped_weapon, equipped_slot_index)
	return true


func equip_weapon_id(weapon_id: StringName) -> bool:
	return equip_weapon(profile.weapon_for_id(weapon_id) if profile != null else null)


func available_weapons() -> Array[WeaponData]:
	return profile.weapons() if profile != null and profile.is_valid() else []


func has_weapon(weapon: WeaponData) -> bool:
	return profile != null and profile.is_valid() and profile.has_weapon(weapon)


func validation_errors() -> PackedStringArray:
	return PackedStringArray() if profile != null and profile.is_valid() else PackedStringArray(["PlayerLoadoutProfile est obligatoire."])


func _slot_index_for(weapon_id: StringName) -> int:
	var candidates := available_weapons()
	for index in candidates.size():
		if candidates[index].weapon_id == weapon_id:
			return index
	return -1


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
