class_name Player
extends "res://src/Actor.gd"


const ICE_WIZARD = preload("res://assets/Player Sprites/ice_wizard.png")
const EARTH_WIZARD = preload("res://assets/Player Sprites/earth_wizard.png")
const FIRE_WIZARD = preload("res://assets/Player Sprites/fire_wizard.png")

export(Vector2) var default_camera_zoom = Vector2(1.25, 1.25)
export var base_speed = Vector2(550.0, 900.0)
export var wall_jump_speed = Vector2(1600, 800)

const DASH_SPEED = Vector2(1400, 1400)
const DASH_TIME = 0.20

signal ice_spell(dir)
signal ice_spell_aoe()
signal earth_spell(dir)
signal earth_spell_aoe()
signal fire_spell(dir)
signal fire_spell_aoe()

var current_spell = "ice_spell"
var move_direction = Vector2.ZERO
var dash_timer = 0
var air_dash = false
var haha_ice = false
var cast_dir = Vector2(0, 0)
var useless_boolean_that_i_shouldnt_need = false
var wall_direction = 1
var in_wind_column = false
var in_water = false
var blasting = false


onready var state_machine = $StateMachine # avoid using when possible, manual state changes can be bad
onready var cast_line = $CastLine
onready var left_rays = $"WallColliders/LeftColliders"
onready var right_rays = $"WallColliders/RightColliders"
onready var spell_cooldown = $SpellCooldown
onready var aoe_cast_time = $AOECastTime
onready var oof_ouch_timer = $OofOuchTimer


func initialize_sprites():
	animation_player = $Ice/AnimationPlayer
	sprite = $Ice/Sprite


func check_raycasts(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("icy"):
				haha_ice = true
			else:
				haha_ice = false
			return true
	return false


func update_wall_direction():
	var is_near_wall_left = check_raycasts(left_rays)
	var is_near_wall_right = check_raycasts(right_rays)
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction.x
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
	if !is_near_wall_left and !is_near_wall_right:
		haha_ice = false


# No longer in use, keeping in case we want to re-add
func wall_jump():
	calculate_move_velocity(0.5, Vector2(-wall_direction, -1), wall_jump_speed, false)


func display_cast_line():
	if useless_boolean_that_i_shouldnt_need:
		cast_dir = (get_global_mouse_position() - global_position).normalized()
	cast_line.points[1] = 200 * cast_dir


func regular_movement():
	move_direction = get_direction()
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	calculate_move_velocity(acceleration, move_direction, base_speed, is_jump_interrupted)


func handle_movement(delta):
	if is_on_floor() && !landing_frame:
		air_dash = false
		
	check_bounce(delta)
	
	apply_velocity(delta)
	
	if move_direction.x != 0:
		sprite.scale.x = 1 if move_direction.x > 0 else -1
	
	check_collisions()


func apply_velocity(delta):
	var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if move_direction.y == 0.0 else Vector2.ZERO
	if in_water:
		_velocity *= 0.9
	_velocity = move_and_slide_with_snap(
		_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false
	)


func get_direction(): #get direction of the character 
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if (is_on_floor()) and Input.is_action_just_pressed("jump") else 0
	)
	
	
func calculate_move_velocity(acc, direction, speed, is_jump_interrupted): #determine how fast the character is moving
	if blasting:
		friction = 0
	# Player is moving horizontally
	if direction.x != 0:
		# If player's velocity is faster than speed, only use friction
		if ((direction.x > 0) == (_velocity.x > 0)) && abs(_velocity.x) > abs(speed.x):
			_velocity.x = lerp(_velocity.x, 0, friction)
		
		# If velocity is faster than speed, and player is pushing in other direction, reduce acceleration
		elif abs(_velocity.x) > abs(speed.x):
			if is_on_floor():
				_velocity.x = lerp(_velocity.x, direction.x * speed.x, acc / 2.5)
			else:
				_velocity.x = lerp(_velocity.x, direction.x * speed.x, acc / 3.5)
		
		# Otherwise, use normal acceleration
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
	if dash_timer > DASH_TIME - delta * 3:
		move_direction = get_dash_direction()
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
	_velocity.x = move_direction.x * base_speed.x if friction != 0 || in_wind_column else _velocity.x
	if !in_wind_column:
		_velocity.y *= 0.2 if !haha_ice else 1


func cancel_dash():
	if dash_timer > 0:
		reset_dash(0.001)
	$StateMachine.set_state($StateMachine.states.jump)


func change_spell(spell):
	if spell == "ice_spell":
		current_spell = "ice_spell"
		cast_line.default_color = Color(0.4, 0.5, 1)
		sprite = $Ice/Sprite
		animation_player = $Ice/AnimationPlayer
		$Nature.visible = false
		$Ice.visible = true
		$Fire.visible = false
	elif spell == "earth_spell":
		current_spell = "earth_spell"
		cast_line.default_color = Color(0.1, 0.7, 0.3)
		sprite = $Nature/Sprite
		animation_player = $Nature/AnimationPlayer
		$Nature.visible = true
		$Ice.visible = false
		$Fire.visible = false
	elif spell == "fire_spell":
		current_spell = "fire_spell"
		cast_line.default_color = Color(1, 0.3, 0.3)
		sprite = $Fire/Sprite
		animation_player = $Fire/AnimationPlayer
		$Nature.visible = false
		$Ice.visible = false
		$Fire.visible = true


func cast_spell():
	spell_cooldown.start()
	emit_signal(current_spell, cast_dir)
	cast_dir = Vector2.ZERO
	useless_boolean_that_i_shouldnt_need = false


func cast_aoe_spell():
	if current_spell == "fire_spell":
		spell_cooldown.start()
		emit_signal(current_spell + "_aoe")
	else:
		aoe_cast_time.start()


func _on_ShroomZone_body_entered(body):
	cancel_dash()
	apply_bounce_velocity(body)



func _on_AOECastTime_timeout():
	spell_cooldown.start()
	emit_signal(current_spell + "_aoe")


func _on_WaterCollider_body_entered(body):
	in_water = true


func _on_WaterCollider_body_exited(body):
	in_water = false


func _on_OofOuchTimer_timeout():
	blasting = false

