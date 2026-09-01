@tool
class_name MissionHUD
extends Control

@export_category("Presentation")
## Resource autoritaire des cadres, icônes et couleurs du HUD de mission.
@export var theme_profile: MissionHUDTheme:
	set(value):
		theme_profile = value
		_apply_theme()

var _health: PlayerHealthComponent
var _inventory: PlayerCombatInventoryComponent
var _weapon: PlayerWeaponComponent
var _loadout: PlayerLoadoutComponent
var _boss_health: EnemyHealthComponent


func _ready() -> void:
	_apply_theme()
	%BossStatus.visible = false
	%OverdriveStatus.visible = false
	%ResultPanel.visible = false


func bind_player(player: PlayerCharacter2D) -> void:
	_disconnect_player_sources()
	if player == null:
		return
	_health = player.health_component()
	_inventory = player.combat_inventory_component()
	_weapon = player.weapon_component()
	_loadout = player.loadout_component()
	%WeaponWheel.bind_loadout(_loadout)
	%WeaponWheel.bind_inventory(_inventory)
	if _health != null and _health.profile != null:
		_on_health_changed(_health.current_health, _health.profile.maximum_health)
		if not _health.health_changed.is_connected(_on_health_changed):
			_health.health_changed.connect(_on_health_changed)
	if _inventory != null and _inventory.profile != null:
		_on_ammo_changed(_inventory.special_ammo, _inventory.profile.maximum_special_ammo)
		_on_armor_changed(_inventory.armor, _inventory.profile.maximum_armor)
		_on_overdrive_changed(_inventory.overdrive_remaining)
		if not _inventory.ammo_changed.is_connected(_on_ammo_changed):
			_inventory.ammo_changed.connect(_on_ammo_changed)
		if not _inventory.armor_changed.is_connected(_on_armor_changed):
			_inventory.armor_changed.connect(_on_armor_changed)
		if not _inventory.overdrive_changed.is_connected(_on_overdrive_changed):
			_inventory.overdrive_changed.connect(_on_overdrive_changed)
	if _weapon != null:
		_on_weapon_changed(_weapon.weapon)
		if not _weapon.weapon_changed.is_connected(_on_weapon_changed):
			_weapon.weapon_changed.connect(_on_weapon_changed)


func bind_boss(enemy: EnemyCharacter2D) -> void:
	if _boss_health != null and is_instance_valid(_boss_health) and _boss_health.health_changed.is_connected(_on_boss_health_changed):
		_boss_health.health_changed.disconnect(_on_boss_health_changed)
	_boss_health = enemy.health_component() if enemy != null else null
	if enemy == null or enemy.profile == null or _boss_health == null:
		%BossStatus.visible = false
		return
	%BossName.text = str(enemy.profile.archetype_id).replace("_", " ").to_upper()
	_on_boss_health_changed(_boss_health.current_health, enemy.profile.maximum_health)
	if not _boss_health.health_changed.is_connected(_on_boss_health_changed):
		_boss_health.health_changed.connect(_on_boss_health_changed)
	%BossStatus.visible = true


func set_objective_text(value: String) -> void:
	%ObjectiveLabel.text = value
	%ObjectiveStatus.visible = not value.strip_edges().is_empty()


func show_loading(message := "EN COURS") -> void:
	%LoadingTitle.text = "DÉPLOIEMENT"
	%MissionStatusLabel.text = message
	%MissionStatusPanel.visible = true


func hide_loading() -> void:
	%MissionStatusPanel.visible = false


func show_error(errors: PackedStringArray) -> void:
	%LoadingTitle.text = "MISSION INDISPONIBLE"
	%MissionStatusLabel.text = "\n".join(errors)
	%MissionStatusPanel.visible = true


func show_result(message: String) -> void:
	%ResultLabel.text = message
	%ResultPanel.visible = true


func _on_health_changed(current: float, maximum: float) -> void:
	%Health.max_value = maximum
	%Health.value = current
	%HealthValue.text = "%d / %d" % [roundi(current), roundi(maximum)]


func _on_ammo_changed(current: int, maximum: int) -> void:
	%AmmoValue.text = "%02d / %02d" % [current, maximum]
	_refresh_weapon_ammo_visibility()


func _on_armor_changed(current: float, maximum: float) -> void:
	%Armor.max_value = maximum
	%Armor.value = current
	%ArmorValue.text = "ARMURE %d" % roundi(current)


func _on_overdrive_changed(remaining: float) -> void:
	var duration := _inventory.profile.overdrive_duration * 2.0 if _inventory != null and _inventory.profile != null else 1.0
	%Overdrive.max_value = duration
	%Overdrive.value = remaining
	%OverdriveValue.text = "SURCHARGE %.1f s" % remaining
	%OverdriveStatus.visible = remaining > 0.0


func _on_weapon_changed(weapon_data: WeaponData) -> void:
	%WeaponName.text = weapon_data.display_name.to_upper() if weapon_data != null else "ARME INCONNUE"
	%WeaponPreview.texture = weapon_data.weapon_texture if weapon_data != null else null
	%WeaponPreview.visible = %WeaponPreview.texture != null
	if _inventory != null and _inventory.profile != null:
		_on_ammo_changed(_inventory.special_ammo, _inventory.profile.maximum_special_ammo)
	else:
		_refresh_weapon_ammo_visibility()


func _refresh_weapon_ammo_visibility() -> void:
	var uses_special_ammo := _weapon != null and _weapon.weapon != null and _weapon.weapon.uses_special_ammo
	%AmmoValue.text = %AmmoValue.text if uses_special_ammo else "MUNITIONS ∞"
	%AmmoIcon.modulate = Color.WHITE if uses_special_ammo else Color(1.0, 1.0, 1.0, 0.55)


func _on_boss_health_changed(current: float, maximum: float) -> void:
	%BossHealth.max_value = maximum
	%BossHealth.value = current
	%BossValue.text = "%d / %d" % [roundi(current), roundi(maximum)]


func _disconnect_player_sources() -> void:
	if _health != null and is_instance_valid(_health) and _health.health_changed.is_connected(_on_health_changed):
		_health.health_changed.disconnect(_on_health_changed)
	if _inventory != null and is_instance_valid(_inventory):
		if _inventory.ammo_changed.is_connected(_on_ammo_changed):
			_inventory.ammo_changed.disconnect(_on_ammo_changed)
		if _inventory.armor_changed.is_connected(_on_armor_changed):
			_inventory.armor_changed.disconnect(_on_armor_changed)
		if _inventory.overdrive_changed.is_connected(_on_overdrive_changed):
			_inventory.overdrive_changed.disconnect(_on_overdrive_changed)
	if _weapon != null and is_instance_valid(_weapon) and _weapon.weapon_changed.is_connected(_on_weapon_changed):
		_weapon.weapon_changed.disconnect(_on_weapon_changed)
	_health = null
	_inventory = null
	_weapon = null
	_loadout = null
	if is_node_ready():
		%WeaponWheel.bind_loadout(null)
		%WeaponWheel.bind_inventory(null)


func _apply_theme() -> void:
	if not is_node_ready() or theme_profile == null:
		return
	%PlayerFrame.texture = theme_profile.player_status_frame
	%WeaponFrame.texture = theme_profile.weapon_status_frame
	%ObjectiveFrame.texture = theme_profile.objective_frame
	%BossFrame.texture = theme_profile.boss_health_frame
	%OverdriveFrame.texture = theme_profile.overdrive_frame
	%ResultFrame.texture = theme_profile.notification_frame
	%LoadingBackdrop.texture = theme_profile.loading_background
	%LoadingFrame.texture = theme_profile.notification_frame
	%PlayerPortrait.texture = theme_profile.player_portrait
	%HealthIcon.texture = theme_profile.health_icon
	%ArmorIcon.texture = theme_profile.armor_icon
	%AmmoIcon.texture = theme_profile.ammo_icon
	%ObjectiveIcon.texture = theme_profile.objective_icon
	for label in [%HealthValue, %ArmorValue, %WeaponName, %AmmoValue, %ObjectiveLabel, %BossName, %BossValue, %OverdriveValue]:
		label.add_theme_color_override("font_color", theme_profile.primary_text_color)
	_apply_bar_style(%Health, theme_profile.health_fill_color)
	_apply_bar_style(%Armor, theme_profile.armor_fill_color)
	_apply_bar_style(%BossHealth, theme_profile.boss_fill_color)
	_apply_bar_style(%Overdrive, theme_profile.overdrive_fill_color)


func _apply_bar_style(progress_bar: ProgressBar, fill_color: Color) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = theme_profile.bar_background_color
	background.corner_radius_top_left = 3
	background.corner_radius_top_right = 3
	background.corner_radius_bottom_right = 3
	background.corner_radius_bottom_left = 3
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_right = 3
	fill.corner_radius_bottom_left = 3
	progress_bar.add_theme_stylebox_override("background", background)
	progress_bar.add_theme_stylebox_override("fill", fill)


func _get_configuration_warnings() -> PackedStringArray:
	return PackedStringArray(["Assigner un MissionHUDTheme valide."]) if theme_profile == null or not theme_profile.is_valid() else PackedStringArray()
