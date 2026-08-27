class_name ArtDirectionGallery
extends Control

signal back_requested

## Catalogue de planches affichées ; leur ordre dans la Resource définit l'ordre de navigation.
@export var catalog: GalleryCatalog

@onready var board_texture: TextureRect = %BoardTexture
@onready var board_name: Label = %BoardName
@onready var counter: Label = %Counter

var _index := 0


func _ready() -> void:
	%BackButton.pressed.connect(back_requested.emit)
	%PreviousButton.pressed.connect(_show_previous)
	%NextButton.pressed.connect(_show_next)
	%BackButton.grab_focus()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		back_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_left"):
		_show_previous()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_right"):
		_show_next()
		get_viewport().set_input_as_handled()


func _show_previous() -> void:
	if _entry_count() == 0:
		return
	_index = wrapi(_index - 1, 0, _entry_count())
	_refresh()


func _show_next() -> void:
	if _entry_count() == 0:
		return
	_index = wrapi(_index + 1, 0, _entry_count())
	_refresh()


func _entry_count() -> int:
	return 0 if catalog == null else catalog.entries.size()


func _refresh() -> void:
	var count := _entry_count()
	if count == 0:
		board_texture.texture = null
		board_name.text = "AUCUNE PLANCHE"
		counter.text = "0 / 0"
		return
	_index = clampi(_index, 0, count - 1)
	var entry := catalog.entries[_index]
	board_name.text = entry.display_name
	counter.text = "%d / %d" % [_index + 1, count]
	board_texture.texture = entry.board_texture
	%AnimationPlayer.stop()
	%AnimationPlayer.play(&"board_change")
