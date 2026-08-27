extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	_scan_production_scripts("res://")
	if _failures.is_empty():
		print("INSPECTOR_DOCUMENTATION_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("INSPECTOR_DOCUMENTATION_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _scan_production_scripts(directory: String) -> void:
	for child_directory in DirAccess.get_directories_at(directory):
		if child_directory in [".agents", ".codex", ".git", ".godot", "docs", "pipeline", "tests"]:
			continue
		_scan_production_scripts(directory.path_join(child_directory))
	for filename in DirAccess.get_files_at(directory):
		if filename.get_extension() != "gd":
			continue
		_validate_export_tooltips(directory.path_join(filename))


func _validate_export_tooltips(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_check(false, "Impossible de lire %s." % path)
		return
	var lines := file.get_as_text().split("\n")
	for index in lines.size():
		var line := lines[index].strip_edges()
		if not _is_exported_property(line):
			continue
		var previous_line := lines[index - 1].strip_edges() if index > 0 else ""
		_check(
			previous_line.begins_with("##") and previous_line.trim_prefix("##").strip_edges().length() >= 12,
			"%s:%d doit décrire cette propriété exportée avec une infobulle ## utile." % [path, index + 1]
		)


func _is_exported_property(line: String) -> bool:
	if not line.begins_with("@export"):
		return false
	if line.begins_with("@export_category") or line.begins_with("@export_group") or line.begins_with("@export_subgroup"):
		return false
	return line.begins_with("@export var ") or line.find(" var ") != -1
