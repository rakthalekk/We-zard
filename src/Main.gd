extends Node2D


const IceSpell = preload("IceSpell.tscn")

export var LIMIT_LEFT = 0
export var LIMIT_TOP = 0
export var LIMIT_RIGHT = 3660
export var LIMIT_BOTTOM = 900

onready var foreground = $Foreground
onready var snowy_foreground = $Snowy_Foreground
onready var player = $Player

func _ready(): #set camera position
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			camera.limit_left = LIMIT_LEFT
			camera.limit_top = LIMIT_TOP
			camera.limit_right = LIMIT_RIGHT
			camera.limit_bottom = LIMIT_BOTTOM


func _on_Player_ice_spell(dir):
	var spell = IceSpell.instance()
	spell.position = player.position
	spell.dir = dir
	add_child(spell)
	spell.connect("freeze", self, "_on_freeze")
	
func _on_freeze(pos):
	if foreground.get_cellv(foreground.world_to_map(pos)) >= 0:
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos), foreground.get_cellv(foreground.world_to_map(pos)))
		foreground.set_cellv(foreground.world_to_map(pos), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, 0)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, -1)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), -1)
