extends SceneTree

const GROUND_SCENES := [
	"res://terrain/kits/toxic_coast/pieces/military_bunker_block_medium.tscn",
	"res://terrain/kits/toxic_coast/pieces/industrial_catwalk_medium.tscn",
	"res://terrain/kits/toxic_coast/pieces/toxic_pipe_bridge_medium.tscn",
]
const HAZARD_SCENE := "res://terrain/hazards/toxic_acid_sump_medium_2d.tscn"
const BARREL_SCENE := "res://props/explosive_barrel/toxic_explosive_barrel_2d.tscn"
const CRATE_SCENE := "res://props/supply_crate/military_supply_crate_2d.tscn"

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	_check(InputMap.has_action(&"player_interact"), "L'action player_interact doit exister dans le projet.")
	for path in GROUND_SCENES:
		var packed := load(path) as PackedScene
		_check(packed != null, "La Ground Piece doit être chargeable : %s" % path)
		if packed != null:
			var piece := packed.instantiate() as GroundPiece2D
			root.add_child(piece)
			_check(piece.definition != null and piece.definition.is_valid(), "La définition doit être valide : %s" % path)
			_check(piece.ground_mode == GroundPiece2D.GroundMode.PERMANENT, "La pièce publiée doit être permanente par défaut.")
			piece.ground_mode = GroundPiece2D.GroundMode.CARVABLE
			_check(piece.is_carvable_stamp_active(), "La pièce doit pouvoir passer en Carvable depuis l'Inspector.")
			piece.ground_mode = GroundPiece2D.GroundMode.BREAKABLE
			_check(piece.is_breakable_active(), "La pièce doit pouvoir passer en Breakable depuis l'Inspector.")
			piece.queue_free()

	var hazard := (load(HAZARD_SCENE) as PackedScene).instantiate() as DamageHazard2D
	root.add_child(hazard)
	_check(hazard.data != null and hazard.data.is_valid(), "Le bassin acide doit posséder une HazardData valide.")
	hazard.queue_free()

	var barrel := (load(BARREL_SCENE) as PackedScene).instantiate() as ExplosiveProp2D
	root.add_child(barrel)
	_check(barrel.data != null and barrel.data.is_valid(), "Le baril doit posséder une ExplosivePropData valide.")
	barrel.queue_free()

	var crate := (load(CRATE_SCENE) as PackedScene).instantiate() as SupplyCrate2D
	root.add_child(crate)
	_check(crate.data != null and crate.data.is_valid(), "La caisse doit posséder une SupplyCrateData valide.")
	_check(crate.data.accepts_shot() and crate.data.accepts_interaction(), "La caisse publiée doit accepter tir et interaction.")
	_check(crate.apply_damage(1.0) and crate.is_open(), "Un tir doit ouvrir la caisse vide publiée.")
	crate.queue_free()

	await process_frame
	if _failures.is_empty():
		print("TOXIC_COAST_CONTENT_PACK_TEST: PASS")
		quit(0)
	else:
		print("TOXIC_COAST_CONTENT_PACK_TEST: FAIL (%d)" % _failures.size())
		quit(1)
