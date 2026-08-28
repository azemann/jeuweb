@tool
class_name ActorSlopePresentationComponent
extends Node

@export_category("Correspondence")
## CharacterBody2D utilisé pour distinguer contact au sol et état aérien.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")
## Grounding partagé qui mesure la tangente entre les appuis gauche et droit.
@export_node_path("ActorGroundingComponent") var grounding_path := NodePath("../Grounding")
## Pivot visuel situé au root des pieds ; seul ce Node s'incline, jamais la collision.
@export_node_path("Node2D") var slope_visual_path := NodePath("../../Visuals/GroundPivot")

@export_category("Slope Follow")
## Fraction de l'angle physique appliquée à la présentation, de corps droit à suivi intégral.
@export_range(0.0, 1.0, 0.05) var follow_ratio := 1.0
## Inclinaison visuelle maximale autorisée, en degrés, quelle que soit la pente physique.
@export_range(0.0, 60.0, 1.0) var maximum_visual_tilt_degrees := 42.0
## Les angles inférieurs à ce seuil restent visuellement plats pour éviter le bruit.
@export_range(0.0, 12.0, 0.5) var flat_deadzone_degrees := 1.5
## Vitesse de convergence vers la pente ou vers zéro pendant un saut.
@export_range(0.0, 60.0, 1.0) var smoothing_speed := 18.0

var visual_angle := 0.0


func _ready() -> void:
	set_physics_process(not Engine.is_editor_hint() and validation_errors().is_empty())


func _physics_process(delta: float) -> void:
	var requested := 0.0
	var body := body()
	var grounding := grounding()
	if body.is_on_floor() and grounding.has_ground_projection:
		requested = grounding.floor_angle
		if absf(rad_to_deg(requested)) < flat_deadzone_degrees:
			requested = 0.0
		requested = clampf(
			requested * follow_ratio,
			-deg_to_rad(maximum_visual_tilt_degrees),
			deg_to_rad(maximum_visual_tilt_degrees)
		)
	var response := 1.0 if smoothing_speed <= 0.0 else 1.0 - exp(-smoothing_speed * delta)
	visual_angle = lerp_angle(visual_angle, requested, response)
	slope_visual().rotation = visual_angle


func body() -> CharacterBody2D:
	return get_node_or_null(body_path) as CharacterBody2D


func grounding() -> ActorGroundingComponent:
	return get_node_or_null(grounding_path) as ActorGroundingComponent


func slope_visual() -> Node2D:
	return get_node_or_null(slope_visual_path) as Node2D


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if body() == null:
		errors.append("Body Path doit résoudre un CharacterBody2D.")
	if grounding() == null:
		errors.append("Grounding est obligatoire.")
	if slope_visual() == null:
		errors.append("Slope Visual est obligatoire et doit pivoter au root des pieds.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
