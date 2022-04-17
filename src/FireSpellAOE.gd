class_name FireSpellAOE
extends Actor


var detonating = false


func _physics_process(delta):
	if !detonating:
		apply_gravity(delta)
		handle_movement(delta)


func detonate():
	$AnimationPlayer.play("boom")
	detonating = true


func delete():
	queue_free()


func _on_ShroomZone_body_entered(body):
	apply_bounce_velocity(body)


func _on_BlastRadius_body_entered(body):
	if body != self:
		var dir = (body.global_position - global_position - Vector2(0, 10)).normalized()
		if body is Player:
			body.blasting = true
			body.oof_ouch_timer.start()
		body._velocity = dir * 1800
