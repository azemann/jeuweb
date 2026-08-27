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

@export_category("Feedback")
## Nom de l'animation jouée par le WeaponFeedback AnimationPlayer à chaque tir réussi.
@export var fire_animation: StringName = &"fire"


func is_valid() -> bool:
	return (
		not str(weapon_id).is_empty()
		and not display_name.strip_edges().is_empty()
		and projectile_scene != null
		and projectile_scene.can_instantiate()
		and fire_interval > 0.0
	)
