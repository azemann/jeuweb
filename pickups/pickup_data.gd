@tool
class_name PickupData
extends Resource

enum Effect { HEALTH, AMMO, ARMOR, OVERDRIVE }

@export_category("Identity")
## Identifiant stable du contenu ramassable.
@export var pickup_id: StringName
## Nom lisible affiché dans l'Inspector et les futurs retours UI.
@export var display_name := "Pickup"

@export_category("Presentation")
## Livrable runtime publié sous art/ et affiché par la scène canonique.
@export var texture: Texture2D
## Échelle finale de la présentation sur son canevas normalisé.
@export_range(0.1, 2.0, 0.05) var visual_scale := 0.55

@export_category("Gameplay Effect")
## Famille d'effet appliquée au joueur qui accepte le ramassage.
@export var effect := Effect.HEALTH
## Quantité transmise au système autoritaire correspondant.
@export_range(1.0, 1000.0, 1.0) var amount := 35.0

@export_category("Collection")
## Rayon de détection du corps joueur autour du pickup.
@export_range(8.0, 96.0, 1.0, "suffix:px") var collection_radius := 34.0


func is_valid() -> bool:
	return (
		not str(pickup_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and texture != null
		and visual_scale > 0.0
		and effect >= Effect.HEALTH and effect <= Effect.OVERDRIVE
		and amount > 0.0
		and collection_radius > 0.0
	)
