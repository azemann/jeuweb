@tool
class_name ProjectileData
extends Resource

@export_category("Identity")
## Identifiant stable utilisé par les armes, registres et futurs systèmes de sauvegarde ou statistiques.
@export var projectile_id: StringName
## Nom lisible présenté dans l'Inspector et les futurs outils de contenu.
@export var display_name := "Projectile"

@export_category("Flight")
## Vitesse de déplacement, en pixels par seconde ; influence portée ressentie et facilité d'esquive.
@export_range(100.0, 4000.0, 10.0) var speed := 1200.0
## Durée maximale de vol, en secondes ; avec Speed, elle détermine la portée théorique.
@export_range(0.05, 10.0, 0.05) var lifetime := 1.5

@export_category("Impact")
## Dégâts infligés aux objets possédant apply_damage, notamment les Ground Pieces Breakable.
@export_range(0.0, 1000.0, 1.0) var damage := 10.0
## Force transmise à une cible compatible dans la direction du tir.
@export_range(0.0, 2000.0, 10.0) var impulse := 150.0
## Scène visuelle instanciée au point d'impact ; elle ne décide pas elle-même des dégâts du projectile.
@export var impact_scene: PackedScene

@export_category("Explosion optionnelle")
## Scène canonique instanciée au point de collision pour une munition explosive ; laisser vide avec Explosion Data pour un impact direct.
@export var explosion_scene: PackedScene
## Style, dégâts radiaux, terrain et temporalité injectés dans Explosion Scene ; les deux champs d'explosion sont assignés ou vides ensemble.
@export var explosion_data: ExplosionData

@export_category("Terrain Carvable")
## Autorise ce projectile à retirer localement la matière du DestructibleTerrain2D.
@export var affects_destructible_terrain := false
## Rayon du cratère en pixels. Petit pour une balle, large pour un projectile explosif.
@export_range(1.0, 300.0, 1.0) var terrain_radius := 10.0

@export_category("Presentation")
## Bitmap publié utilisé à la place des primitives Tracer/Core lorsqu'il est assigné.
@export var texture: Texture2D
## Échelle locale du bitmap de projectile sur son canevas normalisé.
@export_range(0.05, 2.0, 0.05) var texture_scale := 0.35
## Couleur de la traînée extérieure, généralement accordée à la faction ou au type de munition.
@export_color_no_alpha var tracer_color := Color("f1f59a")
## Couleur du noyau central, plus lumineux pour rester lisible sur les décors chargés.
@export_color_no_alpha var core_color := Color("ffffff")
## Longueur visuelle de la traînée, en pixels, sans modifier collision, vitesse ni portée.
@export_range(4.0, 80.0, 1.0) var tracer_length := 30.0
## Épaisseur visuelle de la traînée, en pixels, sans modifier la forme physique du projectile.
@export_range(1.0, 24.0, 1.0) var tracer_width := 7.0


func is_valid() -> bool:
	return (
		not str(projectile_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and speed > 0.0
		and lifetime > 0.0
		and damage >= 0.0
		and _explosion_binding_is_valid()
		and (not affects_destructible_terrain or terrain_radius > 0.0)
		and tracer_length > 0.0
		and tracer_width > 0.0
		and texture_scale > 0.0
	)


func has_explosion() -> bool:
	return explosion_scene != null and explosion_data != null


func _explosion_binding_is_valid() -> bool:
	if explosion_scene == null and explosion_data == null:
		return true
	return (
		explosion_scene != null
		and explosion_scene.can_instantiate()
		and explosion_data != null
		and explosion_data.is_valid()
	)
