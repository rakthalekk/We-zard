class_name Actor
extends KinematicBody2D

export var minimum_bounce_velocity = Vector2(1200, 1200)
export var maximum_bounce_velocity = Vector2(2000, 2000)
export (float, 0, 1.0) var ground_friction = 0.5
export (float, 0, 1.0) var air_friction = 0.005
export (float, 0, 1.0) var acceleration = 0.1

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0

var _velocity = Vector2.ZERO
var friction = ground_friction
var bounce_velocity = Vector2(0, 0)
var landing_frame = false

onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite


func apply_gravity(delta, factor = 1):
	_velocity.y += factor * gravity * delta


func handle_movement(delta):
	_velocity = move_and_slide_with_snap(
		_velocity, Vector2.ZERO, FLOOR_NORMAL, false, 4, 0.9, false
	)
	
	check_bounce(delta)
	
	check_collisions()


func check_bounce(delta):
	if is_on_floor():
		if landing_frame:
			landing_frame = false
	else:
		if !landing_frame:
			landing_frame = true
	
	if abs(_velocity.y) > abs(bounce_velocity.y):
		if abs(_velocity.y) > maximum_bounce_velocity.y:
			bounce_velocity.y = maximum_bounce_velocity.y - 10
		else:
			bounce_velocity.y = abs(_velocity.y) - 10
	elif !landing_frame:
		bounce_velocity.y = minimum_bounce_velocity.y
	if abs(_velocity.x) > abs(bounce_velocity.x):
		if abs(_velocity.x) > maximum_bounce_velocity.x:
			bounce_velocity.x = maximum_bounce_velocity.x
		else:
			bounce_velocity.x = abs(_velocity.x)
	else:
		bounce_velocity.x = minimum_bounce_velocity.x


func check_collisions():
	if get_slide_count() > 0:
		for i in get_slide_count():
			var col = get_slide_collision(i)
			if !col:
				return
			if col.collider.is_in_group("icy"):
				friction = 0
			elif is_on_floor():
				friction = ground_friction
			else:
				friction = air_friction
	else:
		friction = air_friction


func apply_bounce_velocity(body):
	var dir = body.get_bounce_dir(position)
	if dir.x != 0:
		_velocity.x = bounce_velocity.x * dir.x
	if dir.y != 0:
		_velocity.y = bounce_velocity.y * dir.y
	handle_movement(0.05)

