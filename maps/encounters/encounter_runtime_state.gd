class_name EncounterRuntimeState
extends RefCounted

enum Phase {
	LEAD_IN,
	PATTERN_DELAY,
	SPAWN,
	WAIT_CLEAR,
	TIMED_ADVANCE,
	ENCOUNTER_CLEAR,
	COMPLETION_DELAY,
}

var map: MissionMapRoot2D
var marker: MapEncounterMarker2D
var wave_index := 0
var pattern_index := 0
var offset_index := 0
var phase := Phase.LEAD_IN
var timer := 0.0


func _init(authority_map: MissionMapRoot2D, authority_marker: MapEncounterMarker2D) -> void:
	map = authority_map
	marker = authority_marker
	timer = marker.encounter_data.waves[0].lead_in_delay
