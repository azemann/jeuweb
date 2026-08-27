@tool
class_name ExplosivePropData
extends Resource

@export_category("Identity")
## Identifiant stable de cette définition d'objet explosif.
@export var prop_id: StringName
## Nom lisible présenté au level designer dans l'Inspector.
@export var display_name := "Objet explosif"

@export_category("Presentation")
## PNG runtime publié affiché avant la destruction de l'objet.
@export var texture: Texture2D
## Pixel du PNG aligné avec l'origine physique de la scène.
@export var pivot_px := Vector2.ZERO

@export_category("Integrity")
## Points de vie nécessaires avant de déclencher l'explosion.
@export_range(1.0, 10000.0, 1.0) var maximum_health := 30.0

@export_category("Collision")
## Taille de la collision solide et tirable de l'objet.
@export var collision_size := Vector2(94.0, 210.0)
## Position de la collision par rapport à l'origine posée au sol.
@export var collision_offset := Vector2(0.0, -106.0)

@export_category("Explosion")
## Scène canonique instanciée lorsque les PV atteignent zéro.
@export var explosion_scene: PackedScene
## Réglages injectés dans l'explosion instanciée avant sa détonation.
@export var explosion_data: ExplosionData


func is_valid() -> bool:
	return (
		not str(prop_id).is_empty()
		and texture != null
		and maximum_health > 0.0
		and collision_size.x > 0.0
		and collision_size.y > 0.0
		and explosion_scene != null
		and explosion_data != null
		and explosion_data.is_valid()
	)
