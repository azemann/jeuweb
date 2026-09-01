@tool
class_name WeaponData
extends Resource

@export_category("Identity")
## Identifiant stable utilisé pour équiper, référencer et plus tard sauvegarder cette arme.
@export var weapon_id: StringName
## Nom lisible de l'arme destiné à l'Inspector et aux futures interfaces d'équipement.
@export var display_name := "Arme"

@export_category("Fire")
## Scène canonique instanciée à chaque tir ; ses paramètres spécifiques viennent de sa ProjectileData.
@export var projectile_scene: PackedScene
## Temps minimal, en secondes, entre deux projectiles ; plus bas signifie une cadence plus élevée.
@export_range(0.03, 3.0, 0.01) var fire_interval := 0.15
## Si activé, maintenir l'action de tir enchaîne les coups ; sinon chaque coup exige un nouvel appui.
@export var automatic := true
## Cette arme consomme la réserve spéciale du PlayerCombatInventoryComponent.
@export var uses_special_ammo := false
## Quantité retirée de la réserve à chaque tir accepté.
@export_range(1, 10, 1) var ammo_cost := 1

@export_category("Presentation")
## Bitmap du canon équipé affiché sur le WeaponSprite du joueur.
@export var weapon_texture: Texture2D
## Échelle locale appliquée au bitmap d'arme équipé.
@export_range(0.05, 2.0, 0.05) var weapon_visual_scale := 0.28

@export_category("Feedback")
## Nom de l'animation jouée par le WeaponFeedback AnimationPlayer à chaque tir réussi.
@export var fire_animation: StringName = &"fire"
## Distance maximale, en pixels, du recul visuel commun au corps et au canon.
@export_range(0.0, 32.0, 0.5, "suffix:px") var body_recoil_distance := 7.0
## Amplitude demandée à la caméra de mission pour cette arme.
@export_range(0.0, 24.0, 0.5, "suffix:px") var camera_shake_strength := 4.0
## Durée de la secousse demandée à la caméra de mission.
@export_range(0.0, 0.5, 0.01, "suffix:s") var camera_shake_duration := 0.1


func is_valid() -> bool:
	return (
		not str(weapon_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and projectile_scene != null
		and projectile_scene.can_instantiate()
		and fire_interval > 0.0
		and ammo_cost > 0
		and weapon_visual_scale > 0.0
		and body_recoil_distance >= 0.0
		and camera_shake_strength >= 0.0
		and camera_shake_duration >= 0.0
	)
