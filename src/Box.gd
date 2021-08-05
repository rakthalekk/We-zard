class_name Box
extends "res://src/Actor.gd"

export var box_material = "Wood"
export var push_speed = 300

onready var left_ray = $"PushRays/LeftRay"
onready var right_ray = $"PushRays/RightRay"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	apply_gravity(delta)
	handle_movement(delta)
	check_push()


func check_push():
	var move_direction = 0
	print(_velocity)
	if left_ray.is_colliding():
		var col = left_ray.get_collider()
		if col.move_direction.x > 0:
			move_direction = 1
	elif right_ray.is_colliding():
		var col = right_ray.get_collider()
		if col.move_direction.x < 0:
			_velocity.x = col.move_direction.x * push_speed
	else:
		move_direction = 0
	calculate_move_velocity(acceleration, move_direction, push_speed)


func calculate_move_velocity(acc, direction, speed): #determine how fast the box is moving
	if direction != 0:
		if ((direction > 0) == (_velocity.x > 0)) && abs(_velocity.x) > abs(speed):
			_velocity.x = lerp(_velocity.x, 0, friction)
		else:
			_velocity.x = lerp(_velocity.x, direction * speed, acc)
	else:
		_velocity.x = lerp(_velocity.x, 0, friction)


func can_push_on_ground():
	match box_material:
		"Wood":
			return true
		"Metal":
			return false
		_:
			return true


func _on_ShroomZone_body_entered(body):
	apply_bounce_velocity(body)
