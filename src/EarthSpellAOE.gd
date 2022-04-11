extends Area2D

signal sprout(pos)

onready var timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()


func _on_Timer_timeout():
	queue_free()


func _on_EarthSpellAOE_body_entered(body):
	body.sprout()
