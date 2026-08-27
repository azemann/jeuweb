@tool
class_name GroundKitCatalog
extends Resource

const GroundPiece2DType = preload("res://terrain/ground_pieces/ground_piece_2d.gd")

@export_category("Identity")
## Identifiant stable du kit, utilisé par les outils de sélection et les contrats de contenu.
@export var kit_id: StringName
## Nom lisible du kit indiquant son biome ou sa famille artistique dans l'Inspector.
@export var display_name := "Ground kit"

@export_category("Pieces")
## Scènes canoniques que le level designer peut glisser dans une map depuis ce kit.
@export var pieces: Array[PackedScene] = []


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(kit_id).is_empty():
		errors.append("Kit ID ne peut pas être vide.")
	if display_name.strip_edges().is_empty():
		errors.append("Display Name ne peut pas être vide.")
	var known_ids: Dictionary = {}
	for packed in pieces:
		if packed == null or not packed.can_instantiate():
			errors.append("Chaque entrée du kit doit être une PackedScene instanciable.")
			continue
		var instance := packed.instantiate()
		if instance.get_script() != GroundPiece2DType:
			errors.append("La scène '%s' ne produit pas un GroundPiece2D canonique." % packed.resource_path)
			instance.free()
			continue
		var definition = instance.definition
		if definition == null or str(definition.piece_id).is_empty():
			errors.append("La scène '%s' doit référencer une définition identifiée." % packed.resource_path)
			instance.free()
			continue
		if known_ids.has(definition.piece_id):
			errors.append("piece_id '%s' est dupliqué dans le kit." % definition.piece_id)
		else:
			known_ids[definition.piece_id] = true
		for piece_error in instance.validation_errors():
			errors.append("%s : %s" % [definition.piece_id, piece_error])
		instance.free()
	return errors


func scene_for(piece_id: StringName) -> PackedScene:
	for packed in pieces:
		if packed == null or not packed.can_instantiate():
			continue
		var instance := packed.instantiate()
		var matches: bool = (
			instance.get_script() == GroundPiece2DType
			and instance.definition != null
			and instance.definition.piece_id == piece_id
		)
		instance.free()
		if matches:
			return packed
	return null
