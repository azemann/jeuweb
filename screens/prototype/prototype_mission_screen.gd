class_name PrototypeMissionScreen
extends Control

signal back_requested


func _ready() -> void:
	%DesignReferencePanel.visible = false
	%BackButton.pressed.connect(back_requested.emit)
	%ActorSpawner.player_spawned.connect(_on_player_spawned)
	if %ActorSpawner.current_player != null:
		_on_player_spawned(%ActorSpawner.current_player, null)
	%BackButton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()


func _on_player_spawned(player: PlayerCharacter2D, _spawn: MapSpawnPoint2D) -> void:
	var health := player.health_component()
	if health == null or health.profile == null:
		return
	%Health.max_value = health.profile.maximum_health
	%Health.value = health.current_health
	if not health.health_changed.is_connected(_on_player_health_changed):
		health.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(current: float, maximum: float) -> void:
	%Health.max_value = maximum
	%Health.value = current
