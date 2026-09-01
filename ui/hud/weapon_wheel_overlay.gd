@tool
class_name WeaponWheelOverlay
extends Control

@export_category("Input")
## Action maintenue pour ouvrir la roue ; relâcher équipe le segment sélectionné.
@export var wheel_action: StringName = &"player_weapon_wheel"
## Remplit la réserve spéciale lorsqu'une arme de test consommatrice est équipée par la roue.
@export var refill_special_ammo_on_select := true
## Distance minimale du centre avant de changer la sélection au pointeur.
@export_range(8.0, 180.0, 1.0) var pointer_deadzone := 42.0
## Distance minimale du stick droit avant de changer la sélection.
@export_range(0.05, 1.0, 0.01) var stick_deadzone := 0.35

@export_category("Presentation")
## Distance du centre HUD à chaque segment de la roue, en pixels.
@export_range(96.0, 280.0, 1.0) var radius := 172.0
## Taille maximale du bitmap d'arme dessiné dans chaque segment.
@export_range(36.0, 128.0, 1.0) var icon_size := 76.0
## Couleur de l'assombrissement plein écran pendant la sélection.
@export var shade_color := Color(0.015, 0.018, 0.015, 0.68)
## Couleur de fond d'un segment disponible mais non sélectionné.
@export var segment_color := Color(0.10, 0.12, 0.10, 0.90)
## Couleur de fond du segment actuellement pointé.
@export var selected_segment_color := Color(0.58, 0.94, 0.04, 0.95)
## Couleur réservée à un segment vide ou invalide.
@export var locked_segment_color := Color(0.16, 0.16, 0.14, 0.72)
## Couleur des libellés de segment non sélectionnés.
@export var text_color := Color(0.96, 0.91, 0.74, 1.0)
## Couleur du libellé lorsqu'un segment est sélectionné.
@export var selected_text_color := Color(0.02, 0.03, 0.02, 1.0)

var _loadout: PlayerLoadoutComponent
var _inventory: PlayerCombatInventoryComponent
var _weapons: Array[WeaponData] = []
var _selected_index := 0
var _open := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_process(false)
	set_process_unhandled_input(not Engine.is_editor_hint())
	_rebuild_slots()


func bind_loadout(loadout: PlayerLoadoutComponent) -> void:
	if _loadout != null and is_instance_valid(_loadout):
		if _loadout.weapon_equipped.is_connected(_on_weapon_equipped):
			_loadout.weapon_equipped.disconnect(_on_weapon_equipped)
		if _loadout.loadout_changed.is_connected(_on_loadout_changed):
			_loadout.loadout_changed.disconnect(_on_loadout_changed)
	_loadout = loadout
	if _loadout == null:
		_on_loadout_changed([])
		return
	if not _loadout.weapon_equipped.is_connected(_on_weapon_equipped):
		_loadout.weapon_equipped.connect(_on_weapon_equipped)
	if not _loadout.loadout_changed.is_connected(_on_loadout_changed):
		_loadout.loadout_changed.connect(_on_loadout_changed)
	_on_loadout_changed(_loadout.available_weapons())
	_on_weapon_equipped(_loadout.equipped_weapon, _loadout.equipped_slot_index)


func bind_inventory(inventory: PlayerCombatInventoryComponent) -> void:
	_inventory = inventory
	queue_redraw()


func open_wheel() -> void:
	if _weapons.is_empty():
		return
	_open = true
	visible = true
	set_process(true)
	_selected_index = clampi(_selected_index, 0, _weapons.size() - 1)
	_update_selection_from_pointer()
	queue_redraw()


func close_wheel(commit_selection := true) -> void:
	if not _open:
		return
	_open = false
	visible = false
	set_process(false)
	if commit_selection and _loadout != null and _selected_index >= 0 and _selected_index < _weapons.size():
		var weapon := _weapons[_selected_index]
		if _loadout.equip_weapon(weapon):
			_refill_for_weapon(weapon)


func selected_weapon() -> WeaponData:
	return _weapons[_selected_index] if _selected_index >= 0 and _selected_index < _weapons.size() else null


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not InputMap.has_action(wheel_action):
		return
	if event.is_action_pressed(wheel_action):
		open_wheel()
		get_viewport().set_input_as_handled()
	elif event.is_action_released(wheel_action):
		close_wheel(true)
		get_viewport().set_input_as_handled()
	elif _open:
		if event is InputEventMouseMotion:
			_update_selection_from_pointer()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not _open:
		return
	var stick := Input.get_vector(&"player_aim_left", &"player_aim_right", &"player_aim_up", &"player_aim_down")
	if stick.length() >= stick_deadzone:
		_select_from_vector(stick)
	else:
		_update_selection_from_pointer()


func _draw() -> void:
	if not visible:
		return
	draw_rect(Rect2(Vector2.ZERO, size), shade_color, true)
	if _weapons.is_empty():
		return
	var center := size * 0.5
	var count := _weapons.size()
	for index in count:
		var weapon := _weapons[index]
		var angle := -PI * 0.5 + TAU * float(index) / float(count)
		var slot_center := center + Vector2.RIGHT.rotated(angle) * radius
		var selected := index == _selected_index
		var bg_color := selected_segment_color if selected else segment_color
		if weapon == null or not weapon.is_valid():
			bg_color = locked_segment_color
		draw_circle(slot_center, icon_size * 0.58, bg_color)
		draw_arc(slot_center, icon_size * 0.58, 0.0, TAU, 48, Color(0.02, 0.025, 0.02, 1), 3.0)
		if weapon != null and weapon.weapon_texture != null:
			var texture_size := weapon.weapon_texture.get_size()
			var scale_factor := minf(icon_size / texture_size.x, (icon_size * 0.62) / texture_size.y)
			var draw_size := texture_size * scale_factor
			draw_texture_rect(weapon.weapon_texture, Rect2(slot_center - draw_size * 0.5, draw_size), false)
		var label := _slot_label(weapon, index)
		var font := get_theme_default_font()
		var font_size := 13
		var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
		var label_position := slot_center + Vector2(-label_size.x * 0.5, icon_size * 0.58 + 18.0)
		draw_string(font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size, selected_text_color if selected else text_color)
		var ammo_label := _ammo_label(weapon)
		var ammo_size := font.get_string_size(ammo_label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, 11)
		draw_string(font, label_position + Vector2((label_size.x - ammo_size.x) * 0.5, 16.0), ammo_label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, 11, text_color)
	var selected := selected_weapon()
	var center_label := selected.display_name.to_upper() if selected != null else "ARME"
	var center_font := get_theme_default_font()
	var center_size := 18
	var center_label_size := center_font.get_string_size(center_label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, center_size)
	draw_circle(center, 58.0, Color(0.025, 0.03, 0.025, 0.94))
	draw_arc(center, 58.0, 0.0, TAU, 64, selected_segment_color, 3.0)
	draw_string(center_font, center + Vector2(-center_label_size.x * 0.5, 7.0), center_label, HORIZONTAL_ALIGNMENT_CENTER, -1.0, center_size, text_color)


func _on_loadout_changed(weapons: Array[WeaponData]) -> void:
	_weapons = weapons
	_selected_index = clampi(_selected_index, 0, max(0, _weapons.size() - 1))
	queue_redraw()


func _on_weapon_equipped(_weapon: WeaponData, slot_index: int) -> void:
	if slot_index >= 0:
		_selected_index = slot_index
	queue_redraw()


func _update_selection_from_pointer() -> void:
	var vector := get_global_mouse_position() - get_global_rect().get_center()
	if vector.length() >= pointer_deadzone:
		_select_from_vector(vector)


func _select_from_vector(vector: Vector2) -> void:
	if _weapons.is_empty() or vector.is_zero_approx():
		return
	var normalized_angle := fposmod(vector.angle() + PI * 0.5 + TAU / float(_weapons.size()) * 0.5, TAU)
	_selected_index = clampi(floori(normalized_angle / TAU * float(_weapons.size())), 0, _weapons.size() - 1)
	queue_redraw()


func _slot_label(weapon: WeaponData, index: int) -> String:
	if weapon == null:
		return "%d · VIDE" % [index + 1]
	return "%d · %s" % [index + 1, weapon.display_name.to_upper()]


func _ammo_label(weapon: WeaponData) -> String:
	if weapon == null:
		return ""
	return "∞" if not weapon.uses_special_ammo else "SPECIAL -%d" % weapon.ammo_cost


func _refill_for_weapon(weapon: WeaponData) -> void:
	if not refill_special_ammo_on_select or weapon == null or not weapon.uses_special_ammo:
		return
	if _inventory == null or _inventory.profile == null:
		return
	_inventory.add_ammo(_inventory.profile.maximum_special_ammo - _inventory.special_ammo)


func _rebuild_slots() -> void:
	queue_redraw()
