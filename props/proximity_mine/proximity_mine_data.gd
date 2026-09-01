@tool
class_name ProximityMineData
extends Resource

@export_category("Identity")
## Identifiant stable de la mine.
@export var mine_id: StringName
@export_category("Presentation")
## Bitmap runtime publié.
@export var texture: Texture2D
## Pixel du canevas posé à l'origine.
@export var pivot_px := Vector2.ZERO
@export_category("Trigger")
## Rayon de détection des acteurs.
@export_range(8.0, 200.0, 1.0, "suffix:px") var trigger_radius := 72.0
@export_category("Explosion")
## Scène canonique instanciée au déclenchement.
@export var explosion_scene: PackedScene
## Définition autoritaire des dégâts et du terrain.
@export var explosion_data: ExplosionData


func is_valid() -> bool:
	return not str(mine_id).is_empty() and texture != null and trigger_radius > 0.0 and explosion_scene != null and explosion_scene.can_instantiate() and explosion_data != null and explosion_data.is_valid()
