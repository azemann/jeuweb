@tool
class_name WorldPropData
extends Resource

@export_category("Identity")
## Identifiant stable du landmark ou décor physique.
@export var prop_id: StringName
## Nom lisible dans l'Inspector.
@export var display_name := "World prop"
@export_category("Presentation")
## Bitmap runtime publié.
@export var texture: Texture2D
## Pixel du canevas placé à l'origine.
@export var pivot_px := Vector2.ZERO
@export_category("Collision")
## Active un corps World pour cette scène.
@export var collision_enabled := true
## Taille du volume physique simple.
@export var collision_size := Vector2(80, 160)
## Position locale du volume physique.
@export var collision_offset := Vector2(0, -80)


func is_valid() -> bool:
	return not str(prop_id).is_empty() and texture != null and (not collision_enabled or (collision_size.x > 0.0 and collision_size.y > 0.0))
