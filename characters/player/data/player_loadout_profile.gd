@tool
class_name PlayerLoadoutProfile
extends Resource

@export_category("Weapons")
## Arme gratuite toujours disponible au respawn et dans un arsenal valide.
@export var primary_weapon: WeaponData
## Armes spéciales que les armureries peuvent rendre actives sans recopier leurs réglages.
@export var special_weapons: Array[WeaponData] = []
## Arme équipée au démarrage. Vide ou invalide revient au canon principal.
@export var starting_weapon: WeaponData


func starting_weapon_or_primary() -> WeaponData:
	return starting_weapon if starting_weapon != null and _contains_weapon(starting_weapon.weapon_id) else primary_weapon


func weapons() -> Array[WeaponData]:
	var result: Array[WeaponData] = []
	if primary_weapon != null:
		result.append(primary_weapon)
	for weapon in special_weapons:
		if weapon != null:
			result.append(weapon)
	return result


func weapon_for_id(weapon_id: StringName) -> WeaponData:
	for weapon in weapons():
		if weapon.weapon_id == weapon_id:
			return weapon
	return null


func has_weapon(weapon: WeaponData) -> bool:
	return weapon != null and _contains_weapon(weapon.weapon_id)


func is_valid() -> bool:
	if primary_weapon == null or not primary_weapon.is_valid():
		return false
	var ids := {}
	for weapon in weapons():
		if weapon == null or not weapon.is_valid():
			return false
		if ids.has(weapon.weapon_id):
			return false
		ids[weapon.weapon_id] = true
	return starting_weapon == null or ids.has(starting_weapon.weapon_id)


func _contains_weapon(weapon_id: StringName) -> bool:
	return weapon_for_id(weapon_id) != null
