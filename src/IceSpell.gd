extends Area2D

signal freeze(pos)
onready var raycasts = $Raycasts.get_children()

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	for ray in raycasts:
		if ray.is_colliding() && ray.get_collider().get_name() == "Foreground":
			emit_signal("freeze", ray.get_collision_point())


func _on_Timer_timeout():
	self.queue_free()
