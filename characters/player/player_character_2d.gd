@tool
class_name PlayerCharacter2D
extends CharacterBody2D

@export_category("Visible Architecture")
## Composant responsable de la vélocité, du saut et du déplacement du CharacterBody2D.
@export_node_path("PlayerMovementComponent") var movement_component_path := NodePath("Components/Movement")
## Composant responsable de la direction regardée et de la visée arcade.
@export_node_path("PlayerAimComponent") var aim_component_path := NodePath("Components/Aim")
## Composant autoritaire pour les PV runtime et les signaux de dégâts ou de mort.
@export_node_path("PlayerHealthComponent") var health_component_path := NodePath("Components/Health")
## Composant qui consomme la WeaponData, cadence les tirs et émet les demandes de projectile.
@export_node_path("PlayerWeaponComponent") var weapon_component_path := NodePath("Components/Weapon")
## Composant traduisant le mouvement runtime en animations et orientation visuelle.
@export_node_path("PlayerPresentationComponent") var presentation_component_path := NodePath("Components/Presentation")
## Composant partagé qui expose le root des pieds et projette l'ombre sur le vrai sol.
@export_node_path("ActorGroundingComponent") var grounding_component_path := NodePath("Components/Grounding")
## Composant partagé qui incline uniquement le pivot visuel selon les deux sondes de pieds.
@export_node_path("ActorSlopePresentationComponent") var slope_presentation_component_path := NodePath("Components/SlopePresentation")
## Branche regroupant sprites, arme, pivots et animations sans contenir la collision gameplay.
@export_node_path("Node2D") var presentation_path := NodePath("Presentation")


func _ready() -> void:
	if not Engine.is_editor_hint():
		add_to_group(&"players")
		add_to_group(&"damageable_actors")


func movement_component() -> PlayerMovementComponent:
	return get_node_or_null(movement_component_path) as PlayerMovementComponent


func aim_component() -> PlayerAimComponent:
	return get_node_or_null(aim_component_path) as PlayerAimComponent


func health_component() -> PlayerHealthComponent:
	return get_node_or_null(health_component_path) as PlayerHealthComponent


func weapon_component() -> PlayerWeaponComponent:
	return get_node_or_null(weapon_component_path) as PlayerWeaponComponent


func presentation_component() -> PlayerPresentationComponent:
	return get_node_or_null(presentation_component_path) as PlayerPresentationComponent


func grounding_component() -> ActorGroundingComponent:
	return get_node_or_null(grounding_component_path) as ActorGroundingComponent


func slope_presentation_component() -> ActorSlopePresentationComponent:
	return get_node_or_null(slope_presentation_component_path) as ActorSlopePresentationComponent


func apply_damage(amount: float) -> bool:
	var health := health_component()
	return health.apply_damage(amount) if health != null else false


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if movement_component() == null or movement_component().profile == null:
		errors.append("Components/Movement et son profil sont obligatoires.")
	if aim_component() == null or aim_component().profile == null:
		errors.append("Components/Aim et son profil sont obligatoires.")
	if health_component() == null or health_component().profile == null:
		errors.append("Components/Health et son profil sont obligatoires.")
	if weapon_component() == null or weapon_component().weapon == null:
		errors.append("Components/Weapon et sa WeaponData sont obligatoires.")
	if presentation_component() == null:
		errors.append("Components/Presentation est obligatoire.")
	if grounding_component() == null or not grounding_component().validation_errors().is_empty():
		errors.append("Components/Grounding et ses correspondances sont obligatoires.")
	if slope_presentation_component() == null or not slope_presentation_component().validation_errors().is_empty():
		errors.append("Components/SlopePresentation et son pivot visuel sont obligatoires.")
	if get_node_or_null(presentation_path) == null:
		errors.append("La branche Presentation est obligatoire.")
	if get_node_or_null("CollisionShape2D") == null:
		errors.append("CollisionShape2D est obligatoire.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()
