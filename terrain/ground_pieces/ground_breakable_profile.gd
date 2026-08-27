@tool
class_name GroundBreakableProfile
extends Resource

## Panneau de réglage partagé par les pièces en mode Breakable.
## Il décrit leur résistance et ce qui arrive à la scène lorsque ses PV tombent à zéro.

@export_category("Integrity")
## Nombre total de points de vie. Une valeur élevée demande davantage de tirs.
@export_range(1.0, 10000.0, 1.0) var maximum_health := 100.0
## Ratio de vie auquel la Damaged Texture devient visible. 0.35 signifie 35 %
## des PV restants. Ignoré si la définition ne fournit pas cette texture.
@export_range(0.0, 1.0, 0.01) var damaged_health_ratio := 0.35

@export_category("After Break")
## Désactive la collision au moment de la rupture pour libérer le passage.
@export var remove_collision_when_broken := true
## Supprime toute la scène après rupture. Laisser désactivé uniquement si la
## GroundPieceDefinition fournit une Destroyed Texture.
@export var remove_after_break := false


func is_valid() -> bool:
	return maximum_health > 0.0
