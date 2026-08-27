@tool
class_name MapSegment2D
extends Node2D

enum SegmentRole {
	INTRODUCTION,
	ESCALATION,
	CLIMAX,
}

@export_category("Identity")
## Identifiant stable utilisé par les contrats de progression et les outils auteur.
@export var segment_id: StringName:
	set(value):
		segment_id = value
		update_configuration_warnings()
## Nom lisible utilisé par les outils de level design et la documentation de mission.
@export var display_name := "Segment"
## Position de ce segment dans la progression ; les indices doivent rester continus depuis zéro.
@export_range(0, 99, 1) var sequence_index := 0
## Fonction de rythme du segment : introduction, escalade ou conclusion.
@export var role := SegmentRole.INTRODUCTION

@export_category("Authored Bounds")
## Taille du segment dans le repère de la carte. Sa position vient du Node2D.
@export var size := Vector2(1280, 720):
	set(value):
		size = value
		queue_redraw()
		update_configuration_warnings()

@export_category("Authoring Intent")
## Note de game design décrivant ce que le joueur doit apprendre, ressentir ou maîtriser ici.
@export_multiline var gameplay_intent := ""
## Couleur de l'aplat et du contour visibles uniquement dans l'éditeur pour distinguer le segment.
@export var editor_color := Color(0.94, 0.13, 0.55, 0.72):
	set(value):
		editor_color = value
		queue_redraw()


func authored_bounds() -> Rect2:
	return Rect2(position, size)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(editor_color, 0.04), true)
	draw_rect(Rect2(Vector2.ZERO, size), editor_color, false, 3.0)
	draw_line(Vector2(0, 36), Vector2(minf(size.x, 300.0), 36), editor_color, 2.0)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if str(segment_id).is_empty():
		warnings.append("Segment ID est obligatoire et doit être unique dans la carte.")
	if display_name.strip_edges().is_empty():
		warnings.append("Le nom lisible du segment est obligatoire.")
	if size.x <= 0.0 or size.y <= 0.0:
		warnings.append("Les dimensions du segment doivent être positives.")
	if gameplay_intent.strip_edges().is_empty():
		warnings.append("Décrire brièvement l'intention de gameplay du segment.")
	return warnings
