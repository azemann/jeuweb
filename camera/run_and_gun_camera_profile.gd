@tool
class_name RunAndGunCameraProfile
extends Resource

@export_category("Horizontal Progression")
## Avance optionnelle du cadre dans la direction regardée. Laisser à zéro pour éviter tout mouvement lors d'un demi-tour.
@export_range(0.0, 500.0, 5.0) var forward_lookahead := 0.0
## Option arcade stricte. Désactivée pour permettre le retour libre dans une mission.
@export var lock_backward_progression := false

@export_category("Vertical Framing")
## Position verticale du joueur dans l'écran : 0 en haut, 0,5 au centre, 1 en bas.
@export_range(0.0, 1.0, 0.01) var vertical_center_ratio := 0.5

@export_category("Camera2D")
## Active l'interpolation native de Camera2D pour réduire les mouvements brusques.
@export var position_smoothing_enabled := true
## Vitesse du lissage natif ; une valeur élevée rejoint plus vite la position cible.
@export_range(1.0, 20.0, 0.5) var position_smoothing_speed := 6.0

@export_category("Combat Feedback")
## Déplacement maximal autorisé autour du cadre, indépendamment de la progression.
@export_range(0.0, 32.0, 0.5, "suffix:px") var maximum_shake_offset := 12.0
## Fréquence de vibration utilisée par les demandes de secousse des armes et effets.
@export_range(1.0, 80.0, 1.0, "suffix:Hz") var shake_frequency := 36.0


func is_valid() -> bool:
	return (
		forward_lookahead >= 0.0
		and vertical_center_ratio >= 0.0
		and vertical_center_ratio <= 1.0
		and position_smoothing_speed > 0.0
		and maximum_shake_offset >= 0.0
		and shake_frequency > 0.0
	)
