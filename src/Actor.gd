class_name Actor
extends KinematicBody2D

export var minimum_bounce_velocity = Vector2(1200, 1200)
export (float, 0, 1.0) var ground_friction = 0.5
export (float, 0, 1.0) var air_friction = 0.025

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


func check_bounce(delta):
	if is_on_floor():
		if landing_frame:
			landing_frame = false
	else:
		if !landing_frame:
			landing_frame = true
	
	if abs(_velocity.y) > abs(bounce_velocity.y):
		bounce_velocity.y = abs(_velocity.y) - 10
	elif !landing_frame:
		bounce_velocity.y = minimum_bounce_velocity.y
	if abs(_velocity.x) > abs(bounce_velocity.x):
		bounce_velocity.x = abs(_velocity.x)
	else:
		bounce_velocity.x = minimum_bounce_velocity.x


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

