extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")




func _on_Tome_body_entered(body):
	if body is Player:
		$AnimationPlayer.play("close")


func next_level():
	Global.set_current_level(Global.current_level + 1)
