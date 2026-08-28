extends SceneTree

const GroundPieceDefinitionType = preload("res://terrain/ground_pieces/ground_piece_definition.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var grounding_scene := load("res://characters/shared/grounding/actor_grounding_component.tscn") as PackedScene
	_check(grounding_scene != null and grounding_scene.can_instantiate(), "Le composant Grounding partagé doit être instanciable.")

	var player := (load("res://characters/player/player_character_2d.tscn") as PackedScene).instantiate() as PlayerCharacter2D
	var enemy := (load("res://characters/enemies/vacuum_trooper/vacuum_trooper_2d.tscn") as PackedScene).instantiate() as EnemyCharacter2D
	_check(player.grounding_component() != null, "Le joueur doit exposer Components/Grounding.")
	_check(enemy.grounding_component() != null, "Chaque ennemi canonique doit exposer Components/Grounding.")
	_check(player.slope_presentation_component() != null, "Le joueur doit exposer Components/SlopeAlignment.")
	_check(enemy.slope_presentation_component() != null, "Chaque ennemi terrestre doit exposer Components/SlopeAlignment.")
	_check(_has_central_ground_contact(player), "La collision du joueur doit rejoindre GroundAnchor par un contact inférieur central.")
	_check(_has_central_ground_contact(enemy), "La collision ennemie doit rejoindre GroundAnchor par un contact inférieur central.")
	_check(player.get_node_or_null("Visuals/Shadow") == null, "Une ombre ne doit pas être attachée aux Visuals du joueur.")
	_check(enemy.get_node_or_null("Visuals/Shadow") == null, "Une ombre ne doit pas être attachée aux Visuals de l'ennemi.")
	player.free()
	enemy.free()

	var body := CharacterBody2D.new()
	body.position = Vector2(0, -80)
	var components := Node2D.new()
	components.name = "Components"
	body.add_child(components)
	var grounding := grounding_scene.instantiate() as ActorGroundingComponent
	components.add_child(grounding)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.position = Vector2(0, 40)
	floor_body.rotation = deg_to_rad(20.0)
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(400, 20)
	floor_shape.shape = rectangle
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)
	root.add_child(body)
	await physics_frame
	await physics_frame
	_check(grounding.validation_errors().is_empty(), "Le composant Grounding canonique doit être valide.")
	_check(grounding.has_ground_projection, "GroundProbe doit trouver un vrai collider World sous l'acteur.")
	_check(absf(grounding.ground_position.y - 30.0) < 2.0, "L'ombre doit viser la surface physique, même si l'acteur est en hauteur.")
	_check(grounding.shadow_visual().global_position.y > body.global_position.y + 90.0, "L'ombre aérienne doit rester au sol au lieu de suivre Presentation.")
	_check(absf(rad_to_deg(grounding.floor_angle) - 20.0) < 2.0, "Les deux sondes de pieds doivent mesurer l'angle réel de la pente.")
	body.free()
	floor_body.free()

	var definition := load("res://terrain/kits/toxic_coast/definitions/natural_ledge_medium.tres") as GroundPieceDefinitionType
	_check(definition.collision_source == GroundPieceDefinitionType.CollisionSource.AUTHORED_OUTLINE, "Permanent/Breakable doit utiliser la géométrie auteur.")
	_check(definition.walk_surface().size() >= 2, "La première pièce doit exposer sa surface marchable dans l'Inspector.")
	_check(definition.validation_errors().is_empty(), "La définition avec surface marchable doit rester valide.")

	if _failures.is_empty():
		print("GROUNDING_WALK_SURFACE_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("GROUNDING_WALK_SURFACE_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _has_central_ground_contact(actor: CharacterBody2D) -> bool:
	var collision := actor.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return false
	var local_bottom := collision.position.y + collision.shape.get_rect().end.y
	if absf(local_bottom) > 1.0:
		return false
	if collision.shape is CapsuleShape2D or collision.shape is CircleShape2D:
		return true
	if collision.shape is ConvexPolygonShape2D:
		var points := (collision.shape as ConvexPolygonShape2D).points
		for point in points:
			if absf(collision.position.y + point.y) <= 1.0 and absf(collision.position.x + point.x) <= 1.0:
				return true
	return false
