extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var style := load("res://terrain/permanent_ground/styles/toxic_coast_permanent_ground.tres") as PermanentGroundStyle
	_check(style != null and style.is_valid(), "Le style de sol permanent Côte toxique doit être valide.")

	var packed := load("res://terrain/permanent_ground/ground_module_2d.tscn") as PackedScene
	_check(packed != null and packed.can_instantiate(), "La scène canonique GroundModule2D doit être instanciable.")
	var module := packed.instantiate() as GroundModule2D if packed != null else null
	_check(module != null, "La scène canonique doit produire un GroundModule2D.")
	if module != null:
		module.style = style
		module.outline = PackedVector2Array([Vector2(0, 0), Vector2(320, 0), Vector2(320, 160), Vector2(0, 160)])
		module.surface_path = PackedVector2Array([Vector2(0, 0), Vector2(320, 0)])
		root.add_child(module)
		await process_frame
		_check(module.validation_errors().is_empty(), "Le module configuré doit respecter son contrat.")
		_check(module.fill_polygon().polygon == module.outline, "Le Polygon2D doit consommer l'outline autoritaire.")
		_check(module.collision_polygon().polygon == module.outline, "La collision doit consommer le même outline autoritaire.")
		_check(module.surface_line().points == module.surface_path, "La bande de surface doit consommer Surface Path.")
		_check(module.fill_polygon().texture == style.fill_texture, "Le remplissage doit consommer la texture de sa Resource.")
		_check(module.surface_line().texture == style.surface_texture, "La surface doit consommer la texture de sa Resource.")
		module.free()

	if _failures.is_empty():
		print("PERMANENT_GROUND_MODULE_TEST: PASS")
		quit(0)
	else:
		print("PERMANENT_GROUND_MODULE_TEST: FAIL (%d)" % _failures.size())
		quit(1)
