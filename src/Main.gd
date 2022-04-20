extends Node2D


const IceSpell = preload("IceSpell.tscn")
const IceSpellAOE = preload("IceSpellAOE.tscn")
const EarthSpell = preload("EarthSpell.tscn")
const EarthSpellAOE = preload("EarthSpellAOE.tscn")
const FireSpell = preload("FireSpell.tscn")
const FireSpellAOE = preload("FireSpellAOE.tscn")

export var LIMIT_LEFT = 0
export var LIMIT_TOP = 0
export var LIMIT_RIGHT = 3660
export var LIMIT_BOTTOM = 1536
export(Vector2) var camera_zoom_factor = Vector2(1.25, 1.25)

var fire_aoe_instance = null

onready var foreground = $Foreground
onready var icy_foreground = $Icy_Foreground
onready var mushrooms = $Mushrooms
onready var water = $Water
onready var player = $Player

func _ready(): #set camera position
	
	Global.current_level = int(name[name.length() - 1])
	
	player.connect("ice_spell", self, "_on_Player_ice_spell")
	player.connect("ice_spell_aoe", self, "_on_Player_ice_spell_aoe")
	player.connect("earth_spell", self, "_on_Player_earth_spell")
	player.connect("earth_spell_aoe", self, "_on_Player_earth_spell_aoe")
	player.connect("fire_spell", self, "_on_Player_fire_spell")
	player.connect("fire_spell_aoe", self, "_on_Player_fire_spell_aoe")
	
	set_camera_bounds()
	
	for i in range(-64, LIMIT_RIGHT / 64 + 1):
		for j in range(-64, LIMIT_BOTTOM / 64 + 1):
			if foreground.get_cellv(Vector2(i, j)) == 0:
				icy_foreground.set_cellv(Vector2(i, j), 1)


func set_camera_bounds():
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


func _on_Player_ice_spell_aoe():
	var spell = IceSpellAOE.instance()
	spell.position = player.position
	add_child(spell)
	spell.connect("freeze", self, "_on_freeze")


func _on_freeze(pos):
	var update = false
	
	if foreground.get_cellv(foreground.world_to_map(pos)) == 0:
		var id = foreground.get_cellv(foreground.world_to_map(pos))
		if id == 0 || id == 1:
			icy_foreground.set_cellv(icy_foreground.world_to_map(pos), 0)
		foreground.set_cellv(foreground.world_to_map(pos), 1)
		update = true
		
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) == 0:
		var id = foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0)))
		if id == 0 || id == 1:
			icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0)), 0)
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), 1)
		update = true
		
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) == 0:
		var id = foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1)))
		if id == 0 || id == 1:
			icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1)), 0)
		foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), 1)
		update = true
	
	if update:
		update_bitmask()


func _on_Player_earth_spell(dir):
	var spell = EarthSpell.instance()
	spell.position = player.position
	spell.dir = dir
	add_child(spell)
	spell.connect("mushroomify", self, "_on_mushroomify")


func _on_Player_earth_spell_aoe():
	var spell = EarthSpellAOE.instance()
	spell.position = player.position
	add_child(spell)


func _on_mushroomify(pos, direction):
	if foreground.get_cellv(foreground.world_to_map(pos)) >= 0:
		_place_shroom(pos, direction)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		_place_shroom(pos + Vector2(-1, 0), direction)
	elif foreground.get_cellv(foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		_place_shroom(pos + Vector2(-1, -1), direction)
	if icy_foreground.get_cellv(icy_foreground.world_to_map(pos)) >= 0:
		_place_shroom(pos, direction)
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0))) >= 0:
		_place_shroom(pos + Vector2(-1, 0), direction)
	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1))) >= 0:
		_place_shroom(pos + Vector2(-1, -1), direction)


func _place_shroom(pos, direction):
	var update = false
	
	# Downwards mushrooms
	if direction == "down":
		if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(0, -64))) == -1 &&
				icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(0, -64))) == -1):
			mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, -64)), 0)
			update = true
	
	# Left facing mushrooms
	elif direction == "right":
		if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(-64, 0))) == -1 &&
				icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-64, 0))) == -1):
			mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-64, 0)), 1)
			update = true
	
	# Right facing mushrooms
	elif direction == "left":
		if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(64, 0))) == -1 &&
				icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(64, 0))) == -1):
			mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(64, 0)), 2)
			update = true
	
	# Upwards mushrooms
	else:
		if (foreground.get_cellv(foreground.world_to_map(pos + Vector2(0, 64))) == -1 &&
				icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(0, 64))) == -1):
			mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(0, 64)), 3)
			update = true
	
	if update:
		mushrooms.update_bitmask_region()


func _on_Player_fire_spell(dir):
	var spell = FireSpell.instance()
	spell.position = player.position
	spell.dir = dir
	add_child(spell)
	spell.connect("ignite", self, "_on_ignite")


func _on_Player_fire_spell_aoe():
	if !fire_aoe_instance:
		fire_aoe_instance = FireSpellAOE.instance()
		fire_aoe_instance.position = player.position
		add_child(fire_aoe_instance)
	else:
		fire_aoe_instance.detonate()
		fire_aoe_instance = null


func _on_ignite(pos):
	var update = false
	
	if icy_foreground.get_cellv(icy_foreground.world_to_map(pos)) == 0:
		var id = icy_foreground.get_cellv(icy_foreground.world_to_map(pos))
		if id == 0 || id == 1:
			foreground.set_cellv(foreground.world_to_map(pos), 0)
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos), 1)
		update = true

	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0))) == 0:
		var id = icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0)))
		if id == 0 || id == 1:
			foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, 0)), 0)
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, 0)), 1)
		update = true

	elif icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1))) == 0:
		var id = icy_foreground.get_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1)))
		if id == 0 || id == 1:
			foreground.set_cellv(foreground.world_to_map(pos + Vector2(-1, -1)), 0)
		icy_foreground.set_cellv(icy_foreground.world_to_map(pos + Vector2(-1, -1)), 1)
		update = true
	
	if mushrooms.get_cellv(mushrooms.world_to_map(pos)) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos), -1)
		update = true
	elif mushrooms.get_cellv(mushrooms.world_to_map(pos + Vector2(-1, 0))) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-1, 0)), -1)
		update = true
	elif mushrooms.get_cellv(mushrooms.world_to_map(pos + Vector2(-1, -1))) >= 0:
		mushrooms.set_cellv(mushrooms.world_to_map(pos + Vector2(-1, -1)), -1)
		update = true
	
	if update:
		update_bitmask()


func update_bitmask():
	foreground.update_bitmask_region()
	icy_foreground.update_bitmask_region()
	mushrooms.update_bitmask_region()
