@tool
class_name MapEncounterMarker2D
extends Marker2D

@export_category("Encounter")
## Identité stable de cette occurrence dans la mission.
@export var encounter_id: StringName:
	set(value):
		encounter_id = value
		update_configuration_warnings()
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

@export_category("Authoring Actions")
## Recalcule un identifiant snake_case depuis le nom du Marker et évite les collisions entre frères.
@export_tool_button("Générer un Encounter ID unique") var generate_unique_id_button := editor_generate_unique_id

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


func editor_generate_unique_id() -> void:
	var base_id := String(name).to_snake_case()
	if base_id.is_empty():
		base_id = "encounter"
	var sibling_ids: Dictionary = {}
	if get_parent() != null:
		for sibling in get_parent().get_children():
			if sibling is MapEncounterMarker2D and sibling != self:
				sibling_ids[String(sibling.encounter_id)] = true
	var candidate := base_id
	var suffix := 2
	while sibling_ids.has(candidate):
		candidate = "%s_%d" % [base_id, suffix]
		suffix += 1
	encounter_id = StringName(candidate)
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if str(encounter_id).is_empty():
		warnings.append("Encounter ID est obligatoire et doit être unique dans la carte.")
	elif get_parent() != null:
		for sibling in get_parent().get_children():
			if sibling is MapEncounterMarker2D and sibling != self and sibling.encounter_id == encounter_id:
				warnings.append("Encounter ID '%s' est déjà utilisé par %s. Utiliser « Générer un Encounter ID unique » après une duplication." % [encounter_id, sibling.name])
				break
	if encounter_data == null:
		warnings.append("Encounter Data est obligatoire.")
	elif not encounter_data.validation_errors().is_empty():
		warnings.append_array(encounter_data.validation_errors())
	elif encounter_data.resource_path.contains("::") or encounter_data.resource_path.is_empty():
		warnings.append("Encounter Data est intégrée à la scène. L'enregistrer en .tres pour en faire une recette auteur explicite et réutilisable.")
	return warnings
