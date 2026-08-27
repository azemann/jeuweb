@tool
class_name GalleryEntry
extends Resource

## Titre lisible présenté dans l'interface de galerie.
@export var display_name := "Planche"
## Catégorie permettant de filtrer ou regrouper les planches sans dépendre de leur chemin.
@export var category: StringName = &"direction_art"
## Image finale affichée en plein écran ; elle doit être publiée sous res://art/.
@export var board_texture: Texture2D
