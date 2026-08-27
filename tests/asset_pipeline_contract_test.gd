extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	_check(FileAccess.file_exists("res://pipeline/.gdignore"), "Le pipeline doit être masqué à l'importeur Godot par .gdignore.")
	_check(
		FileAccess.file_exists("res://pipeline/assets/sources/imagegen/toxic_coast/toxic-soil-master-v001.png"),
		"La source maître du sol doit appartenir au pipeline."
	)
	_check(
		not FileAccess.file_exists("res://art/terrain/toxic_coast/toxic-soil-master-v001.png"),
		"Un fichier maître non runtime ne doit pas rester sous art/."
	)
	_scan_runtime_references("res://")

	if _failures.is_empty():
		print("ASSET_PIPELINE_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("ASSET_PIPELINE_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)


func _scan_runtime_references(directory: String) -> void:
	for child_directory in DirAccess.get_directories_at(directory):
		if child_directory in [".godot", ".git", "pipeline"]:
			continue
		_scan_runtime_references(directory.path_join(child_directory))
	for filename in DirAccess.get_files_at(directory):
		if filename.get_extension() not in ["gd", "tscn", "tres"]:
			continue
		var path := directory.path_join(filename)
		if path == "res://tests/asset_pipeline_contract_test.gd":
			continue
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var forbidden_reference := "res://" + "pipeline/"
		_check(
			file.get_as_text().find(forbidden_reference) == -1,
			"Le fichier runtime %s référence directement le pipeline auteur." % path
		)
