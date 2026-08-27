@tool
class_name RunAndGunCameraProfile
extends Resource

@export_category("Horizontal Progression")
## Avance du cadre, en pixels, dans la direction regardée afin de révéler les menaces.
@export_range(0.0, 500.0, 5.0) var forward_lookahead := 150.0
## Metal Slug : la caméra conserve la progression maximale atteinte vers la droite.
@export var lock_backward_progression := true

@export_category("Vertical Framing")
## Position verticale du joueur dans l'écran : 0 en haut, 0,5 au centre, 1 en bas.
@export_range(0.0, 1.0, 0.01) var vertical_center_ratio := 0.5

@export_category("Camera2D")
## Active l'interpolation native de Camera2D pour réduire les mouvements brusques.
@export var position_smoothing_enabled := true
## Vitesse du lissage natif ; une valeur élevée rejoint plus vite la position cible.
@export_range(1.0, 20.0, 0.5) var position_smoothing_speed := 6.0


func is_valid() -> bool:
	return (
		forward_lookahead >= 0.0
		and vertical_center_ratio >= 0.0
		and vertical_center_ratio <= 1.0
		and position_smoothing_speed > 0.0
	)
