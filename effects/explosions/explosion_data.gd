@tool
class_name ExplosionData
extends Resource

@export_category("Identity")
## Identifiant stable du profil d'explosion, indépendant de son consommateur.
@export var explosion_id: StringName
## Famille autorisant les outils à regrouper les profils sans déduire leur usage depuis un chemin.
@export var family_id: StringName
## Nom lisible présenté à l'auteur dans l'Inspector.
@export var display_name := "Explosion"

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

@export_category("VFX Composition")
## Animation peinte principale. Nulle conserve le fallback procédural de la scène canonique.
@export var sprite_frames: SpriteFrames
## Animation jouée dans Sprite Frames lors de la détonation.
@export var sprite_animation: StringName = &"detonate"
## Décalage de l'atlas par rapport au point d'impact posé au sol.
@export var sprite_offset := Vector2(0.0, -146.0)
## Échelle globale de toute la composition VFX, sans modifier les rayons gameplay.
@export_range(0.25, 3.0, 0.05) var visual_scale := 1.0
## Amplitude visuelle des deux ondes de choc superposées.
@export_range(0.25, 3.0, 0.05) var shockwave_scale := 1.0
## Intensité du flash lumineux local ; zéro désactive la lumière.
@export_range(0.0, 8.0, 0.1) var light_energy := 1.8
## Quantité d'étincelles additives émises au premier impact.
@export_range(0, 128, 1) var spark_amount := 20
## Quantité de fragments sombres projetés par l'explosion.
@export_range(0, 128, 1) var debris_amount := 10
## Quantité de gouttes chimiques colorées projetées au sol.
@export_range(0, 128, 1) var toxic_droplet_amount := 14


func is_valid() -> bool:
	return (
		not str(explosion_id).is_empty()
		and not str(family_id).is_empty()
		and terrain_radius > 0.0
		and damage_radius >= 0.0
		and damage >= 0.0
		and impulse >= 0.0
		and duration > 0.0
		and (sprite_frames == null or sprite_frames.has_animation(sprite_animation))
	)
