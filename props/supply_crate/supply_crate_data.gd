@tool
class_name SupplyCrateData
extends Resource

enum OpeningMode { SHOT_ONLY, INTERACTION_ONLY, SHOT_OR_INTERACTION }

@export_category("Identity")
## Identifiant stable de cette définition de caisse.
@export var crate_id: StringName
## Nom lisible présenté dans l'Inspector.
@export var display_name := "Caisse de ravitaillement"

@export_category("Presentation")
## PNG runtime affiché tant que la caisse est fermée.
@export var closed_texture: Texture2D
## PNG runtime affiché après ouverture ; il doit partager canevas et pivot.
@export var open_texture: Texture2D
## Pixel commun aux deux PNG aligné avec l'origine physique de la scène.
@export var pivot_px := Vector2.ZERO

@export_category("Opening")
## Choisit si les tirs, l'action d'interaction, ou les deux peuvent ouvrir la caisse.
@export var opening_mode: OpeningMode = OpeningMode.SHOT_OR_INTERACTION
## Résistance aux tirs avant ouverture ; ignorée si les tirs sont désactivés.
@export_range(1.0, 10000.0, 1.0) var maximum_health := 1.0
## Action Input Map demandée lorsque le joueur est dans la zone d'interaction.
@export var interaction_action: StringName = &"player_interact"
## Rayon autour de la caisse dans lequel l'action d'interaction est acceptée.
@export_range(16.0, 300.0, 1.0) var interaction_radius := 92.0

@export_category("Contents")
## Scène instanciée au ContentsOrigin lors de la première ouverture réussie.
@export var contents_scene: PackedScene

@export_category("Collision")
## Taille de la collision solide et tirable de la caisse fermée.
@export var collision_size := Vector2(300.0, 150.0)
## Position de la collision par rapport à l'origine posée au sol.
@export var collision_offset := Vector2(0.0, -76.0)
## Conserve l'obstacle physique après l'ouverture de la caisse.
@export var keep_collision_when_open := true


func accepts_shot() -> bool:
	return opening_mode != OpeningMode.INTERACTION_ONLY


func accepts_interaction() -> bool:
	return opening_mode != OpeningMode.SHOT_ONLY


func has_contents() -> bool:
	return contents_scene != null and contents_scene.can_instantiate()


func is_valid() -> bool:
	return (
		not str(crate_id).is_empty()
		and closed_texture != null
		and open_texture != null
		and closed_texture.get_size() == open_texture.get_size()
		and maximum_health > 0.0
		and not str(interaction_action).is_empty()
		and interaction_radius > 0.0
		and (contents_scene == null or contents_scene.can_instantiate())
		and collision_size.x > 0.0
		and collision_size.y > 0.0
	)
