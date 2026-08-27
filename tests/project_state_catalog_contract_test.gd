extends SceneTree

const PROJECT_STATE_PATH := "res://docs/PROJECT_STATE.md"
const MISSION_CATALOG_PATH := "res://maps/definitions/mission_map_catalog.tres"
const ENEMY_CATALOG_PATH := "res://characters/enemies/data/enemy_catalog.tres"
const GROUND_KIT_PATH := "res://terrain/kits/toxic_coast/toxic_coast_ground_kit.tres"
const PROJECTION_BEGIN := "<!-- CATALOG_PROJECTION_BEGIN -->"
const PROJECTION_END := "<!-- CATALOG_PROJECTION_END -->"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var projection := _read_documented_projection()
	var expected := {
		"mission_maps": _published_mission_ids(),
		"enemy_archetypes": _published_enemy_ids(),
		"ground_pieces/toxic_coast": _published_ground_piece_ids(),
	}
	for key in expected:
		_check_projection(key, expected[key], projection)
	for documented_key in projection:
		_check(expected.has(documented_key), "Projection de catalogue inconnue dans PROJECT_STATE : %s." % documented_key)
	_finish()


func _read_documented_projection() -> Dictionary:
	var result: Dictionary = {}
	var file := FileAccess.open(PROJECT_STATE_PATH, FileAccess.READ)
	_check(file != null, "PROJECT_STATE doit être lisible.")
	if file == null:
		return result
	var inside_projection := false
	var found_begin := false
	var found_end := false
	for raw_line in file.get_as_text().split("\n"):
		var line := raw_line.strip_edges()
		if line == PROJECTION_BEGIN:
			inside_projection = true
			found_begin = true
			continue
		if line == PROJECTION_END:
			inside_projection = false
			found_end = true
			continue
		if not inside_projection or not line.begins_with("-"):
			continue
		var tokens := _backtick_tokens(line)
		if tokens.is_empty():
			continue
		var key := tokens[0]
		var ids := PackedStringArray()
		for index in range(1, tokens.size()):
			ids.append(tokens[index])
		ids.sort()
		_check(not result.has(key), "Projection dupliquée dans PROJECT_STATE : %s." % key)
		result[key] = ids
	_check(found_begin and found_end and not inside_projection, "Le bloc de projection des catalogues doit être complet.")
	return result


func _backtick_tokens(line: String) -> PackedStringArray:
	var tokens := PackedStringArray()
	var cursor := 0
	while cursor < line.length():
		var opening := line.find("`", cursor)
		if opening == -1:
			break
		var closing := line.find("`", opening + 1)
		if closing == -1:
			break
		tokens.append(line.substr(opening + 1, closing - opening - 1))
		cursor = closing + 1
	return tokens


func _published_mission_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	var catalog := load(MISSION_CATALOG_PATH) as MissionMapCatalog
	_check(catalog != null, "Le catalogue de missions doit être chargeable.")
	if catalog == null:
		return ids
	_check(catalog.validation_errors().is_empty(), "Le catalogue de missions doit être valide.")
	for definition in catalog.maps:
		if definition != null and definition.is_valid():
			ids.append(str(definition.map_id))
	ids.sort()
	return ids


func _published_enemy_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	var catalog := load(ENEMY_CATALOG_PATH) as EnemyCatalog
	_check(catalog != null, "Le catalogue ennemi doit être chargeable.")
	if catalog == null:
		return ids
	_check(catalog.validation_errors().is_empty(), "Le catalogue ennemi doit être valide.")
	for binding in catalog.bindings:
		if binding != null and binding.is_valid():
			ids.append(str(binding.archetype_id))
	ids.sort()
	return ids


func _published_ground_piece_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	var catalog := load(GROUND_KIT_PATH) as GroundKitCatalog
	_check(catalog != null, "Le Ground Kit Côte toxique doit être chargeable.")
	if catalog == null:
		return ids
	_check(catalog.validation_errors().is_empty(), "Le Ground Kit Côte toxique doit être valide.")
	for packed in catalog.pieces:
		if packed == null or not packed.can_instantiate():
			continue
		var piece := packed.instantiate() as GroundPiece2D
		if piece != null and piece.definition != null:
			ids.append(str(piece.definition.piece_id))
		if piece != null:
			piece.free()
	ids.sort()
	return ids


func _check_projection(key: String, expected_ids: PackedStringArray, projection: Dictionary) -> void:
	_check(projection.has(key), "PROJECT_STATE doit projeter le catalogue %s." % key)
	if not projection.has(key):
		return
	var documented_ids: PackedStringArray = projection[key]
	_check(
		documented_ids == expected_ids,
		"Projection %s obsolète : documenté=%s, publié=%s." % [key, documented_ids, expected_ids]
	)


func _finish() -> void:
	if _failures.is_empty():
		print("PROJECT_STATE_CATALOG_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("PROJECT_STATE_CATALOG_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
