@tool
class_name MissionMapDefinition
extends Resource

enum DestructionPolicy {
	NONE,
	AUTHORED_ZONES,
	FULL_RASTER,
}

@export_category("Identity")
## Identifiant stable utilisé par le catalogue, les transitions et la sauvegarde.
@export var map_id: StringName
## Nom lisible présenté dans l'interface et l'Inspecteur.
@export var display_name := "Mission"
## Ordre de progression dans la campagne solo.
@export_range(0, 999, 1) var campaign_order := 0

@export_category("Master Scene")
## Scène Godot autoritaire qui assemble visuel, gameplay, destruction et caméra.
@export_file("*.tscn") var scene_path := ""
## Aperçu utilisé par les menus de mission sans charger la scène complète.
@export var preview_texture: Texture2D

@export_category("World Contract")
## Dimensions du monde en pixels, indépendantes de la fenêtre.
@export var world_size := Vector2i(1920, 720)
## Politique de destruction autorisée pour cette carte.
@export var destruction_policy := DestructionPolicy.AUTHORED_ZONES
## Nombre maximal de reconstructions de terrain prévues sur une image.
@export_range(1, 16, 1) var destruction_updates_per_frame := 2


func is_valid() -> bool:
	return (
		not str(map_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and scene_path.begins_with("res://maps/missions/")
		and scene_path.ends_with(".tscn")
		and world_size.x >= 1280
		and world_size.y >= 720
	)

