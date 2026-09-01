@tool
class_name EnvironmentFX2D
extends Node2D

@export_category("Definition")
## Profil autoritaire des couleurs, quantités et intervalles de cet acte.
@export var profile: EnvironmentFXProfile:
	set(value):
		profile = value
		_refresh_from_profile()

@export_category("Authored Placement")
## Emprise de l'acte utilisée par le flash et l'aperçu éditeur.
@export var effect_size := Vector2(2560.0, 720.0):
	set(value):
		effect_size = value
		_refresh_from_profile()
		queue_redraw()
## Origine locale des cheminées ou panaches de fumée.
@export var smoke_origin := Vector2(1280.0, 410.0):
	set(value):
		smoke_origin = value
		_refresh_from_profile()
## Origine locale de la nappe toxique basse.
@export var fog_origin := Vector2(1280.0, 610.0):
	set(value):
		fog_origin = value
		_refresh_from_profile()
## Origine locale des étincelles industrielles.
@export var sparks_origin := Vector2(1280.0, 320.0):
	set(value):
		sparks_origin = value
		_refresh_from_profile()
## Décalage local du dessin d'éclair.
@export var lightning_origin := Vector2(1280.0, 40.0):
	set(value):
		lightning_origin = value
		_refresh_from_profile()

@export_category("Editor Preview")
## Affiche l'emprise de l'effet dans la scène maîtresse.
@export var show_effect_bounds := true:
	set(value):
		show_effect_bounds = value
		queue_redraw()
## Joue une frappe sans attendre le Timer runtime.
@export_tool_button("Prévisualiser l'éclair") var preview_lightning_button := preview_lightning

@onready var smoke: GPUParticles2D = %Smoke
@onready var toxic_fog: GPUParticles2D = %ToxicFog
@onready var sparks: GPUParticles2D = %Sparks
@onready var lightning: Node2D = %Lightning
@onready var flash: Polygon2D = %Flash
@onready var bolt_primary: Line2D = %BoltPrimary
@onready var bolt_secondary: Line2D = %BoltSecondary
@onready var lightning_timer: Timer = %LightningTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	_refresh_from_profile()
	if Engine.is_editor_hint() or profile == null or not profile.lightning_enabled:
		return
	_schedule_lightning()


func _draw() -> void:
	if not Engine.is_editor_hint() or not show_effect_bounds:
		return
	draw_rect(Rect2(Vector2.ZERO, effect_size), Color(0.62, 0.87, 1.0, 0.55), false, 2.0)


func preview_lightning() -> void:
	if profile == null or not profile.lightning_enabled or not is_node_ready():
		return
	animation_player.play(&"strike")


func _on_lightning_timer_timeout() -> void:
	if profile == null or not profile.lightning_enabled:
		return
	animation_player.play(&"strike")
	_schedule_lightning()


func _schedule_lightning() -> void:
	lightning_timer.start(randf_range(profile.lightning_interval_min, profile.lightning_interval_max))


func _refresh_from_profile() -> void:
	queue_redraw()
	if not is_node_ready() or profile == null:
		return
	smoke.position = smoke_origin
	toxic_fog.position = fog_origin
	sparks.position = sparks_origin
	lightning.position = lightning_origin
	smoke.amount = profile.smoke_amount
	smoke.modulate = profile.smoke_color
	smoke.emitting = profile.smoke_enabled
	toxic_fog.amount = profile.fog_amount
	toxic_fog.modulate = profile.fog_color
	toxic_fog.emitting = profile.fog_enabled
	sparks.amount = profile.sparks_amount
	sparks.modulate = profile.sparks_color
	sparks.emitting = profile.sparks_enabled
	flash.polygon = PackedVector2Array([
		-lightning_origin,
		Vector2(effect_size.x, 0.0) - lightning_origin,
		effect_size - lightning_origin,
		Vector2(0.0, effect_size.y) - lightning_origin,
	])
	flash.color = Color(profile.lightning_color, 0.14)
	bolt_primary.default_color = profile.lightning_color
	bolt_secondary.default_color = Color(profile.lightning_color, 0.72)
	lightning.visible = profile.lightning_enabled


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if profile == null:
		warnings.append("Assigner un EnvironmentFXProfile.")
	elif not profile.is_valid():
		warnings.append_array(profile.validation_errors())
	if effect_size.x <= 0.0 or effect_size.y <= 0.0:
		warnings.append("Effect Size doit être positif.")
	return warnings
