@tool
class_name MissionMapRoot2D
extends Node2D

const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")
const AUTHORING_PREVIEW_GROUP := &"map_authoring_preview"

const REQUIRED_GAMEPLAY_BRANCHES := [
	"Segments",
	"SpawnPoints",
	"EnemySpawns",
	"Encounters",
	"GroundPieces",
	"DestructibleZones",
	"IndestructibleGeometry",
	"Hazards",
	"Interactions",
	"CameraZones",
	"Exits",
]

@export_category("Identity")
## Définition autoritaire de cette scène ; son scene_path et ses dimensions doivent correspondre à la map.
@export var definition: MissionMapDefinition:
	set(value):
		definition = value
		update_configuration_warnings()
## Point d'apparition utilisé lorsqu'aucun checkpoint ou spawn explicite n'est demandé.
@export var default_spawn_id: StringName = &"player_start"

@export_category("Scene Composition")
## Branche contenant uniquement décors, parallaxes et couches visuelles de la mission.
@export_node_path("Node2D") var visual_root_path := NodePath("Visual")
## Branche auteur contenant segments, sols, dangers, interactions et marqueurs.
@export_node_path("Node2D") var gameplay_root_path := NodePath("Gameplay")
## Branche runtime recevant joueur, ennemis, projectiles et effets instanciés.
@export_node_path("Node2D") var actors_root_path := NodePath("Actors")

@export_category("Camera")
## Rectangle mondial, en pixels, que la caméra ne doit jamais dépasser.
@export var camera_bounds := Rect2(0, 0, 1920, 720)

@export_category("Editor Preview")
## Affiche dans l'éditeur les silhouettes et zones servant à construire la map.
## Ces repères restent toujours invisibles lorsque le jeu est lancé.
@export var show_authoring_previews := true:
	set(value):
		show_authoring_previews = value
		if is_inside_tree():
			call_deferred(&"_sync_authoring_previews")


func _ready() -> void:
	_sync_authoring_previews()


func _sync_authoring_previews() -> void:
	if not is_inside_tree():
		return
	var previews_are_visible := Engine.is_editor_hint() and show_authoring_previews
	for node in get_tree().get_nodes_in_group(AUTHORING_PREVIEW_GROUP):
		if node is CanvasItem and is_ancestor_of(node):
			(node as CanvasItem).visible = previews_are_visible


func map_id() -> StringName:
	return definition.map_id if definition != null else &""


func visual_root() -> Node2D:
	return get_node_or_null(visual_root_path) as Node2D


func gameplay_root() -> Node2D:
	return get_node_or_null(gameplay_root_path) as Node2D


func actors_root() -> Node2D:
	return get_node_or_null(actors_root_path) as Node2D


func authored_segments() -> Array[MapSegment2D]:
	var result: Array[MapSegment2D] = []
	var root := gameplay_root()
	var segments_root := root.get_node_or_null("Segments") if root != null else null
	if segments_root == null:
		return result
	for child in segments_root.get_children():
		var segment := child as MapSegment2D
		if segment != null:
			result.append(segment)
	result.sort_custom(func(a: MapSegment2D, b: MapSegment2D) -> bool: return a.sequence_index < b.sequence_index)
	return result


func find_spawn(spawn_id: StringName) -> MapSpawnPoint2D:
	var root := gameplay_root()
	var spawn_root := root.get_node_or_null("SpawnPoints") if root != null else null
	if spawn_root == null:
		return null
	for child in spawn_root.get_children():
		var spawn := child as MapSpawnPoint2D
		if spawn != null and spawn.spawn_id == spawn_id:
			return spawn
	return null


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if definition == null or not definition.is_valid():
		errors.append("MissionMapDefinition absente ou invalide.")
	elif not scene_file_path.is_empty() and definition.scene_path != scene_file_path:
		errors.append("La scène maîtresse ne correspond pas au scene_path de sa définition.")
	if visual_root() == null:
		errors.append("La branche Visual est introuvable.")
	if gameplay_root() == null:
		errors.append("La branche Gameplay est introuvable.")
	else:
		_validate_gameplay_branches(errors)
	if actors_root() == null:
		errors.append("La branche Actors est introuvable.")
	if str(default_spawn_id).is_empty() or find_spawn(default_spawn_id) == null:
		errors.append("Le point d'apparition par défaut est absent.")
	if camera_bounds.size.x <= 0.0 or camera_bounds.size.y <= 0.0:
		errors.append("Les limites caméra doivent avoir une taille positive.")
	elif definition != null and camera_bounds.size != Vector2(definition.world_size):
		errors.append("Les limites caméra doivent correspondre à world_size.")
	return errors


func _validate_gameplay_branches(errors: PackedStringArray) -> void:
	var root := gameplay_root()
	for branch_name in REQUIRED_GAMEPLAY_BRANCHES:
		if root.get_node_or_null(branch_name) == null:
			errors.append("Gameplay/%s est obligatoire." % branch_name)
	_validate_unique_markers(root.get_node_or_null("SpawnPoints"), &"spawn_id", errors)
	_validate_unique_markers(root.get_node_or_null("EnemySpawns"), &"encounter_id", errors)
	_validate_segments(errors)
	_validate_ground_pieces(root.get_node_or_null("GroundPieces"), errors)


func _validate_ground_pieces(parent: Node, errors: PackedStringArray) -> void:
	if parent == null:
		return
	for child in parent.find_children("*", "GroundPiece2D", true, false):
		var piece := child as GroundPiece2DType
		if piece == null:
			continue
		for piece_error in piece.validation_errors():
			var relative_path := parent.get_path_to(piece)
			errors.append("Gameplay/GroundPieces/%s : %s" % [relative_path, piece_error])


func _validate_segments(errors: PackedStringArray) -> void:
	var segments := authored_segments()
	if segments.is_empty():
		errors.append("Gameplay/Segments doit contenir au moins un MapSegment2D.")
		return
	var known_ids: Dictionary = {}
	var expected_x := 0.0
	for index in segments.size():
		var segment := segments[index]
		if str(segment.segment_id).is_empty():
			errors.append("Segments/%s doit renseigner segment_id." % segment.name)
		elif known_ids.has(segment.segment_id):
			errors.append("segment_id '%s' est dupliqué." % segment.segment_id)
		else:
			known_ids[segment.segment_id] = true
		if segment.sequence_index != index:
			errors.append("Segments/%s doit avoir sequence_index=%d." % [segment.name, index])
		if not is_equal_approx(segment.position.x, expected_x):
			errors.append("Segments/%s doit commencer à x=%d sans trou ni chevauchement." % [segment.name, roundi(expected_x)])
		if not is_equal_approx(segment.position.y, 0.0):
			errors.append("Segments/%s doit commencer à y=0." % segment.name)
		if definition != null and not is_equal_approx(segment.size.y, float(definition.world_size.y)):
			errors.append("Segments/%s doit couvrir toute la hauteur du monde." % segment.name)
		expected_x = segment.position.x + segment.size.x
	if definition != null and not is_equal_approx(expected_x, float(definition.world_size.x)):
		errors.append("Les segments doivent couvrir exactement world_size.x.")


func _validate_unique_markers(parent: Node, property_name: StringName, errors: PackedStringArray) -> void:
	if parent == null:
		return
	var known: Dictionary = {}
	for child in parent.get_children():
		var value: Variant = child.get(property_name)
		if value == null or str(value).is_empty():
			errors.append("%s/%s doit renseigner %s." % [parent.name, child.name, property_name])
		elif known.has(value):
			errors.append("%s '%s' est dupliqué." % [property_name, value])
		else:
			known[value] = true


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
