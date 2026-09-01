extends SceneTree

const DATA_ROOT := "res://maps/encounters/data/toxic_coast/"
const REMOVED_SINGLE_USE_RESOURCES := [
	DATA_ROOT + "waves/landing_pressure.tres",
	DATA_ROOT + "waves/landing_release.tres",
	DATA_ROOT + "patterns/bridge_flying_column.tres",
	DATA_ROOT + "waves/bridge_escalation_air.tres",
	DATA_ROOT + "waves/bridge_escalation_pincer.tres",
	DATA_ROOT + "waves/bridge_pressure.tres",
	DATA_ROOT + "waves/foundry_payoff.tres",
	DATA_ROOT + "waves/foundry_pressure.tres",
	DATA_ROOT + "patterns/bridge_grunt_pincer.tres",
	DATA_ROOT + "patterns/bridge_two_grunts.tres",
	DATA_ROOT + "patterns/foundry_boss.tres",
	DATA_ROOT + "patterns/foundry_two_grunts.tres",
	DATA_ROOT + "patterns/landing_grunt_release.tres",
	DATA_ROOT + "patterns/landing_two_troopers.tres",
]

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var encounter_paths := [
		DATA_ROOT + "landing_cadence.tres",
		DATA_ROOT + "bridge_gauntlet.tres",
		DATA_ROOT + "foundry_boss_gate.tres",
	]
	var encounters: Array[EncounterData] = []
	for path in encounter_paths:
		var encounter := load(path) as EncounterData
		_check(encounter != null and encounter.resource_path == path, "%s doit rester une recette EncounterData externe." % path)
		if encounter != null:
			_check(encounter.validation_errors().is_empty(), "%s doit rester structurellement valide." % path)
			encounters.append(encounter)

	for encounter in encounters:
		for wave in encounter.waves:
			_check(wave.resource_path.contains("::"), "%s doit intégrer ses Waves mono-usage." % encounter.resource_path)
			for pattern in wave.spawn_patterns:
				_check(pattern.resource_path.contains("::"), "%s doit intégrer ses Patterns mono-usage." % encounter.resource_path)
	for path in REMOVED_SINGLE_USE_RESOURCES:
		_check(not ResourceLoader.exists(path), "%s est mono-usage et doit rester intégrée à sa recette parente." % path)

	if _failures.is_empty():
		print("ENCOUNTER_RESOURCE_STRUCTURE_TEST: PASS")
		quit(0)
	else:
		print("ENCOUNTER_RESOURCE_STRUCTURE_TEST: FAIL (%d)" % _failures.size())
		quit(1)
