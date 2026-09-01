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
## Machine d'états commune qui expose l'état gameplay courant du joueur.
@export_node_path("ActorStateMachineComponent") var state_machine_path := NodePath("Components/StateMachine")
## Composant qui consomme la WeaponData, cadence les tirs et émet les demandes de projectile.
@export_node_path("PlayerWeaponComponent") var weapon_component_path := NodePath("Components/Weapon")
## Autorité runtime de l'arsenal et de l'arme actuellement équipée.
@export_node_path("PlayerLoadoutComponent") var loadout_component_path := NodePath("Components/Loadout")
## Autorité runtime des munitions spéciales, de l'armure et de l'Overdrive.
@export_node_path("PlayerCombatInventoryComponent") var combat_inventory_component_path := NodePath("Components/CombatInventory")
## Composant traduisant le mouvement runtime en animations et orientation visuelle.
@export_node_path("PlayerPresentationComponent") var presentation_component_path := NodePath("Components/Animation")
## Composant traduisant chaque tir en recul local sans déplacer le CharacterBody2D.
@export_node_path("PlayerRecoilComponent") var recoil_component_path := NodePath("Components/Recoil")
## Composant seul propriétaire de player_interact et de la cible locale choisie.
@export_node_path("PlayerInteractionComponent") var interaction_component_path := NodePath("Components/Interaction")
## Composant partagé qui expose le root des pieds et projette l'ombre sur le vrai sol.
@export_node_path("ActorGroundingComponent") var grounding_component_path := NodePath("Components/Grounding")
## Composant partagé qui incline uniquement le pivot visuel selon les deux sondes de pieds.
@export_node_path("ActorSlopePresentationComponent") var slope_presentation_component_path := NodePath("Components/SlopeAlignment")
## Branche regroupant sprites, arme, pivots et animations sans contenir la collision gameplay.
@export_node_path("Node2D") var visuals_path := NodePath("Visuals")


func _ready() -> void:
	if not Engine.is_editor_hint():
		add_to_group(&"players")
		add_to_group(&"damageable_actors")
		var health := health_component()
		if health != null:
			health.damaged.connect(_on_health_damaged)
			health.died.connect(_on_health_died)


func movement_component() -> PlayerMovementComponent:
	return get_node_or_null(movement_component_path) as PlayerMovementComponent


func aim_component() -> PlayerAimComponent:
	return get_node_or_null(aim_component_path) as PlayerAimComponent


func health_component() -> PlayerHealthComponent:
	return get_node_or_null(health_component_path) as PlayerHealthComponent


func state_machine() -> ActorStateMachineComponent:
	return get_node_or_null(state_machine_path) as ActorStateMachineComponent


func weapon_component() -> PlayerWeaponComponent:
	return get_node_or_null(weapon_component_path) as PlayerWeaponComponent


func loadout_component() -> PlayerLoadoutComponent:
	return get_node_or_null(loadout_component_path) as PlayerLoadoutComponent


func combat_inventory_component() -> PlayerCombatInventoryComponent:
	return get_node_or_null(combat_inventory_component_path) as PlayerCombatInventoryComponent


func presentation_component() -> PlayerPresentationComponent:
	return get_node_or_null(presentation_component_path) as PlayerPresentationComponent


func recoil_component() -> PlayerRecoilComponent:
	return get_node_or_null(recoil_component_path) as PlayerRecoilComponent


func interaction_component() -> PlayerInteractionComponent:
	return get_node_or_null(interaction_component_path) as PlayerInteractionComponent


func grounding_component() -> ActorGroundingComponent:
	return get_node_or_null(grounding_component_path) as ActorGroundingComponent


func slope_presentation_component() -> ActorSlopePresentationComponent:
	return get_node_or_null(slope_presentation_component_path) as ActorSlopePresentationComponent


func apply_damage(amount: float) -> bool:
	var health := health_component()
	var inventory := combat_inventory_component()
	var remaining := inventory.absorb_damage(amount) if inventory != null else amount
	return true if remaining <= 0.0 and amount > 0.0 else (health.apply_damage(remaining) if health != null else false)


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if movement_component() == null or movement_component().profile == null:
		errors.append("Components/Movement et son profil sont obligatoires.")
	if aim_component() == null or aim_component().profile == null:
		errors.append("Components/Aim et son profil sont obligatoires.")
	if health_component() == null or health_component().profile == null:
		errors.append("Components/Health et son profil sont obligatoires.")
	if state_machine() == null:
		errors.append("Components/StateMachine est obligatoire.")
	if weapon_component() == null or weapon_component().weapon == null:
		errors.append("Components/Weapon et sa WeaponData sont obligatoires.")
	if loadout_component() == null or not loadout_component().validation_errors().is_empty():
		errors.append("Components/Loadout et son profil sont obligatoires.")
	if combat_inventory_component() == null or not combat_inventory_component().validation_errors().is_empty():
		errors.append("Components/CombatInventory et son profil sont obligatoires.")
	if presentation_component() == null or not presentation_component().validation_errors().is_empty():
		errors.append("Components/Animation et ses correspondances de feedback sont obligatoires.")
	if recoil_component() == null or not recoil_component().validation_errors().is_empty():
		errors.append("Components/Recoil et ses pivots visuels sont obligatoires.")
	if interaction_component() == null or not interaction_component().validation_errors().is_empty():
		errors.append("Components/Interaction, sa zone et son prompt sont obligatoires.")
	if grounding_component() == null or not grounding_component().validation_errors().is_empty():
		errors.append("Components/Grounding et ses correspondances sont obligatoires.")
	if slope_presentation_component() == null or not slope_presentation_component().validation_errors().is_empty():
		errors.append("Components/SlopeAlignment et son pivot visuel sont obligatoires.")
	if get_node_or_null(visuals_path) == null:
		errors.append("La branche Visuals est obligatoire.")
	if get_node_or_null("CollisionShape2D") == null:
		errors.append("CollisionShape2D est obligatoire.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()


func _on_health_damaged(_amount: float) -> void:
	var state := state_machine()
	if state != null:
		state.transition(ActorStateMachineComponent.State.HURT)


func _on_health_died() -> void:
	var state := state_machine()
	if state != null:
		state.transition(ActorStateMachineComponent.State.DEAD)
