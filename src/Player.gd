class_name Player
extends KinematicBody2D

export var speed = Vector2(300.0, 900.0)
export (float, 0, 1.0) var ground_friction = 0.5
export (float, 0, 1.0) var air_friction = 0.05
export (float, 0, 1.0) var acceleration = 0.25

const FLOOR_NORMAL = Vector2.UP
const FLOOR_DETECT_DISTANCE = 20.0
const DASH_SPEED = Vector2(1200, 1200)
const DASH_TIME = 0.20

signal ice_spell

var _velocity = Vector2.ZERO
var friction = ground_friction
var dash_timer = 0
var air_dash = false
var dashing = false
var stored_dir = Vector2(0, 0)

onready var gravity = ProjectSettings.get("physics/2d/default_gravity")
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite

func _physics_process(delta):
	var direction = Vector2.ZERO
	if !dashing:
		_velocity.y += gravity * delta
		direction = get_direction()
		var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
		calculate_move_velocity(acceleration, direction, speed, is_jump_interrupted)
	
	if Input.is_action_just_pressed("dash") && dash_timer == 0 && !air_dash: #speeding up (dashing)
		dash_timer = DASH_TIME
		_velocity.y = 0
		dashing = true
		direction = get_dash_direction()
	if dash_timer > 0:
		handle_dash(delta)
	if is_on_floor():
		air_dash = false
		
	if get_slide_count() > 0: #slowing down
		for i in get_slide_count():
			if get_slide_collision(i).collider.is_in_group("icy"):
				friction = 0
			else:
				friction = ground_friction
	else:
		friction = air_friction
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false
	)
	
	if direction.x != 0:
		sprite.scale.x = 1 if direction.x > 0 else -1
	#var animation = get_new_animation()
	#animation_player.play(animation)
	
	if Input.is_action_just_pressed("ice_spell"):#action button casts freeze spell 
		emit_signal("ice_spell")


func get_direction(): #get direction of the character 
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if (is_on_floor()) and Input.is_action_just_pressed("jump") else 0
	)
	
	
func calculate_move_velocity(acc, direction, speedl, is_jump_interrupted): #determine how fast the character is moving
	if direction.x != 0:
		_velocity.x = lerp(_velocity.x, direction.x * speedl.x, acc)
	else:
		_velocity.x = lerp(_velocity.x, 0, friction)
	if direction.y != 0.0:
		_velocity.y = speedl.y * direction.y
	if is_jump_interrupted:
		_velocity.y *= 0.5


func get_dash_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	return dir if dir.length() != 0 else Vector2(sprite.scale.x, 0)


func handle_dash(delta):
	if stored_dir.length() == 0:
		stored_dir = get_dash_direction()
	var direction = stored_dir
	calculate_move_velocity(0.5, direction, DASH_SPEED, false)
	dash_timer -= delta
	if dash_timer <= 0:
		dash_timer = 0
		dashing = false
		_velocity.x *= 0.2 if friction != 0 else 1
		_velocity.y *= 0.2 if _velocity.y < 0 else 1
		stored_dir = Vector2(0, 0)
	if !is_on_floor():
		air_dash = true


func get_new_animation(): 
	var animation_new = ""
	if is_on_floor():
		animation_new = "running" if abs(_velocity.x) > 0.1 else "idle"
	else:
		animation_new = "jumping"
	return animation_new
