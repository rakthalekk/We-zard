extends Area2D


export(String, "ice_spell", "earth_spell", "fire_spell") var spell = "ice_spell"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("spin")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Crystal_body_entered(body):
	if body is Player:
		body.change_spell(spell)
		$Sprite.visible = false
		call_deferred("disable_collider", true)
		$Timer.start()


func _on_Timer_timeout():
	$Sprite.visible = true
	call_deferred("disable_collider", false)


func disable_collider(arg):
	$CollisionShape2D.disabled = arg
