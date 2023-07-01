extends CharacterBody2D

signal hit(damage: int)

const speed: int = 70
const ad_damage: int = 10
var player_chase = false
var player = null

var health: int = 100
var is_enemy_dead: bool = false

# Function to distinguish enemies objects
# Use <Object>.has_method("enemy_identifier") to 
# determine if this object is enemy
func enemy_identifier():
	pass


func _physics_process(_delta):
	if is_enemy_dead:
		return
	
	if health == 0:
		is_enemy_dead = true
		$AnimatedSprite2D.play("death")
		$AnimatedSprite2D.connect("animation_finished", _on_death)
	else:
		if player_chase:
			velocity = (player.position - position).normalized() * speed
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = position.x > player.position.x
		else:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
			
		move_and_slide()

func _on_detection_area_body_entered(body):
	if body.has_method("player_identifier"):
		player = body
		player_chase = true


func _on_detection_area_body_exited(body):
	if body.has_method("player_identifier"):
		player = null
		player_chase = false


func _on_ad_cooldown_timeout():
	print("signal emited")
	emit_signal("hit", ad_damage)



func _on_hitbox_body_entered(body):
	if body.has_method("player_identifier"):
		$AdCooldown.start()
	
func _on_hitbox_body_exited(body):
	if body.has_method("player_identifier"):
		$AdCooldown.stop()


func _on_player_hit(damage):
	health = max(health - damage, 0)


func _on_death():
	queue_free()
	
