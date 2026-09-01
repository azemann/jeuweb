@tool
class_name ServiceStationData
extends Resource

enum Service { HEALTH, AMMO, ARMORY }

@export_category("Identity")
## Identifiant stable de la station.
@export var station_id: StringName
## Nom présenté dans l'Inspector.
@export var display_name := "Station"

@export_category("Presentation")
## Bitmap runtime publié.
@export var texture: Texture2D
## Pixel du canevas placé à l'origine de la scène.
@export var pivot_px := Vector2.ZERO
## Taille du corps physique auteur.
@export var collision_size := Vector2(120, 220)
## Décalage du corps physique par rapport à l'origine.
@export var collision_offset := Vector2(0, -110)

@export_category("Service")
## Autorité bénéficiaire appelée lors d'une interaction acceptée.
@export var service := Service.HEALTH
## Quantité de soin ou de munitions fournie par utilisation.
@export_range(1.0, 1000.0, 1.0) var amount := 50.0
## Arme équipée par une station d'armurerie. La WeaponData reste l'autorité du comportement.
@export var granted_weapon: WeaponData
## Nombre d'utilisations de cette occurrence avant épuisement.
@export_range(1, 20, 1) var maximum_uses := 1
## Texte affiché par le PlayerInteractionComponent.
@export var interaction_prompt := "UTILISER"


func is_valid() -> bool:
	if str(station_id).is_empty() or texture == null or collision_size.x <= 0.0 or collision_size.y <= 0.0:
		return false
	if maximum_uses <= 0 or interaction_prompt.strip_edges().is_empty():
		return false
	if service == Service.ARMORY:
		return granted_weapon != null and granted_weapon.is_valid() and amount >= 0.0
	return amount > 0.0
