class_name PlayerAimComponent
extends Node

signal aim_changed(direction: Vector2)
signal facing_changed(direction: float)

@export_category("Authority")
## Profil de visée partagé qui définit directions permises, zone morte et seuil diagonal.
@export var profile: PlayerAimProfile
## Pivot visuel tourné vers la direction de tir ; il porte normalement l'arme et le Muzzle.
@export_node_path("Node2D") var aim_pivot_path := NodePath("../../Visuals/AimPivot")
## Sprite retourné horizontalement lorsque le joueur change de direction principale.
@export_node_path("AnimatedSprite2D") var body_sprite_path := NodePath("../../Visuals/GroundPivot/BodySprite")

var aim_direction := Vector2.RIGHT
var facing := 1.0
var _aim_pivot: Node2D
var _body_sprite: AnimatedSprite2D
var _pointer_aim_active := false


func _ready() -> void:
	_aim_pivot = get_node_or_null(aim_pivot_path) as Node2D
	_body_sprite = get_node_or_null(body_sprite_path) as AnimatedSprite2D
	set_process(not Engine.is_editor_hint() and profile != null and profile.is_valid())
	_apply_direction()


func _process(_delta: float) -> void:
	var horizontal := Input.get_axis(&"player_move_left", &"player_move_right")
	var vertical := 0.0
	if profile.allow_vertical_aim:
		vertical = Input.get_axis(&"player_aim_up", &"player_aim_down")
	if _pointer_aim_active and profile.allow_pointer_aim and _aim_pivot != null:
		if aim_toward_global(_aim_pivot.get_global_mouse_position()):
			return

	var aim_horizontal := Input.get_axis(&"player_aim_left", &"player_aim_right")
	if absf(aim_horizontal) >= profile.input_deadzone:
		set_facing(aim_horizontal)
		set_aim_direction(Vector2(aim_horizontal, vertical))
		return
	if absf(horizontal) >= profile.input_deadzone:
		set_facing(horizontal)
	var requested := Vector2(facing, 0.0)
	if absf(vertical) >= profile.input_deadzone:
		if profile.allow_diagonal_aim and absf(horizontal) >= profile.input_deadzone:
			requested = Vector2(facing, vertical * profile.diagonal_vertical_weight).normalized()
		else:
			requested = Vector2(0.0, signf(vertical))
	set_aim_direction(requested)


func _input(event: InputEvent) -> void:
	if profile == null or not profile.allow_pointer_aim:
		return
	if event is InputEventMouseMotion and event.relative.length_squared() >= 1.0:
		_pointer_aim_active = true
	elif event is InputEventKey and event.pressed:
		_pointer_aim_active = false
	elif event is InputEventJoypadButton and event.pressed:
		_pointer_aim_active = false
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= profile.input_deadzone:
		_pointer_aim_active = false
	elif event is InputEventScreenTouch and event.pressed:
		_pointer_aim_active = false


## Commande intentionnelle partagée par la souris et de futurs systèmes de ciblage.
func aim_toward_global(global_target: Vector2) -> bool:
	if _aim_pivot == null:
		return false
	var offset := global_target - _aim_pivot.global_position
	if offset.length() < profile.pointer_minimum_distance:
		return false
	if not is_zero_approx(offset.x):
		set_facing(offset.x)
	set_aim_direction(offset)
	return true


func set_facing(value: float) -> void:
	var requested := signf(value)
	if is_zero_approx(requested) or is_equal_approx(requested, facing):
		return
	facing = requested
	if _body_sprite != null:
		_body_sprite.flip_h = facing < 0.0
	_apply_weapon_orientation()
	facing_changed.emit(facing)


func set_aim_direction(value: Vector2) -> void:
	if value.is_zero_approx():
		return
	var normalized := value.normalized()
	if normalized.is_equal_approx(aim_direction):
		return
	aim_direction = normalized
	_apply_direction()
	aim_changed.emit(aim_direction)


func _apply_direction() -> void:
	if _aim_pivot != null:
		_aim_pivot.rotation = aim_direction.angle()
	_apply_weapon_orientation()


## Une rotation de PI pour viser à gauche inverse aussi le haut/bas de l'arme.
## Le miroir vertical du pivot conserve donc le canon et le Muzzle à l'endroit.
func _apply_weapon_orientation() -> void:
	if _aim_pivot == null:
		return
	_aim_pivot.scale = Vector2(1.0, -1.0 if facing < 0.0 else 1.0)
