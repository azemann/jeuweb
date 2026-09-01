@tool
class_name PlayerInteractionComponent
extends Node

signal target_changed(target: Area2D)
signal interaction_succeeded(target: Area2D)

@export_category("Authority")
## Action abstraite consommée uniquement par le joueur pour déclencher l'interaction choisie.
@export var interaction_action: StringName = &"player_interact"

@export_category("Scene Correspondence")
## Joueur transmis comme acteur intentionnel à la cible sélectionnée.
@export_node_path("PlayerCharacter2D") var actor_path := NodePath("../..")
## Zone locale détectant les Area2D du groupe interaction_targets.
@export_node_path("Area2D") var detection_area_path := NodePath("InteractionArea")
## Indication visible uniquement lorsqu'une cible valide est disponible.
@export_node_path("Label") var prompt_label_path := NodePath("../../InteractionPrompt")

var current_target: Area2D
var _actor: PlayerCharacter2D
var _detection_area: Area2D
var _prompt_label: Label


func _ready() -> void:
	_actor = get_node_or_null(actor_path) as PlayerCharacter2D
	_detection_area = get_node_or_null(detection_area_path) as Area2D
	_prompt_label = get_node_or_null(prompt_label_path) as Label
	if _prompt_label != null:
		_prompt_label.visible = false
	set_process(not Engine.is_editor_hint() and validation_errors().is_empty())


func _process(_delta: float) -> void:
	_refresh_target()
	if current_target != null and Input.is_action_just_pressed(interaction_action):
		try_interact()


func try_interact() -> bool:
	_refresh_target()
	if current_target == null:
		return false
	var target := current_target
	var interactable := target.get_parent()
	if interactable == null or not interactable.has_method(&"interact"):
		return false
	var accepted := bool(interactable.call(&"interact", _actor))
	if accepted:
		interaction_succeeded.emit(target)
		_refresh_target()
	return accepted


func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if str(interaction_action).is_empty() or not InputMap.has_action(interaction_action):
		errors.append("L'action Input Map d'interaction est absente.")
	if get_node_or_null(actor_path) == null:
		errors.append("Le PlayerCharacter2D d'interaction est introuvable.")
	if get_node_or_null(detection_area_path) == null:
		errors.append("InteractionArea est introuvable.")
	if get_node_or_null(prompt_label_path) == null:
		errors.append("InteractionPrompt est introuvable.")
	return errors


func _get_configuration_warnings() -> PackedStringArray:
	return validation_errors()


func _refresh_target() -> void:
	var requested: Area2D
	var nearest_distance := INF
	for area in _detection_area.get_overlapping_areas():
		if not area.is_in_group(&"interaction_targets"):
			continue
		var interactable := area.get_parent()
		if interactable == null or not interactable.has_method(&"can_interact") or not bool(interactable.call(&"can_interact", _actor)):
			continue
		var distance := _actor.global_position.distance_squared_to(area.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			requested = area
	if requested == current_target:
		return
	current_target = requested
	if _prompt_label != null:
		_prompt_label.visible = current_target != null
		if current_target != null:
			var interactable := current_target.get_parent()
			_prompt_label.text = str(interactable.call(&"get_interaction_prompt")) if interactable.has_method(&"get_interaction_prompt") else "INTERAGIR"
	target_changed.emit(current_target)
