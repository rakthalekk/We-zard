extends Area2D

signal freeze(pos) #sends 'freeze' signal with position coords to main.


onready var timer = $Timer
onready var raycasts = $Raycasts.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()


func _physics_process(delta):
	for ray in raycasts:
		if ray.is_colliding() && ray.get_collider().get_name() == "Foreground":
			emit_signal("freeze", ray.get_collision_point())


func _on_Timer_timeout():
	self.queue_free()
