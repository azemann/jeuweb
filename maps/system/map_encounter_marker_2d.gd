@tool
class_name MapEncounterMarker2D
extends Marker2D

@export_category("Encounter")
## Identité stable de cette occurrence dans la mission.
@export var encounter_id: StringName
## Recette Resource autoritaire des vagues, motifs et respirations de cette occurrence.
@export var encounter_data: EncounterData:
	set(value):
		encounter_data = value
		queue_redraw()
		update_configuration_warnings()
## Distance horizontale, en pixels, à laquelle la progression du joueur active la rencontre.
@export_range(64.0, 1600.0, 16.0) var activation_distance := 640.0
## Permet de neutraliser cette rencontre depuis l'Inspector sans effacer son placement.
@export var enabled := true

@export_category("Editor Preview")
## Dessine dans la scène maîtresse toutes les formations de la cadence.
@export var show_formation_preview := true:
	set(value):
		show_formation_preview = value
		queue_redraw()
## Rayon des silhouettes circulaires représentant les apparitions dans l'éditeur.
@export_range(4.0, 32.0, 1.0) var preview_radius := 10.0:
	set(value):
		preview_radius = value
		queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint() or not show_formation_preview or encounter_data == null:
		return
	var beat_colors := [
		Color(0.94, 0.13, 0.55, 0.82),
		Color(0.38, 0.83, 0.92, 0.82),
		Color(0.71, 0.84, 0.12, 0.82),
		Color(1.0, 0.64, 0.12, 0.9),
	]
	for wave_index in encounter_data.waves.size():
		var wave := encounter_data.waves[wave_index]
		if wave == null:
			continue
		var color: Color = beat_colors[wave.combat_beat]
		for pattern in wave.spawn_patterns:
			if pattern == null:
				continue
			for offset in pattern.authored_offsets():
				draw_line(Vector2.ZERO, offset, Color(color, 0.22), 1.0)
				draw_circle(offset, preview_radius + wave_index * 2.0, Color(color, 0.12), true)
				draw_arc(offset, preview_radius + wave_index * 2.0, 0.0, TAU, 24, color, 2.0)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if str(encounter_id).is_empty():
		warnings.append("Encounter ID est obligatoire et doit être unique dans la carte.")
	if encounter_data == null:
		warnings.append("Encounter Data est obligatoire.")
	elif not encounter_data.validation_errors().is_empty():
		warnings.append_array(encounter_data.validation_errors())
	return warnings
