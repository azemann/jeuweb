@tool
class_name BootStartFlowTheme
extends Resource

@export_group("Identity")
## Identifiant stable utilisé par les contrats et futures variantes visuelles.
@export var theme_id: StringName = &"industrial_toxic"
## Emblème visuel de l'univers, distinct d'un logo textuel ou d'une statistique.
@export var faction_emblem: Texture2D
## Plaque vierge sur laquelle Godot compose le titre localisable.
@export var title_plaque: Texture2D
## Cadre décoratif qui entoure les actions du menu sans posséder leur texte.
@export var main_menu_frame: Texture2D

@export_group("Backgrounds")
## Illustration du splash initial.
@export var boot_background: Texture2D
## Illustration réservée aux transitions ou chargements futurs.
@export var loading_background: Texture2D
## Illustration du menu principal.
@export var start_background: Texture2D
## Carte réservée au futur écran de sélection de mission.
@export var mission_select_background: Texture2D

@export_group("Menu Ornaments")
## Flèche de navigation au repos.
@export var previous_inactive: Texture2D
## Flèche utilisée comme indicateur réel du focus clavier ou manette.
@export var previous_active: Texture2D
## Verrou destiné aux actions ou destinations indisponibles.
@export var locked_ornament: Texture2D
## Séparateur décoratif horizontal.
@export var divider_ornament: Texture2D
## Lampe de statut positif ou disponible.
@export var lime_status_lamp: Texture2D
## Lampe de statut alternatif ou hostile.
@export var magenta_status_lamp: Texture2D

@export_group("Mission Markers")
## Marqueur de mission de débarquement.
@export var landing_marker: Texture2D
## Marqueur de mission liée aux pipelines.
@export var pipeline_marker: Texture2D
## Marqueur de mission de fonderie.
@export var foundry_marker: Texture2D
## Marqueur de mission de forteresse.
@export var fortress_marker: Texture2D
## Marqueur de mission élite.
@export var elite_marker: Texture2D
## Marqueur d'une mission terminée.
@export var completed_marker: Texture2D


func is_valid() -> bool:
	return validation_errors().is_empty()


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if theme_id.is_empty():
		errors.append("theme_id est obligatoire.")
	for property_name in _required_texture_properties():
		if get(property_name) == null:
			errors.append("%s doit référencer une Texture2D publiée." % property_name)
	return errors


func _required_texture_properties() -> PackedStringArray:
	return PackedStringArray([
		"faction_emblem", "title_plaque", "main_menu_frame",
		"boot_background", "loading_background", "start_background", "mission_select_background",
		"previous_inactive", "previous_active", "locked_ornament", "divider_ornament",
		"lime_status_lamp", "magenta_status_lamp", "landing_marker", "pipeline_marker",
		"foundry_marker", "fortress_marker", "elite_marker", "completed_marker",
	])
