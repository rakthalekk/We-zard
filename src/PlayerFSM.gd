extends "res://src/StateMachine.gd"

const DASH_TIME = 0.20

var casting = false

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("dash")
	add_state("cast")
	add_state("wall_slide")
	add_state("ice_wall_slide")
	add_state("crouch")
	call_deferred("set_state", states.idle)

func _input(event):
	if ![states.dash, states.cast].has(state):
		if event.is_action_pressed("dash") && parent.dash_timer == 0 && !parent.air_dash: #speeding up (dashing)
			set_state(states.dash)
			parent.dash_timer = DASH_TIME
			parent._velocity.y = 0
			parent.move_direction = parent.get_dash_direction()
		elif event.is_action_pressed("cast") && parent.spell_cooldown.time_left == 0: #action button casts spell
			casting = true
			parent.useless_boolean_that_i_shouldnt_need = true
		elif event.is_action_released("aoe_cast") && parent.spell_cooldown.time_left == 0 && parent.aoe_cast_time.time_left == 0:
			if parent.current_spell != "fire_spell":
				set_state(states.cast)
			parent.cast_aoe_spell()
		elif event.is_action_pressed("crouch"):
			set_state(states.crouch)
	# Casts spell on release
	if event.is_action_released("cast") && parent.spell_cooldown.time_left == 0 && casting:
		parent.cast_spell()
		casting = false
	if [states.wall_slide, states.ice_wall_slide].has(state):
		if event.is_action_pressed("jump"):
			parent.wall_jump()


func _state_logic(delta):
	if ![states.dash, states.ice_wall_slide, states.wall_slide, states.cast].has(state):
		parent.apply_gravity(delta)
	elif state == states.ice_wall_slide:
		parent.apply_gravity(delta, 0.7)
	elif state == states.wall_slide:
		parent.apply_gravity(delta, 0.1)
	if state == states.dash:
		parent.handle_dash(delta)
	elif state == states.cast:
		parent._velocity = Vector2.ZERO
	else:
		parent.regular_movement()
	parent.update_wall_direction()
	parent.display_cast_line()
	parent.handle_movement(delta)


func _get_transition(delta):
	#print(state)
	if parent.dash_timer > 0:
		return states.dash
	if parent.haha_ice and !parent.is_on_floor():
		return states.ice_wall_slide
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent._velocity.y < 0:
					return states.jump
				elif parent._velocity.y > 0:
					return states.fall
			elif parent._velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent._velocity.y < 0:
					return states.jump
				elif parent._velocity.y > 0:
					return states.fall
			elif parent._velocity.x == 0:
				return states.idle
		states.jump:
			if parent.is_on_floor():
				return states.idle
			elif parent._velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0:
				return states.wall_slide
			if parent.is_on_floor():
				return states.idle
			elif parent._velocity.y < 0:
				return states.jump
		states.dash:
			if parent.is_on_floor():
				return states.idle
			else:
				if parent._velocity.y < 0:
					return states.jump
				else:
					return states.fall
		states.cast:
			if parent.aoe_cast_time.time_left == 0:
				if parent.is_on_floor():
					return states.idle
				else:
					return states.fall
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
		states.ice_wall_slide:
			if parent._velocity.y < 0:
				return states.jump
			else:
				return states.fall
		states.crouch:
			if !Input.is_action_pressed("crouch"):
				parent.sprite.scale.y = 1
				return states.idle
	return null


func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animation_player.play('idle')
		states.cast:
			parent.animation_player.play("spell_cast")
		states.crouch:
			parent.animation_player.play("crouch")


func _exit_state(old_state, new_state):
	pass
