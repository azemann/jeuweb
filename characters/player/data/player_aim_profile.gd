@tool
class_name PlayerAimProfile
extends Resource

@export_category("Arcade Aim")
## Autorise les directions strictement verticales, nécessaires pour tirer au-dessus et sous le joueur.
@export var allow_vertical_aim := true
## Autorise les quatre diagonales en plus des directions horizontales et verticales.
@export var allow_diagonal_aim := true
## Intensité minimale de l'entrée directionnelle avant que la visée quitte sa direction précédente.
@export_range(0.1, 1.0, 0.05) var input_deadzone := 0.35
## Poids vertical appliqué lors d'une diagonale ; plus bas, il faut pousser davantage vers le haut ou le bas.
@export_range(0.0, 1.0, 0.05) var diagonal_vertical_weight := 0.82

@export_category("Pointer Aim")
## Active la visée vers le pointeur après un mouvement de souris.
@export var allow_pointer_aim := true
## Empêche une direction instable lorsque le pointeur est presque sur le pivot.
@export_range(1.0, 128.0, 1.0, "suffix:px") var pointer_minimum_distance := 24.0


func is_valid() -> bool:
	return input_deadzone > 0.0 and input_deadzone <= 1.0 and pointer_minimum_distance > 0.0
