@tool
class_name EnemyCharacter2D
extends CharacterBody2D

@export_category("Authority")
## Profil partagé par les composants de cette instance ennemie.
@export var profile: EnemyArchetypeProfile

@export_category("Visible Architecture")
## Composant propriétaire de la vélocité et des bornes de patrouille.
@export_node_path("EnemyPatrolComponent") var patrol_component_path := NodePath("Components/Patrol")
## Composant propriétaire des points de vie runtime.
@export_node_path("EnemyHealthComponent") var health_component_path := NodePath("Components/Health")
## Zone optionnelle dont la forme étend la réception des tirs au-delà du corps physique.
@export_node_path("Area2D") var hurtbox_path := NodePath("Hurtbox")
## Composant qui télégraphie et exécute l'attaque data-driven de l'archétype.
@export_node_path("EnemyAttackComponent") var attack_component_path := NodePath("Components/Attack")
## FSM commune exposant les états de l'ennemi aux composants et aux outils de mission.
@export_node_path("ActorStateMachineComponent") var state_machine_path := NodePath("Components/StateMachine")
## Composant traduisant la patrouille en animation et orientation.
@export_node_path("EnemyPresentationComponent") var presentation_component_path := NodePath("Components/Presentation")
## Composant partagé qui expose le root des pieds et projette l'ombre sur le vrai sol.
@export_node_path("ActorGroundingComponent") var grounding_component_path := NodePath("Components/Grounding")
## Composant partagé qui incline uniquement le pivot visuel selon les deux sondes de pieds.
@export_node_path("ActorSlopePresentationComponent") var slope_presentation_component_path := NodePath("Components/SlopePresentation")
## Branche contenant uniquement le rendu de l'ennemi.
@export_node_path("Node2D") var presentation_path := NodePath("Presentation")

var _dying := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group(&"enemies")
	add_to_group(&"damageable_actors")
	var health := health_component()
	if health != null:
		if not health.damaged.is_connected(_on_health_damaged):
			health.damaged.connect(_on_health_damaged)
		if not health.died.is_connected(_on_health_died):
			health.died.connect(_on_health_died)
	var presentation := presentation_component()
	if presentation != null:
		if not presentation.hit_animation_finished.is_connected(_on_hit_animation_finished):
			presentation.hit_animation_finished.connect(_on_hit_animation_finished)
		if not presentation.death_animation_finished.is_connected(_on_death_animation_finished):
			presentation.death_animation_finished.connect(_on_death_animation_finished)


func patrol_component() -> EnemyPatrolComponent:
	return get_node_or_null(patrol_component_path) as EnemyPatrolComponent


func health_component() -> EnemyHealthComponent:
	return get_node_or_null(health_component_path) as EnemyHealthComponent


func hurtbox() -> Area2D:
	return get_node_or_null(hurtbox_path) as Area2D


func attack_component() -> EnemyAttackComponent:
	return get_node_or_null(attack_component_path) as EnemyAttackComponent


func state_machine() -> ActorStateMachineComponent:
	return get_node_or_null(state_machine_path) as ActorStateMachineComponent


func presentation_component() -> EnemyPresentationComponent:
	return get_node_or_null(presentation_component_path) as EnemyPresentationComponent


func grounding_component() -> ActorGroundingComponent:
	return get_node_or_null(grounding_component_path) as ActorGroundingComponent


func slope_presentation_component() -> ActorSlopePresentationComponent:
	return get_node_or_null(slope_presentation_component_path) as ActorSlopePresentationComponent


func apply_damage(amount: float) -> bool:
	if _dying:
		return false
	var health := health_component()
	return health.apply_damage(amount) if health != null else false


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if profile == null or not profile.is_valid():
		errors.append("EnemyArchetypeProfile valide obligatoire.")
	if patrol_component() == null or patrol_component().profile != profile:
		errors.append("Components/Patrol doit consommer le profil de la racine.")
	if health_component() == null or health_component().profile != profile:
		errors.append("Components/Health doit consommer le profil de la racine.")
	if attack_component() == null or not attack_component().validation_errors().is_empty():
		errors.append("Components/Attack et ses correspondances sont obligatoires.")
	if state_machine() == null:
		errors.append("Components/StateMachine est obligatoire.")
	if presentation_component() == null:
		errors.append("Components/Presentation est obligatoire.")
	if (profile == null or not profile.is_flying()) and (grounding_component() == null or not grounding_component().validation_errors().is_empty()):
		errors.append("Components/Grounding et ses correspondances sont obligatoires.")
	if (profile == null or not profile.is_flying()) and (slope_presentation_component() == null or not slope_presentation_component().validation_errors().is_empty()):
		errors.append("Components/SlopePresentation et son pivot visuel sont obligatoires.")
	if get_node_or_null(presentation_path) == null:
		errors.append("La branche Presentation est obligatoire.")
	if get_node_or_null("CollisionShape2D") == null:
		errors.append("CollisionShape2D est obligatoire.")
	return errors


func _on_health_damaged(_amount: float) -> void:
	if _dying:
		return
	var patrol := patrol_component()
	if patrol != null:
		patrol.set_movement_enabled(false)
	var attack := attack_component()
	if attack != null:
		attack.cancel_attack()
	var state := state_machine()
	if state != null:
		state.transition(ActorStateMachineComponent.State.HURT)
	var presentation := presentation_component()
	if presentation != null:
		presentation.play_hit()


func _on_hit_animation_finished() -> void:
	if _dying:
		return
	var patrol := patrol_component()
	if patrol != null:
		patrol.set_movement_enabled(true)
	var state := state_machine()
	if state != null:
		state.transition(ActorStateMachineComponent.State.RUN)


func _on_health_died() -> void:
	_dying = true
	var state := state_machine()
	if state != null:
		state.transition(ActorStateMachineComponent.State.DEAD)
	remove_from_group(&"damageable_actors")
	collision_layer = 0
	var damage_area := hurtbox()
	if damage_area != null:
		damage_area.collision_layer = 0
	var patrol := patrol_component()
	if patrol != null:
		patrol.set_movement_enabled(false)
	var presentation := presentation_component()
	if presentation != null:
		presentation.play_death()
	else:
		queue_free()


func _on_death_animation_finished() -> void:
	queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
