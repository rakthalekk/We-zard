extends Area2D


signal mushroomify(pos) #sends 'mushroomify' signal with position coords to main.

export var speed = 20
var dir: Vector2
var beeg = false
var direction = "down"

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
				emit_signal("mushroomify", ray.get_collision_point(), direction)


func _on_Timer_timeout():
	self.queue_free()


func _on_EarthSpell_body_entered(body):
	var down_d = $Raycasts/DownRayCast.get_collision_point().distance_to(position)
	var left_d = $Raycasts/LeftRayCast.get_collision_point().distance_to(position)
	var up_d = $Raycasts/UpRayCast.get_collision_point().distance_to(position)
	var right_d = $Raycasts/RightRayCast.get_collision_point().distance_to(position)
	
	if down_d <= left_d && down_d <= up_d && down_d <= right_d:
		direction = "down"
	elif left_d <= down_d && left_d <= up_d && left_d <= right_d:
		direction = "left"
	elif up_d <= left_d && up_d <= down_d && up_d <= right_d:
		direction = "up"
	else:
		direction = "right"

	dir = Vector2(0, 0)
