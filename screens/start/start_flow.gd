class_name StartFlow
extends Control

signal open_gallery_requested
signal open_mission_requested
signal quit_requested


func _ready() -> void:
	%MissionButton.pressed.connect(open_mission_requested.emit)
	%GalleryButton.pressed.connect(open_gallery_requested.emit)
	%QuitButton.pressed.connect(quit_requested.emit)
	%MissionButton.grab_focus()
	%AnimationPlayer.play(&"reveal")

