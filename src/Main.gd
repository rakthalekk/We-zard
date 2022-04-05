extends Node2D


const IceSpell = preload("IceSpell.tscn")
const EarthSpell = preload("EarthSpell.tscn")
const FireSpell = preload("FireSpell.tscn")

export var LIMIT_LEFT = 0
export var LIMIT_TOP = 0
export var LIMIT_RIGHT = 3660
export var LIMIT_BOTTOM = 900

onready var foreground = $Foreground
onready var icy_foreground = $Icy_Foreground
onready var mushrooms = $Mushrooms
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
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos), foreground.get_cellv(foreground.world_to_map(pos)))
		foreground.set_cellv(foreground.world_to_map(pos), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), -1)
	
	icy_foreground.update_bitmask_region()


func _on_Player_earth_spell(dir):
	var spell = EarthSpell.instance()
	spell.position = player.position
	spell.dir = dir
	add_child(spell)
	spell.connect("mushroomify", self, "_on_mushroomify")


func _on_mushroomify(pos):
	if foreground.get_cellv(foreground.world_to_map(pos)) >= 0:
		_place_shroom(pos)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		_place_shroom(pos + Vector2(-1, 0))
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		_place_shroom(pos + Vector2(-1, -1))
	if icy_foreground.get_cellv(icy_foreground.world_to_map(pos)) >= 0:
		_place_shroom(pos)
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		_place_shroom(pos + Vector2(-1, 0))
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		_place_shroom(pos + Vector2(-1, -1))


func _place_shroom(pos):
	# Downwards mushrooms
	if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(0, -64))) == -1 &&
			icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(0, -64))) == -1):
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, -64)), 0)
	
	# Left facing mushrooms
	if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(-64, 0))) == -1 &&
			icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-64, 0))) == -1):
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-64, 0)), 1)
	
	# Right facing mushrooms
	if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(64, 0))) == -1 &&
			icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(64, 0))) == -1):
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(64, 0)), 2)
	
	# Upwards mushrooms
	if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(0, 64))) == -1 &&
			icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(0, 64))) == -1):
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, 64)), 3)
		
	mushrooms.update_bitmask_region()


func _on_Player_fire_spell(dir):
	var spell = FireSpell.instance()
	spell.position = player.position
	spell.dir = dir
	add_child(spell)
	spell.connect("ignite", self, "_on_ignite")


func _on_ignite(pos):
	if icy_foreground.get_cellv(icy_foreground.world_to_map(pos)) >= 0:
		foreground.set_cellv(foreground.world_to_map(pos), icy_foreground.get_cellv(icy_foreground.world_to_map(pos)))
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos), -1)
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0))))
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0)), -1)
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1))))
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1)), -1)
	
	if mushrooms.get_cellv(mushrooms.world_to_map(pos)) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos), -1)
	elif mushrooms.get_cellv(mushrooms.world_to_map(pos + Vector2(-1, 0))) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-1, 0)), -1)
	elif mushrooms.get_cellv(mushrooms.world_to_map(pos + Vector2(-1, -1))) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-1, -1)), -1)
	
	foreground.update_bitmask_region()
	icy_foreground.update_bitmask_region()
	mushrooms.update_bitmask_region()
