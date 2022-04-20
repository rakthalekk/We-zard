extends Node


var current_level = 1

func set_current_level(level):
	current_level = level
	if current_level == 0:
		get_tree().change_scene("res://src/Main.tscn")
	else:
		get_tree().change_scene("res://src/Level" + str(level) + ".tscn")
