@tool
class_name PlayerCombatInventoryProfile
extends Resource

@export_category("Capacity")
## Réserve maximale partagée par les armes spéciales.
@export_range(1, 999, 1) var maximum_special_ammo := 40
## Quantité maximale de dégâts absorbables par l'armure.
@export_range(1.0, 1000.0, 1.0) var maximum_armor := 100.0

@export_category("Overdrive")
## Durée ajoutée par un noyau de surpuissance.
@export_range(0.5, 60.0, 0.5, "suffix:s") var overdrive_duration := 8.0
## Multiplicateur de l'intervalle de tir pendant la surpuissance.
@export_range(0.2, 1.0, 0.05) var overdrive_fire_interval_multiplier := 0.55


func is_valid() -> bool:
	return maximum_special_ammo > 0 and maximum_armor > 0.0 and overdrive_duration > 0.0 and overdrive_fire_interval_multiplier > 0.0 and overdrive_fire_interval_multiplier <= 1.0
