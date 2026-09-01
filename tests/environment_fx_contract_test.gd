extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var profile_paths := [
		"res://effects/environment/profiles/toxic_coast_landing_fx.tres",
		"res://effects/environment/profiles/toxic_coast_bridge_fx.tres",
		"res://effects/environment/profiles/toxic_coast_foundry_fx.tres",
	]
	for profile_path in profile_paths:
		var profile := load(profile_path) as EnvironmentFXProfile
		_check(profile != null and profile.is_valid(), "%s doit fournir un profil d'atmosphère valide." % profile_path)

	var packed := load("res://maps/missions/toxic_coast/toxic_coast.tscn") as PackedScene
	var map := packed.instantiate() as MissionMapRoot2D if packed != null else null
	_check(map != null, "Côte toxique doit être instanciable pour valider son atmosphère.")
	if map != null:
		root.add_child(map)
		await process_frame
		var parallax_layers := map.find_children("*", "Parallax2D", true, false)
		_check(parallax_layers.size() == 2, "Toxic Coast doit exposer exactement un midground et un foreground parallaxes.")
		var midground := map.get_node_or_null("Visual/MidgroundParallax") as Parallax2D
		var foreground := map.get_node_or_null("Visual/ForegroundParallax") as Parallax2D
		_check(midground != null and midground.scroll_scale.x < 1.0, "Le midground doit défiler plus lentement que la caméra.")
		_check(foreground != null and foreground.scroll_scale.x > 1.0, "Le foreground doit défiler légèrement plus vite que la caméra.")
		var fx_root := map.get_node_or_null("Visual/EnvironmentFX") as Node2D
		_check(fx_root != null and fx_root.get_child_count() == 3, "Chaque acte doit posséder une instance EnvironmentFX2D explicite.")
		if fx_root != null:
			for child in fx_root.get_children():
				var environment_fx := child as EnvironmentFX2D
				_check(environment_fx != null and environment_fx.profile != null and environment_fx.profile.is_valid(), "%s doit consommer un profil valide." % child.name)
				if environment_fx != null and environment_fx.profile != null:
					_check(environment_fx.smoke.amount == environment_fx.profile.smoke_amount, "%s doit appliquer la quantité de fumée du profil." % child.name)
					_check(environment_fx.toxic_fog.amount == environment_fx.profile.fog_amount, "%s doit appliquer la quantité de brouillard du profil." % child.name)
		var foundry_fx := map.get_node_or_null("Visual/EnvironmentFX/FoundryEnvironmentFX") as EnvironmentFX2D
		_check(foundry_fx != null and foundry_fx.sparks.emitting, "La fonderie doit activer ses étincelles industrielles.")
		var bridge_fx := map.get_node_or_null("Visual/EnvironmentFX/BridgeEnvironmentFX") as EnvironmentFX2D
		_check(bridge_fx != null and bridge_fx.lightning.visible, "Le pont acide doit exposer son orage animé.")
		if bridge_fx != null:
			bridge_fx.preview_lightning()
			await process_frame
			_check(bridge_fx.animation_player.current_animation == &"strike", "L'éclair doit être orchestré par AnimationPlayer.")
		map.queue_free()

	if _failures.is_empty():
		print("ENVIRONMENT_FX_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("ENVIRONMENT_FX_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
