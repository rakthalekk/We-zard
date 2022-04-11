extends StaticBody2D

const WIND_COLUMN = preload("res://src/WindColumn.tscn")

export var sprouted = false

func _ready():
	if !sprouted:
		$Sprite.modulate = Color(1, 1, 1, 0.5)
	else:
		sprout()


func sprout():
	$AnimationPlayer.play("woosh")
	$Sprite.modulate = Color(1, 1, 1, 1)
	set_collision_layer_bit(4, false)
	
	var c = WIND_COLUMN.instance()
	c.global_position = global_position
	c.rotation = rotation
	c.direction = Vector2(0, -1).rotated(rotation)
	get_parent().add_child(c)
