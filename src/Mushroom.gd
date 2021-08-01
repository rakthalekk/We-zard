extends Area2D

export var dir = Vector2(0, -1)

func _ready():
	pass # Replace with function body.

func _on_Mushroom_body_entered(body):
	if body is Actor:
		if body is Player:
			body.cancel_dash()
		if dir.x != 0:
			body._velocity.x = body.bounce_velocity.x * dir.x
		if dir.y != 0:
			body._velocity.y = body.bounce_velocity.y * dir.y
		body.handle_movement(0.05)
