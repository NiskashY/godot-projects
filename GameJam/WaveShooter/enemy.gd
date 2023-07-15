extends CharacterBody2D

func _physics_process(_delta):
	var Player = get_parent().get_node("Player")
	position += (Player.position - position) / 50
	look_at(Player.position)
	move_and_slide()


func _on_area_2d_body_entered(body):
	if "bullet" in body.name:
		queue_free()
