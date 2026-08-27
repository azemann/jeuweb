@tool
class_name EnemyArchetypeProfile
extends Resource

@export_category("Identity")
## Identifiant stable utilisé par le catalogue et les marqueurs de rencontre.
@export var archetype_id: StringName

@export_category("Integrity")
## Total de points de vie possédé par chaque nouvelle instance.
@export_range(1.0, 1000.0, 1.0) var maximum_health := 35.0
## Fenêtre, en secondes, pendant laquelle un nouvel impact est ignoré.
@export_range(0.0, 2.0, 0.01) var post_hit_invulnerability := 0.08

@export_category("Patrol")
## Vitesse horizontale de patrouille en pixels par seconde.
@export_range(0.0, 600.0, 1.0) var movement_speed := 70.0
## Accélération horizontale en pixels par seconde carrée.
@export_range(1.0, 3000.0, 1.0) var acceleration := 420.0
## Gravité appliquée en pixels par seconde carrée.
@export_range(0.0, 4000.0, 10.0) var gravity := 1100.0
## Vitesse de chute maximale en pixels par seconde.
@export_range(1.0, 3000.0, 10.0) var maximum_fall_speed := 900.0
## Distance maximale parcourue de chaque côté du point d'apparition.
@export_range(0.0, 1200.0, 8.0) var patrol_half_width := 96.0


func is_valid() -> bool:
	return (
		not str(archetype_id).is_empty()
		and maximum_health > 0.0
		and post_hit_invulnerability >= 0.0
		and movement_speed >= 0.0
		and acceleration > 0.0
		and gravity >= 0.0
		and maximum_fall_speed > 0.0
		and patrol_half_width >= 0.0
	)
