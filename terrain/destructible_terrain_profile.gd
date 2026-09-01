@tool
class_name DestructibleTerrainProfile
extends Resource

@export_category("Canvas And Chunks")
## Dimensions totales, en pixels, du masque destructible ; elles doivent couvrir la MissionMapDefinition.
@export var world_size := Vector2i(1920, 720)
## Taille carrée des morceaux reconstruits après un impact ; petite = précis mais davantage de Nodes.
@export_enum("64", "128", "256") var chunk_size := 128
## Tolérance, en pixels, appliquée aux contours physiques ; élevée réduit les sommets et le coût CPU.
@export_range(0.5, 8.0, 0.25) var collision_simplification := 2.0
## Aire minimale, en pixels carrés, conservée comme collision ; élimine les poussières et petits îlots.
@export_range(1.0, 1024.0, 1.0) var minimum_polygon_area := 12.0

@export_category("Performance Budgets")
## Nombre maximal de StaticBody2D de chunks accepté après une génération complète.
@export_range(1, 512, 1) var maximum_chunk_bodies := 96
## Nombre maximal de formes physiques dérivées accepté pour toute la carte.
@export_range(1, 2048, 1) var maximum_collision_shapes := 256
## Nombre maximal de chunks reconstruits dans un même flush différé d'impacts.
@export_range(1, 64, 1) var maximum_chunks_per_flush := 9

@export_category("Visual Surface")
## Texture de la couche proche de l'air, révélée autour de la surface intacte.
@export var shallow_texture: Texture2D
## Texture principale occupant la majorité du volume destructible.
@export var main_texture: Texture2D
## Texture des zones profondes, utilisée pour donner de l'épaisseur aux grandes coupes.
@export var deep_texture: Texture2D
## Bande dessinée le long du contour auteur initial avant toute destruction.
@export var intact_surface_texture: Texture2D
## Bande révélée sur les bords nouvellement creusés afin de rendre chaque impact lisible.
@export var fresh_cut_surface_texture: Texture2D
## Profondeur, en pixels, de la couche visuelle superficielle sous le contour exposé.
@export_range(2, 64, 1) var surface_depth := 20
## Épaisseur, en pixels, des bandes de contour intactes ou fraîchement coupées.
@export_range(1, 12, 1) var edge_thickness := 3

@export_category("Fallback Palette")
## Couleur utilisée pour la couche superficielle lorsque Shallow Texture est absente.
@export var shallow_color := Color("556b2f")
## Couleur utilisée pour le volume principal lorsque Main Texture est absente.
@export var main_color := Color("35462c")
## Couleur utilisée dans la profondeur lorsque Deep Texture est absente.
@export var deep_color := Color("172f2a")
## Couleur de la surface intacte lorsque sa texture dédiée est absente.
@export var edge_color := Color("b5d61f")
## Couleur des bords fraîchement creusés lorsque leur texture dédiée est absente.
@export var fresh_cut_color := Color("f1f59a")

@export_category("Determinism")
## Graine stable des variations procédurales ; identique, elle reproduit le même rendu de terrain.
@export var seed := 1701


func is_valid() -> bool:
	return (
		world_size.x >= 1280
		and world_size.y >= 720
		and chunk_size > 0
		and collision_simplification > 0.0
		and maximum_chunk_bodies > 0
		and maximum_collision_shapes > 0
		and maximum_chunks_per_flush > 0
	)


func performance_budget_errors(chunk_bodies: int, collision_shapes: int) -> PackedStringArray:
	var errors := PackedStringArray()
	if chunk_bodies > maximum_chunk_bodies:
		errors.append("Le terrain utilise %d chunks physiques pour un budget de %d." % [chunk_bodies, maximum_chunk_bodies])
	if collision_shapes > maximum_collision_shapes:
		errors.append("Le terrain utilise %d formes physiques pour un budget de %d." % [collision_shapes, maximum_collision_shapes])
	return errors
