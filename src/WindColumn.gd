extends Area2D

var direction

onready var gr = ProjectSettings.get("physics/2d/default_gravity")

func _physics_process(delta):
	for entity in get_overlapping_bodies():
		if entity is Player:
			if entity.wall_direction != 0 && entity._velocity.y > 0:
				apply_gravity_to_entity(delta, -0.15, entity)
				continue
		apply_gravity_to_entity(delta, -1.3, entity)


func apply_gravity_to_entity(delta, factor, entity):
	entity._velocity += factor * delta * gr * -direction


func _on_WindColumn_body_entered(body):
	if body is Player:
		body.in_wind_column = true

func _on_WindColumn_body_exited(body):
	if body is Player:
		body.in_wind_column = false
