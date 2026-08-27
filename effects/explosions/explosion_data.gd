@tool
class_name ExplosionData
extends Resource

@export_category("Terrain")
## Autorise l'explosion à demander un cratère au DestructibleTerrain2D rencontré.
@export var affects_destructible_terrain := true
## Rayon, en pixels, de matière retirée du terrain Carvable.
@export_range(8.0, 300.0, 1.0) var terrain_radius := 64.0

@export_category("Combat")
## Rayon, en pixels, dans lequel personnages et objets peuvent recevoir l'impact.
@export_range(0.0, 300.0, 1.0) var damage_radius := 88.0
## Quantité de dégâts proposée à chaque cible située dans Damage Radius.
@export_range(0.0, 1000.0, 1.0) var damage := 45.0
## Force radiale transmise aux cibles compatibles ; zéro désactive la poussée.
@export_range(0.0, 3000.0, 10.0) var impulse := 720.0

@export_category("Timing")
## Durée totale, en secondes, de l'animation et de la présence de la scène d'explosion.
@export_range(0.05, 2.0, 0.01) var duration := 0.42

@export_category("Palette")
## Couleur du flash initial, volontairement la plus lumineuse de l'effet.
@export_color_no_alpha var flash_color := Color("fff3a3")
## Couleur principale du volume de feu pendant l'expansion.
@export_color_no_alpha var fire_color := Color("ff681f")
## Couleur des formes résiduelles de fumée pendant la dissipation.
@export_color_no_alpha var smoke_color := Color("582d63")


func is_valid() -> bool:
	return (
		terrain_radius > 0.0
		and damage_radius >= terrain_radius
		and damage >= 0.0
		and impulse >= 0.0
		and duration > 0.0
	)
