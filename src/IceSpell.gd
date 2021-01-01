extends Area2D

<<<<<<< Updated upstream
signal freeze(pos) #sends 'freeze' signal with position coords to main.
=======
<<<<<<< HEAD
signal freeze(pos)

export var speed = 10
var dir: Vector2
var beeg = false

onready var sprite = $Sprite
onready var timer = $Timer
=======
signal freeze(pos) #sends 'freeze' signal with position coords to main.
>>>>>>> 6c3e91fb4d6e811884b18948fd34bb1d9b165e7e
>>>>>>> Stashed changes
onready var raycasts = $Raycasts.get_children()

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
<<<<<<< HEAD
	if dir.length() != 0:
		translate(speed * dir)
		sprite.scale = Vector2(0.2, 0.2)
	else:
		if !beeg:
			timer.start()
		beeg = true
		sprite.scale = Vector2(1, 1)
		for ray in raycasts:
			if ray.is_colliding() && ray.get_collider().get_name() == "Foreground":
				emit_signal("freeze", ray.get_collision_point())
=======
	for ray in raycasts:
		if ray.is_colliding() && ray.get_collider().get_name() == "Foreground":
			emit_signal("freeze", ray.get_collision_point())#if freeze hits foreground tile, freeze that tile. 
<<<<<<< Updated upstream
=======
>>>>>>> 6c3e91fb4d6e811884b18948fd34bb1d9b165e7e
>>>>>>> Stashed changes


func _on_Timer_timeout():
	self.queue_free()


func _on_IceSpell_body_entered(body):
	dir = Vector2(0, 0)
