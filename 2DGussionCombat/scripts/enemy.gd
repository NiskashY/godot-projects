extends CharacterBody2D

signal hit(damage: int)

const speed: int = 70
const ad_damage: int = 10
var player_chase = false
var player = null

var health = preload("res://scripts/health_script.gd").new()
var is_enemy_dead: bool = false

# Function to distinguish enemies objects
# Use <Object>.has_method("enemy_identifier") to 
# determine if this object is enemy
func enemy_identifier():
	pass

func _ready():
	$HealthBar.value = health.getter()
	health.connect("update_health", _on_health_bar_update_health)


func _physics_process(_delta):
	if is_enemy_dead:
		return
	
	if health.getter() == 0:
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

# ---------------------------------SIGNALS--------------------------------------------

func _on_detection_area_body_entered(body):
	if body.has_method("player_identifier"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body.has_method("player_identifier"):
		player = null
		player_chase = false

func _on_ad_cooldown_timeout():
	print("hit emited")
	emit_signal("hit", ad_damage)

func _on_hitbox_body_entered(body):
	if body.has_method("player_identifier"):
		$AdCooldown.start()
	
func _on_hitbox_body_exited(body):
	if body.has_method("player_identifier"):
		$AdCooldown.stop()

func _on_player_hit(damage):
	health.setter(health.getter() - damage)

func _on_death():
	queue_free()
	
func _on_health_bar_update_health(local_health):
	$HealthBar.value = local_health

func _on_regenerate_timer_timeout():
	health.setter(health.getter() + 5)
