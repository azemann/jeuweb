@tool
class_name GroundPieceDefinition
extends Resource

const GroundBreakableProfileType = preload("res://terrain/ground_pieces/ground_breakable_profile.gd")

enum Category {
	NATURAL,
	MILITARY,
	METAL,
	HAZARD,
}

enum CollisionSource {
	ALPHA,
	AUTHORED_OUTLINE,
}

enum RecommendedMode {
	PERMANENT,
	CARVABLE,
	BREAKABLE,
}

@export_category("Identity")
## Identifiant stable de la forme, indépendant du nom du PNG ou de la scène publiée.
@export var piece_id: StringName
## Nom lisible présenté au level designer dans l'Inspector et les futurs outils de kit.
@export var display_name := "Ground piece"
## Famille artistique servant au classement : naturel, architecture ou décoration.
@export var category: Category = Category.NATURAL
## Mots-clés libres permettant de rechercher la pièce par biome, rôle ou matériau.
@export var tags := PackedStringArray()

@export_category("Presentation")
## PNG runtime intact ; il constitue aussi l'aperçu canonique de la scène glissable.
@export var texture: Texture2D
## Point du canevas publié placé sur l'origine du Node.
@export var pivot_px := Vector2.ZERO
## Ordre de dessin proposé à toutes les instances avant une éventuelle surcharge locale.
@export var default_z_index := 0
## Orientation horizontale proposée lors de la création d'une nouvelle instance.
@export var default_flip_h := false
## Variante affichée sous le seuil Damaged Health Ratio du profil cassable.
## Conserver exactement le même canevas et le même pivot que Texture.
@export var damaged_texture: Texture2D
## Variante finale affichée à zéro PV lorsque Remove After Break est désactivé.
## Conserver exactement le même canevas et le même pivot que Texture.
@export var destroyed_texture: Texture2D

@export_category("Geometry")
## Autorité de collision : contour dérivé de l'alpha du PNG ou contour dessiné manuellement.
@export var collision_source: CollisionSource = CollisionSource.ALPHA
## Seuil d'opacité utilisé pour considérer un pixel solide lors de l'extraction automatique.
@export_range(0.01, 0.99, 0.01) var alpha_threshold := 0.5
## Tolérance, en pixels, de simplification du contour ; élevée, elle réduit le coût mais perd du détail.
@export_range(0.0, 16.0, 0.25) var simplification := 2.0
## Contour local relatif au pivot, actif uniquement avec AUTHORED_OUTLINE.
@export var authored_outline := PackedVector2Array()
## Nombre de premiers points du contour formant, dans leur ordre, la surface de marche auteur.
@export_range(0, 256, 1) var walk_surface_point_count := 0
## Masque alpha optionnel. Sa taille doit être identique à celle de Texture.
@export var material_mask: Texture2D

@export_category("Recommended Behavior")
## Mode proposé par la scène publiée. Chaque instance de map peut ensuite choisir
## indépendamment Permanent, Carvable ou Breakable.
@export var recommended_mode: RecommendedMode = RecommendedMode.CARVABLE
## Résistance disponible lorsque l'instance choisit Breakable. Cette Resource
## peut être partagée par plusieurs pièces possédant la même robustesse.
@export var breakable_profile: GroundBreakableProfileType


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(piece_id).is_empty():
		errors.append("Piece ID ne peut pas être vide.")
	if display_name.strip_edges().is_empty():
		errors.append("Display Name ne peut pas être vide.")
	if texture == null:
		errors.append("Texture est obligatoire.")
	if collision_source == CollisionSource.AUTHORED_OUTLINE and authored_outline.size() < 3:
		errors.append("Authored Outline exige au moins trois points.")
	if collision_source == CollisionSource.AUTHORED_OUTLINE:
		if walk_surface_point_count < 2 or walk_surface_point_count > authored_outline.size():
			errors.append("Walk Surface Point Count doit désigner au moins deux points du contour auteur.")
	if collision_source == CollisionSource.ALPHA and texture != null and geometry_polygons().is_empty():
		errors.append("L'alpha de Texture ne produit aucun contour.")
	if material_mask != null and texture != null:
		var mask := material_mask.get_image()
		var color := texture.get_image()
		if mask == null or color == null or mask.get_size() != color.get_size():
			errors.append("Material Mask doit avoir la même taille que Texture.")
	if damaged_texture != null and texture != null and damaged_texture.get_size() != texture.get_size():
		errors.append("Damaged Texture doit avoir la même taille que Texture.")
	if destroyed_texture != null and texture != null and destroyed_texture.get_size() != texture.get_size():
		errors.append("Destroyed Texture doit avoir la même taille que Texture.")
	if recommended_mode == RecommendedMode.BREAKABLE:
		if breakable_profile == null or not breakable_profile.is_valid():
			errors.append("Breakable Profile est obligatoire pour le mode conseillé Breakable.")
	if (
		breakable_profile != null
		and not breakable_profile.remove_after_break
		and destroyed_texture == null
	):
		errors.append("Une pièce cassable conservée après rupture exige une Destroyed Texture.")
	return errors


func is_valid() -> bool:
	return validation_errors().is_empty()


func texture_image() -> Image:
	if texture == null:
		return null
	var image := texture.get_image()
	return image if image != null and not image.is_empty() else null


func mask_image() -> Image:
	var source := material_mask if material_mask != null else texture
	if source == null:
		return null
	var image := source.get_image()
	return image if image != null and not image.is_empty() else null


func geometry_polygons() -> Array[PackedVector2Array]:
	var result: Array[PackedVector2Array] = []
	if collision_source == CollisionSource.AUTHORED_OUTLINE:
		if authored_outline.size() >= 3:
			result.append(authored_outline.duplicate())
		return result
	var image := mask_image()
	if image == null:
		return result
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(image, alpha_threshold)
	var polygons := bitmap.opaque_to_polygons(
		Rect2i(Vector2i.ZERO, image.get_size()), simplification
	)
	for polygon in polygons:
		var local_polygon := PackedVector2Array()
		for point in polygon:
			local_polygon.append(point - pivot_px)
		result.append(local_polygon)
	return result


func walk_surface() -> PackedVector2Array:
	if (
		collision_source != CollisionSource.AUTHORED_OUTLINE
		or walk_surface_point_count < 2
		or walk_surface_point_count > authored_outline.size()
	):
		return PackedVector2Array()
	return authored_outline.slice(0, walk_surface_point_count)
