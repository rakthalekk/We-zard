extends Node2D


const IceSpell = preload("IceSpell.tscn")
const EarthSpell = preload("EarthSpell.tscn")

export var LIMIT_LEFT = 0
export var LIMIT_TOP = 0
export var LIMIT_RIGHT = 3660
export var LIMIT_BOTTOM = 900

onready var foreground = $Foreground
onready var snowy_foreground = $Snowy_Foreground
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
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos), foreground.get_cellv(foreground.world_to_map(pos)))
		foreground.set_cellv(foreground.world_to_map(pos), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, 0)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), -1)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		snowy_foreground.set_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, -1)), foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))))
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), -1)


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
	if snowy_foreground.get_cellv(snowy_foreground.world_to_map(pos)) >= 0:
		_place_shroom(pos, snowy_foreground)
	elif snowy_foreground.get_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		_place_shroom(pos + Vector2(-1, 0), snowy_foreground)
	elif snowy_foreground.get_cellv(snowy_foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		_place_shroom(pos + Vector2(-1, -1), snowy_foreground)


func _place_shroom(pos, tilemap = foreground):
	if tilemap.get_cellv(tilemap.world_to_map(pos + Vector2(0, -32))) == -1:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, -32)), 0)
	if tilemap.get_cellv(tilemap.world_to_map(pos + Vector2(-32, 0))) == -1:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-32, 0)), 1)
	if tilemap.get_cellv(tilemap.world_to_map(pos + Vector2(32, 0))) == -1:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(32, 0)), 2)
	if tilemap.get_cellv(tilemap.world_to_map(pos + Vector2(0, 32))) == -1:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, 32)), 3)
