@tool
class_name MobileControls
extends Control

@export_category("Visibility")
## Permet de prévisualiser les commandes tactiles sur ordinateur.
@export var show_on_desktop := false:
	set(value):
		show_on_desktop = value
		_update_runtime_visibility()

@export_category("Layout")
## Rayon tactile et visuel des boutons, en pixels ; plus grand facilite l'appui mais occupe davantage l'écran.
@export_range(36.0, 80.0, 1.0, "suffix:px") var button_radius := 52.0:
	set(value):
		button_radius = value
		_layout_controls()
## Distance, en pixels, conservée entre les commandes et les bords sûrs de l'écran.
@export_range(12.0, 96.0, 1.0, "suffix:px") var edge_margin := 28.0:
	set(value):
		edge_margin = value
		_layout_controls()

const BUTTONS := {
	"Left": "LeftVisual",
	"Right": "RightVisual",
	"Up": "UpVisual",
	"Down": "DownVisual",
	"Jump": "JumpVisual",
	"Fire": "FireVisual",
	"Interact": "InteractVisual",
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not resized.is_connected(_layout_controls):
		resized.connect(_layout_controls)
	_connect_feedback()
	_update_runtime_visibility()
	_layout_controls()


func _update_runtime_visibility() -> void:
	if not is_inside_tree():
		return
	visible = Engine.is_editor_hint() or show_on_desktop or DisplayServer.is_touchscreen_available()


func _layout_controls() -> void:
	if not is_inside_tree():
		return
	var spacing := button_radius * 1.15
	var direction_center := Vector2(
		edge_margin + button_radius * 2.25,
		size.y - edge_margin - button_radius - spacing
	)
	_place_button("Left", direction_center + Vector2.LEFT * spacing)
	_place_button("Right", direction_center + Vector2.RIGHT * spacing)
	_place_button("Up", direction_center + Vector2.UP * spacing)
	_place_button("Down", direction_center + Vector2.DOWN * spacing)

	var fire_center := Vector2(size.x - edge_margin - button_radius, size.y - edge_margin - button_radius)
	var jump_center := fire_center + Vector2(-button_radius * 2.25, -button_radius * 1.45)
	var interact_center := fire_center + Vector2(0.0, -button_radius * 2.4)
	_place_button("Fire", fire_center)
	_place_button("Jump", jump_center)
	_place_button("Interact", interact_center)


func _place_button(button_name: String, center: Vector2) -> void:
	var button := get_node_or_null(button_name) as TouchScreenButton
	var visual := get_node_or_null(BUTTONS[button_name]) as Control
	if button != null:
		button.position = center
		var circle := button.shape as CircleShape2D
		if circle != null:
			circle.radius = button_radius
	if visual != null:
		visual.position = center - Vector2.ONE * button_radius
		visual.size = Vector2.ONE * button_radius * 2.0


func _connect_feedback() -> void:
	for button_name in BUTTONS:
		var button := get_node_or_null(button_name) as TouchScreenButton
		var visual := get_node_or_null(BUTTONS[button_name]) as Control
		if button == null or visual == null:
			continue
		var press_callback := _set_visual_pressed.bind(visual, true)
		var release_callback := _set_visual_pressed.bind(visual, false)
		if not button.pressed.is_connected(press_callback):
			button.pressed.connect(press_callback)
		if not button.released.is_connected(release_callback):
			button.released.connect(release_callback)


func _set_visual_pressed(visual: Control, pressed: bool) -> void:
	visual.modulate = Color(1.0, 0.72, 0.25, 1.0) if pressed else Color.WHITE
