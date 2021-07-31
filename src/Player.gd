class_name Player
extends KinematicBody2D

export var base_speed = Vector2(400.0, 900.0)
export var wall_jump_speed = Vector2(2500, 800)
export var minimum_bounce_velocity = Vector2(1200, 1200)
export (float, 0, 1.0) var ground_friction = 0.5
export (float, 0, 1.0) var air_friction = 0.025
export (float, 0, 1.0) var acceleration = 0.1

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0
const DASH_SPEED = Vector2(1200, 1200)
const DASH_TIME = 0.20

signal ice_spell(dir)
signal earth_spell(dir)

var current_spell = "ice_spell"
var move_direction = Vector2.ZERO
var _velocity = Vector2.ZERO
var friction = ground_friction
var dash_timer = 0
var air_dash = false
var haha_ice = false
var cast_dir = Vector2(0, 0)
var useless_boolean_that_i_shouldnt_need = false
var wall_direction = 1
var bounce_velocity = Vector2(0, 0)
var landing_frame = false

onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
onready var state_machine = $StateMachine # avoid using when possible, manual state changes can be bad
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var cast_line = $CastLine
onready var left_rays = $"WallColliders/LeftColliders"
onready var right_rays = $"WallColliders/RightColliders"
onready var down_shroom = $"MushroomColliders/Down"


func check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			if raycast.get_collider().get_name() == "Snowy_Foreground":
				haha_ice = true
			else:
				haha_ice = false
			return true
	return false


func update_wall_direction():
	var is_near_wall_left = check_is_valid_wall(left_rays)
	var is_near_wall_right = check_is_valid_wall(right_rays)
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
	if !is_near_wall_left and !is_near_wall_right:
		haha_ice = false


func wall_jump():
	calculate_move_velocity(0.5, Vector2(-wall_direction, -1), wall_jump_speed, false)


func display_cast_line():
	if get_input_dir().length() != 0 && useless_boolean_that_i_shouldnt_need:
		cast_dir = get_input_dir()
	cast_line.points[1] = 200 * cast_dir
	
	
func apply_gravity(delta, factor = 1):
	_velocity.y += factor * gravity * delta


func regular_movement():
	move_direction = get_direction()
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	calculate_move_velocity(acceleration, move_direction, base_speed, is_jump_interrupted)


func handle_movement(delta):
	if is_on_floor():
		if landing_frame:
			landing_frame = false;
		else:
			air_dash = false
	else:
		if !landing_frame:
			landing_frame = true
		
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if move_direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false
	)
	
	if move_direction.x != 0:
		sprite.scale.x = 1 if move_direction.x > 0 else -1
		
	if abs(_velocity.y) > abs(bounce_velocity.y):
		bounce_velocity.y = _velocity.y
	elif !landing_frame:
		bounce_velocity.y = minimum_bounce_velocity.y
	if abs(_velocity.x) > abs(bounce_velocity.x):
		bounce_velocity.x = _velocity.x
	else:
		bounce_velocity.x = minimum_bounce_velocity.x
	check_collisions()


func check_collisions():
	if get_slide_count() > 0:
		for i in get_slide_count():
			if get_slide_collision(i).collider.is_in_group("icy"):
				friction = 0
			else:
				friction = ground_friction
	else:
		friction = air_friction


func get_direction(): #get direction of the character 
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if (is_on_floor()) and Input.is_action_just_pressed("jump") else 0
	)
	
	
func calculate_move_velocity(acc, direction, speed, is_jump_interrupted): #determine how fast the character is moving
	if direction.x != 0:
		if ((direction.x > 0) == (_velocity.x > 0)) && abs(_velocity.x) > abs(speed.x):
			_velocity.x = lerp(_velocity.x, 0, friction)
		else:
			_velocity.x = lerp(_velocity.x, direction.x * speed.x, acc)
	else:
		_velocity.x = lerp(_velocity.x, 0, friction)
	if direction.y != 0.0:
		_velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		_velocity.y *= 0.5


func get_input_dir():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()


func get_dash_direction():
	var dir = get_input_dir()
	return dir if dir.length() != 0 else Vector2(sprite.scale.x, 0)


func handle_dash(delta):
	calculate_move_velocity(0.5, move_direction, DASH_SPEED, false)
	dash_timer -= delta
	if dash_timer <= 0:
		reset_dash(delta)
	if !is_on_floor():
		air_dash = true


func reset_dash(delta):
	dash_timer = 0
	apply_gravity(delta)
	handle_movement(delta)
	_velocity.x = move_direction.x * base_speed.x if friction != 0 else _velocity.x
	_velocity.y *= 0.2 if !haha_ice else 0.6


func cancel_dash():
	if dash_timer > 0:
		reset_dash(0.001)
	$StateMachine.set_state($StateMachine.states.jump)


func _on_SpellCast_timeout():
	$SpellCast.stop()
	emit_signal(current_spell, cast_dir)
	cast_dir = Vector2.ZERO
	useless_boolean_that_i_shouldnt_need= false


func _on_Down_body_entered(body):
	cancel_dash()
	_velocity.y = -bounce_velocity.y
	handle_movement(0.05)


func _on_Up_body_entered(body):
	cancel_dash()
	_velocity.y = bounce_velocity.y
	handle_movement(0.05)


func _on_Left_body_entered(body):
	cancel_dash()
	_velocity.x = bounce_velocity.x
	handle_movement(0.05)


func _on_Right_body_entered(body):
	cancel_dash()
	_velocity.x = -bounce_velocity.x
	handle_movement(0.05)
