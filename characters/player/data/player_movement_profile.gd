@tool
class_name PlayerMovementProfile
extends Resource

@export_category("Horizontal Movement")
## Vitesse horizontale maximale au sol, en pixels par seconde.
@export_range(50.0, 800.0, 5.0) var maximum_speed := 285.0
## Accélération au sol, en pixels par seconde carrée ; élevée, elle rend le départ plus nerveux.
@export_range(100.0, 5000.0, 25.0) var ground_acceleration := 1900.0
## Freinage au sol, en pixels par seconde carrée ; élevé, il réduit la glisse au relâchement.
@export_range(100.0, 5000.0, 25.0) var ground_deceleration := 2400.0
## Multiplicateur de contrôle horizontal en l'air par rapport à l'accélération au sol.
@export_range(0.0, 1.0, 0.05) var air_control := 0.72

@export_category("Jump And Gravity")
## Impulsion verticale initiale du saut, en pixels par seconde ; élevée, elle augmente la hauteur.
@export_range(100.0, 1200.0, 5.0) var jump_speed := 570.0
## Accélération verticale, en pixels par seconde carrée, appliquée tant que le joueur est en l'air.
@export_range(100.0, 4000.0, 25.0) var gravity := 1750.0
## Vitesse de chute maximale, en pixels par seconde, pour garder les descentes contrôlables.
@export_range(100.0, 2000.0, 10.0) var maximum_fall_speed := 980.0
## Tolérance, en secondes, permettant de sauter juste après avoir quitté un rebord.
@export_range(0.0, 0.3, 0.01) var coyote_time := 0.1
## Durée, en secondes, pendant laquelle une commande de saut anticipée reste mémorisée avant l'atterrissage.
@export_range(0.0, 0.3, 0.01) var jump_buffer_time := 0.12


func is_valid() -> bool:
	return (
		maximum_speed > 0.0
		and ground_acceleration > 0.0
		and ground_deceleration > 0.0
		and jump_speed > 0.0
		and gravity > 0.0
		and maximum_fall_speed > 0.0
	)
