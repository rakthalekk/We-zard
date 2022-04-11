class_name BounceFlower
extends StaticBody2D


export var sprouted = false

func _ready():
	if !sprouted:
		$Sprite.modulate = Color(1, 1, 1, 0.5)
	else:
		sprout()


func get_bounce_dir(pos):
	$AnimationPlayer.play("sproing")
	return Vector2(0, -1).rotated(rotation)


func sprout():
	$Sprite.modulate = Color(1, 1, 1, 1)
	set_collision_layer_bit(3, true)
	set_collision_layer_bit(4, false)
