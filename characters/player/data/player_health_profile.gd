@tool
class_name PlayerHealthProfile
extends Resource

@export_category("Integrity")
## Total de points de vie restauré à l'apparition et utilisé comme maximum par le HUD.
@export_range(1.0, 1000.0, 1.0) var maximum_health := 100.0
## Durée, en secondes, pendant laquelle les nouveaux impacts sont ignorés après un dégât reçu.
@export_range(0.0, 5.0, 0.05) var post_hit_invulnerability := 0.65


func is_valid() -> bool:
	return maximum_health > 0.0 and post_hit_invulnerability >= 0.0
