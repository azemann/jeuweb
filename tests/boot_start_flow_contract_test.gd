extends SceneTree

var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred(&"_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void:
	var presentation := load("res://ui/flows/themes/industrial_toxic_boot_start_theme.tres") as BootStartFlowTheme
	_check(presentation != null and presentation.is_valid(), "La présentation Industrial Toxic du Boot/Start doit être valide.")
	if presentation != null:
		_check(presentation.theme_id == &"industrial_toxic", "La présentation doit conserver son identifiant stable.")
		_check(presentation.loading_background != presentation.boot_background, "Le chargement et le Boot doivent conserver des illustrations sémantiquement distinctes.")
		_check(presentation.landing_marker.get_size() == Vector2(192, 192), "Les marqueurs futurs doivent être normalisés sur 192 × 192.")
		var published_textures: Array[Texture2D] = [
			presentation.faction_emblem, presentation.title_plaque, presentation.main_menu_frame,
			presentation.boot_background, presentation.loading_background, presentation.start_background,
			presentation.mission_select_background, presentation.previous_inactive, presentation.previous_active,
			presentation.locked_ornament, presentation.divider_ornament, presentation.lime_status_lamp,
			presentation.magenta_status_lamp, presentation.landing_marker, presentation.pipeline_marker,
			presentation.foundry_marker, presentation.fortress_marker, presentation.elite_marker,
			presentation.completed_marker,
		]
		var published_paths := PackedStringArray()
		for texture in published_textures:
			published_paths.append(texture.resource_path)
		_check(published_textures.size() == 19 and published_paths.size() == 19, "La Resource doit exposer les dix-neuf livrables publiés.")
		var unique_paths := {}
		for path in published_paths:
			unique_paths[path] = true
		_check(unique_paths.size() == 19, "Chaque rôle visuel doit pointer vers un livrable distinct, sans doublon silencieux.")

	var boot := (load("res://screens/boot/boot_flow.tscn") as PackedScene).instantiate() as BootFlow
	var start := (load("res://screens/start/start_flow.tscn") as PackedScene).instantiate() as StartFlow
	_check(boot != null and start != null, "BootFlow et StartFlow doivent rester instanciables.")
	if boot != null and start != null:
		root.add_child(boot)
		root.add_child(start)
		await process_frame
		_check(boot.presentation == presentation, "BootFlow doit consommer la Resource de présentation partagée.")
		_check(boot.get_node("Backdrop").texture == presentation.boot_background, "Le Boot doit utiliser son background publié.")
		_check(boot.get_node("Center/Identity/Emblem") is TextureRect, "L'emblème doit être un bitmap sémantique, pas un glyphe typographique.")
		_check(boot.get_node_or_null("Center/EmblemPanel/Stack/EmblemGlyph") == null, "L'ancien placeholder de glyphe doit être retiré.")
		_check(start.get_node("Backdrop").texture == presentation.start_background, "Le menu doit utiliser le panorama de forteresse publié.")
		_check(start.get_node("SafeArea/MenuComposition/TitlePlate/TitleStack/Title") is Label, "Le titre doit rester du texte natif Godot localisable.")
		_check(start.get_node("SafeArea/MenuComposition/MenuPanel/MenuFrame").texture == presentation.main_menu_frame, "Le cadre doit entourer les actions sans les posséder.")
		var mission_indicator := start.get_node("SafeArea/MenuComposition/MenuPanel/MenuRows/MissionRow/MissionIndicator") as TextureRect
		var gallery_indicator := start.get_node("SafeArea/MenuComposition/MenuPanel/MenuRows/GalleryRow/GalleryIndicator") as TextureRect
		var menu_frame := start.get_node("SafeArea/MenuComposition/MenuPanel/MenuFrame") as TextureRect
		var mission_button := start.get_node("SafeArea/MenuComposition/MenuPanel/MenuRows/MissionRow/MissionButton") as Button
		var gallery_button := start.get_node("SafeArea/MenuComposition/MenuPanel/MenuRows/GalleryRow/GalleryButton") as Button
		_check(mission_indicator.texture == presentation.previous_active and mission_indicator.modulate.a == 1.0, "La flèche active doit indiquer le focus initial.")
		_check(is_equal_approx(menu_frame.size.x / menu_frame.size.y, 2.0 / 3.0), "Le cadre vertical doit conserver son ratio artistique 2:3.")
		_check(mission_button.theme_type_variation == &"StartMenuButton", "Les actions du menu doivent éviter le cartouche Button générique.")
		_check(is_equal_approx(mission_button.global_position.x, gallery_button.global_position.x), "Les indicateurs invisibles doivent réserver leur espace et garder les libellés alignés.")
		start.get_node("SafeArea/MenuComposition/MenuPanel/MenuRows/GalleryRow/GalleryButton").grab_focus()
		await process_frame
		_check(gallery_indicator.modulate.a == 1.0 and mission_indicator.modulate.a == 0.0, "L'ornement actif doit suivre le focus sans déplacer l'alignement des boutons.")
		boot.queue_free()
		start.queue_free()

	var ui_theme := load("res://ui/themes/game_ui_theme.tres") as Theme
	_check(ui_theme != null, "Le thème UI global doit être lisible.")
	if ui_theme != null:
		_check(ui_theme.get_font_size("font_size", &"DisplayTitleLabel") >= 36, "Un titre d'affichage doit dominer clairement la hiérarchie.")
		_check(ui_theme.get_constant("outline_size", &"NotificationLabel") >= 8, "Les notifications sur gameplay doivent posséder un contour fort.")

	var hud_theme := load("res://ui/hud/themes/toxic_commando_hud_theme.tres") as MissionHUDTheme
	var hud := (load("res://ui/hud/mission_hud.tscn") as PackedScene).instantiate() as MissionHUD
	root.add_child(hud)
	await process_frame
	_check(hud.theme == ui_theme, "La scène MissionHUD doit posséder explicitement le Theme typographique et rester autonome dans l'éditeur.")
	_check(hud_theme.loading_background == presentation.loading_background, "Le HUD de Côte toxique doit réutiliser le loading publié sans dupliquer son autorité bitmap.")
	_check(hud.get_node("MissionStatusPanel/LoadingBackdrop").texture == hud_theme.loading_background, "Le chargement en jeu doit être une composition illustrée.")
	var status_label := hud.get_node("MissionStatusPanel/MissionStatusLabel") as Label
	var loading_title := hud.get_node("MissionStatusPanel/LoadingTitle") as Label
	_check(status_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER and status_label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "Le message de chargement doit être centré dans sa plaque.")
	_check(loading_title.theme_type_variation == &"LoadingTitleLabel" and status_label.theme_type_variation == &"LoadingLabel", "Le chargement doit séparer titre de signalétique et sous-état.")
	hud.queue_free()

	if _failures.is_empty():
		print("BOOT_START_FLOW_CONTRACT_TEST: PASS")
		quit(0)
	else:
		print("BOOT_START_FLOW_CONTRACT_TEST: FAIL (%d)" % _failures.size())
		quit(1)
