extends SceneTree

const GLOSSARY_PATH := "res://docs/architecture/GLOSSARY_CLASSES_AND_VOCABULARY.md"

var _failures: Array[String] = []
var _glossary := ""


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var glossary_file := FileAccess.open(GLOSSARY_PATH, FileAccess.READ)
	_check(glossary_file != null, "Le glossaire des classes doit être lisible.")
	if glossary_file != null:
		_glossary = glossary_file.get_as_text()
		_scan_scripts("res://")
	if _failures.is_empty():
		print("CLASS_GLOSSARY_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("CLASS_GLOSSARY_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _scan_scripts(directory: String) -> void:
	for child_directory in DirAccess.get_directories_at(directory):
		if child_directory in [".agents", ".codex", ".git", ".godot", "docs", "pipeline", "tests"]:
			continue
		_scan_scripts(directory.path_join(child_directory))
	for filename in DirAccess.get_files_at(directory):
		if filename.get_extension() != "gd":
			continue
		_check_script(directory.path_join(filename))


func _check_script(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_check(false, "Impossible de lire %s." % path)
		return
	for raw_line in file.get_as_text().split("\n"):
		var line := raw_line.strip_edges()
		if not line.begins_with("class_name "):
			continue
		var class_name_parts := line.trim_prefix("class_name ").split(" ", false, 1)
		var registered_name := class_name_parts[0]
		_check(
			_glossary.find("`%s`" % registered_name) != -1,
			"%s déclare %s, absent du glossaire des classes." % [path, registered_name]
		)

