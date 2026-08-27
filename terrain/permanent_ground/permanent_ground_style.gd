@tool
class_name PermanentGroundStyle
extends Resource

@export_category("Identity")
## Identifiant stable du matériau de sol, partageable entre plusieurs modules de formes différentes.
@export var style_id: StringName
## Nom lisible présenté au level designer lorsqu'il choisit le panneau de style.
@export var display_name := "Sol permanent"

@export_category("Fill")
## Texture répétée à l'intérieur du volume permanent ; la forme reste définie par chaque module.
@export var fill_texture: Texture2D
## Teinte multiplicative du remplissage ; blanc conserve les couleurs originales du PNG.
@export var fill_color := Color.WHITE
## Décalage UV, en pixels de texture, permettant d'éviter des répétitions alignées entre modules.
@export var texture_offset := Vector2.ZERO
## Échelle UV de la texture ; ne change ni la taille ni la collision du module.
@export var texture_scale := Vector2.ONE

@export_category("Surface")
## Texture appliquée à la ligne supérieure pour distinguer immédiatement la zone praticable.
@export var surface_texture: Texture2D
## Teinte multiplicative de la bande de surface ; blanc conserve la texture intacte.
@export var surface_color := Color.WHITE
## Largeur visuelle, en pixels, de la bande suivant Surface Path ; sans influence physique.
@export_range(2.0, 96.0, 1.0) var surface_width := 24.0


func is_valid() -> bool:
	return (
		not str(style_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and fill_texture != null
		and surface_texture != null
		and texture_scale.x > 0.0
		and texture_scale.y > 0.0
		and surface_width > 0.0
	)
