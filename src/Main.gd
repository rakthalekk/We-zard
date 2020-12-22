extends Node2D

export var LIMIT_LEFT = 0
export var LIMIT_TOP = 0
export var LIMIT_RIGHT = 3660
export var LIMIT_BOTTOM = 900

func _ready():
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			camera.limit_left = LIMIT_LEFT
			camera.limit_top = LIMIT_TOP
			camera.limit_right = LIMIT_RIGHT
			camera.limit_bottom = LIMIT_BOTTOM
