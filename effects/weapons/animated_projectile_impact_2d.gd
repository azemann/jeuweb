class_name AnimatedProjectileImpact2D
extends Node2D

@onready var sprite: AnimatedSprite2D = $Visuals


func _ready() -> void:
	sprite.animation_finished.connect(queue_free)
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(&"impact"):
		sprite.play(&"impact")
	else:
		queue_free()
