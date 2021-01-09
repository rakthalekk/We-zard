extends Area2D


signal mushroomify(pos) #sends 'mushroomify' signal with position coords to main.

export var speed = 10
var dir: Vector2
var beeg = false

onready var sprite = $Sprite
onready var timer = $Timer
onready var raycasts = $Raycasts.get_children()

func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if dir.length() != 0:
		translate(speed * dir)
		sprite.scale = Vector2(0.2, 0.2)
	else:
		if !beeg:
			timer.start()
		beeg = true
		sprite.scale = Vector2(1, 1)
		for ray in raycasts:
			if ray.is_colliding():
				emit_signal("mushroomify", ray.get_collision_point())


func _on_Timer_timeout():
	self.queue_free()


func _on_EarthSpell_body_entered(body):
	dir = Vector2(0, 0)
