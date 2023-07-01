extends CharacterBody2D

const speed = 70
var player_chase = false
var player = null


func _physics_process(_delta):
	if player_chase:
		velocity = (player.position - position).normalized() * speed
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.flip_h = position.x > player.position.x
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("idle")
		
	move_and_slide()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true


func _on_detection_area_body_exited(_body):
	player = null
	player_chase = false
