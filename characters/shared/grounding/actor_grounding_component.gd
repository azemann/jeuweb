@tool
class_name ActorGroundingComponent
extends Node2D

@export_category("Correspondence")
## CharacterBody2D dont l'origine représente le contact central entre les pieds.
@export_node_path("CharacterBody2D") var body_path := NodePath("../..")
## Marker2D auteur matérialisant le root de contact au sol de la scène d'acteur.
@export_node_path("Marker2D") var ground_anchor_path := NodePath("GroundAnchor")
## RayCast2D qui cherche le vrai sol World, y compris les collisions Carvable reconstruites.
@export_node_path("RayCast2D") var ground_probe_path := NodePath("GroundProbe")
## Sonde gauche utilisée avec la sonde droite pour mesurer la tangente sous les appuis.
@export_node_path("RayCast2D") var left_foot_probe_path := NodePath("LeftFootProbe")
## Sonde droite utilisée avec la sonde gauche pour mesurer la tangente sous les appuis.
@export_node_path("RayCast2D") var right_foot_probe_path := NodePath("RightFootProbe")
## Polygon2D projeté au point de collision, jamais attaché visuellement au sprite animé.
@export_node_path("Polygon2D") var shadow_visual_path := NodePath("GroundShadow")

@export_category("Projected Shadow")
## Dimensions de l'ombre au contact du sol, en pixels monde.
@export var shadow_size := Vector2(56.0, 14.0):
	set(value):
		shadow_size = value
		_sync_editor_preview()
## Distance horizontale entre les deux sondes d'appui ; elle correspond à la largeur utile des pieds.
@export_range(4.0, 320.0, 2.0) var foot_probe_span := 34.0:
	set(value):
		foot_probe_span = value
		_sync_probe()
## Écart angulaire maximal entre les deux pieds et la normale centrale avant de privilégier celle-ci.
@export_range(1.0, 60.0, 1.0) var maximum_probe_deviation_degrees := 12.0
## Distance verticale maximale de recherche et de maintien de l'ombre.
@export_range(16.0, 1200.0, 8.0) var projection_distance := 320.0:
	set(value):
		projection_distance = value
		_sync_probe()
## Décalage de l'ombre le long de la normale afin d'éviter le z-fighting avec le sol.
@export_range(0.0, 12.0, 0.25) var surface_offset := 1.5
## Échelle minimale atteinte lorsque l'acteur approche de la distance maximale.
@export_range(0.1, 1.0, 0.05) var airborne_scale := 0.42
## Opacité maximale de l'ombre lorsque les pieds touchent le sol.
@export_range(0.0, 1.0, 0.01) var contact_opacity := 0.46
## Vitesse de suivi du point et de la normale du sol ; zéro désactive le lissage.
@export_range(0.0, 60.0, 1.0) var smoothing_speed := 24.0
## Couleur commune de l'ombre avant modulation de son opacité par la hauteur.
@export var shadow_color := Color(0.015, 0.02, 0.03, 1.0):
	set(value):
		shadow_color = value
		_sync_editor_preview()

var has_ground_projection := false
var ground_position := Vector2.ZERO
var ground_normal := Vector2.UP
var floor_angle := 0.0
var _projection_initialized := false


func _ready() -> void:
	_build_shadow_polygon()
	_sync_probe()
	if Engine.is_editor_hint():
		_sync_editor_preview()
		set_physics_process(false)
	else:
		set_physics_process(validation_errors().is_empty())


func _physics_process(delta: float) -> void:
	var probe := ground_probe()
	var shadow := shadow_visual()
	var body := body()
	if probe == null or shadow == null or body == null:
		return
	probe.force_raycast_update()
	var left_probe := left_foot_probe()
	var right_probe := right_foot_probe()
	if left_probe != null:
		left_probe.force_raycast_update()
	if right_probe != null:
		right_probe.force_raycast_update()
	has_ground_projection = probe.is_colliding()
	shadow.visible = has_ground_projection
	if not has_ground_projection:
		_projection_initialized = false
		return

	ground_position = probe.get_collision_point()
	ground_normal = probe.get_collision_normal().normalized()
	var normal_angle := ground_normal.angle() + PI * 0.5
	floor_angle = normal_angle
	if left_probe != null and right_probe != null and left_probe.is_colliding() and right_probe.is_colliding():
		var foot_delta := right_probe.get_collision_point() - left_probe.get_collision_point()
		if not is_zero_approx(foot_delta.x):
			var probed_angle := atan2(foot_delta.y, foot_delta.x)
			var deviation := absf(wrapf(probed_angle - normal_angle, -PI, PI))
			if deviation <= deg_to_rad(maximum_probe_deviation_degrees):
				floor_angle = probed_angle
	var anchor := ground_anchor()
	var anchor_position := anchor.global_position if anchor != null else body.global_position
	var height := clampf(anchor_position.distance_to(ground_position), 0.0, projection_distance)
	var height_ratio := height / projection_distance
	var size_ratio := lerpf(1.0, airborne_scale, height_ratio)
	var target_position := ground_position + ground_normal * surface_offset
	var target_rotation := ground_normal.angle() + PI * 0.5
	var response := 1.0 if smoothing_speed <= 0.0 else 1.0 - exp(-smoothing_speed * delta)
	if not _projection_initialized:
		shadow.global_position = target_position
		shadow.global_rotation = target_rotation
		_projection_initialized = true
	else:
		shadow.global_position = shadow.global_position.lerp(target_position, response)
		shadow.global_rotation = lerp_angle(shadow.global_rotation, target_rotation, response)
	var actor_scale := body.global_scale.abs()
	shadow.global_scale = shadow_size * 0.5 * size_ratio * actor_scale
	var color := shadow_color
	color.a = contact_opacity * lerpf(1.0, 0.28, height_ratio)
	shadow.color = color


func body() -> CharacterBody2D:
	return get_node_or_null(body_path) as CharacterBody2D


func ground_anchor() -> Marker2D:
	return get_node_or_null(ground_anchor_path) as Marker2D


func ground_probe() -> RayCast2D:
	return get_node_or_null(ground_probe_path) as RayCast2D


func left_foot_probe() -> RayCast2D:
	return get_node_or_null(left_foot_probe_path) as RayCast2D


func right_foot_probe() -> RayCast2D:
	return get_node_or_null(right_foot_probe_path) as RayCast2D


func shadow_visual() -> Polygon2D:
	return get_node_or_null(shadow_visual_path) as Polygon2D


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if body() == null:
		errors.append("Body Path doit résoudre un CharacterBody2D.")
	if ground_anchor() == null:
		errors.append("Ground Anchor est obligatoire.")
	if ground_probe() == null:
		errors.append("Ground Probe est obligatoire.")
	if left_foot_probe() == null or right_foot_probe() == null:
		errors.append("Left Foot Probe et Right Foot Probe sont obligatoires.")
	if shadow_visual() == null:
		errors.append("Ground Shadow est obligatoire.")
	if shadow_size.x <= 0.0 or shadow_size.y <= 0.0:
		errors.append("Shadow Size doit être positif.")
	if projection_distance <= 0.0:
		errors.append("Projection Distance doit être positive.")
	return errors


func _build_shadow_polygon() -> void:
	var shadow := shadow_visual()
	if shadow == null:
		return
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(Vector2(cos(angle), sin(angle)))
	shadow.polygon = points


func _sync_probe() -> void:
	if not is_inside_tree():
		return
	var probes: Array[RayCast2D] = [ground_probe(), left_foot_probe(), right_foot_probe()]
	for probe in probes:
		if probe != null:
			probe.target_position = Vector2(0.0, projection_distance)
	var left_probe := left_foot_probe()
	var right_probe := right_foot_probe()
	if left_probe != null:
		left_probe.position = Vector2(-foot_probe_span * 0.5, -8.0)
	if right_probe != null:
		right_probe.position = Vector2(foot_probe_span * 0.5, -8.0)


func _sync_editor_preview() -> void:
	if not is_inside_tree() or not Engine.is_editor_hint():
		return
	_build_shadow_polygon()
	var shadow := shadow_visual()
	if shadow != null:
		shadow.position = Vector2(0.0, surface_offset)
		shadow.scale = shadow_size * 0.5
		var color := shadow_color
		color.a = contact_opacity
		shadow.color = color
		shadow.visible = true


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
