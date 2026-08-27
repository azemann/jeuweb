class_name ToxicPressureImpact2D
extends Node2D

@onready var sprite: AnimatedSprite2D = $Visuals


func _ready() -> void:
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	queue_free()
