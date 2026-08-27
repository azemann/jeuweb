@tool
class_name HazardData
extends Resource

@export_category("Identity")
## Identifiant stable utilisé par les maps, sauvegardes et futurs catalogues.
@export var hazard_id: StringName
## Nom lisible de ce danger dans l'Inspector.
@export var display_name := "Danger"

@export_category("Presentation")
## PNG runtime publié qui représente le danger dans la scène.
@export var texture: Texture2D
## Pixel du canevas PNG placé exactement sur l'origine de la scène.
@export var pivot_px := Vector2.ZERO

@export_category("Damage")
## Dégâts appliqués dès l'entrée puis à chaque intervalle aux acteurs présents.
@export_range(0.0, 1000.0, 1.0) var damage_per_tick := 20.0
## Temps en secondes entre deux applications de dégâts.
@export_range(0.05, 10.0, 0.05) var tick_interval := 0.75

@export_category("Authored Zone")
## Dimensions de la zone dangereuse locale, visibles dans la scène et l'Inspector.
@export var damage_zone_size := Vector2(560.0, 72.0)
## Décalage de la zone dangereuse par rapport à l'origine de la scène.
@export var damage_zone_offset := Vector2(0.0, -72.0)


func is_valid() -> bool:
	return (
		not str(hazard_id).is_empty()
		and texture != null
		and damage_per_tick >= 0.0
		and tick_interval > 0.0
		and damage_zone_size.x > 0.0
		and damage_zone_size.y > 0.0
	)
