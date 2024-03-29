extends CharacterBody2D

signal hit(damage: int)

# Scenes
var dagger_scene: PackedScene = preload("res://scenes/dagger.tscn")

# Variables
const speed: int = 100
var current_direction
var is_skill_animation_playing: bool = false
var is_enemy_in_attack_range: bool = false
var is_player_dead: bool = false

# If player health equals zero - player is dead
var health = preload("res://scripts/health_script.gd").new()
const first_skill_dmg: int = 30
const second_skill_dmg: int = 70

# Function to distinguish players objects
# Use <Object>.has_method("player_identifier") to 
# determine if this object is player
func player_identifier():
	pass

func _ready():
	$AnimatedSprite2D.play("side_idle")
	$HealthBar.value = health.getter()
	health.connect("update_health", _on_health_bar_update_health)
	current_direction = "side"

func _physics_process(_delta):
	if is_player_dead:
		return
		
	if health.getter() == 0:
		is_player_dead = true
		$AnimatedSprite2D.play("death")
		$AnimatedSprite2D.connect("animation_finished", _on_game_over)
	else:
		var direction = get_direction()
		play_animation(direction)
		play_animation_skills(current_direction)
		player_movement(direction)
		move_and_slide()
	

# ---------------------------------MOVEMENT AND ANIMATION----------------------------
func get_direction():
	var direction: Vector2 = Vector2.ZERO
	
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	direction.y = int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
	
	return direction.normalized()

func get_prefix_direction(direction: Vector2):
	if direction.x == 0:
		return "front" if direction.y > 0 else "back"
	return "side"

func play_animation_skills(direction_type: String):
	if is_skill_animation_playing:
		return
	
	var is_lmb: bool = Input.is_action_pressed("ui_lmb") && $FirstSkill/Cd.is_stopped() 
	var is_rmb: bool = Input.is_action_pressed("ui_rmb") && $SecondSkill/Cd.is_stopped()
	
	if is_lmb || is_rmb:
		var damage: int = first_skill_dmg
		if is_lmb:
			$AnimatedSprite2D.play(direction_type + "_skill_first")
			$FirstSkill/Cd.start()
			var dagger = dagger_scene.instantiate()
			dagger.position = $Marker2D.position
			dagger.apply_impulse(Vector2(100, 0))
			get_tree().get_root().call_deferred("add_child", dagger)
		else:
			$AnimatedSprite2D.play(direction_type + "_skill_second")
			$SecondSkill/Cd.start()
			damage = second_skill_dmg
		
		if is_enemy_in_attack_range:
			print("player hit")
			emit_signal("hit", damage)
		
		$AnimatedSprite2D.connect("animation_finished", _on_skill_animation_finished)
		is_skill_animation_playing = true

func play_animation(direction: Vector2):
	if is_skill_animation_playing:
		return
		
	var direction_type
	var animation_type
	
	if direction == Vector2.ZERO:
		direction_type = get_prefix_direction(velocity)
		animation_type = "idle"
	else:
		direction_type = get_prefix_direction(direction)
		animation_type = "walk"
	
	# Play same idle animation as before
	if velocity == Vector2.ZERO:
		return
	else:
		# If player looking backwards
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	current_direction = direction_type
	$AnimatedSprite2D.play(direction_type + "_" + animation_type)

func player_movement(direction: Vector2): 
	var current_speed: int = speed
	if Input.is_action_pressed("ui_shift"):
		current_speed <<= 1
	
	var is_ult: bool = Input.is_action_pressed("ui_R") && $ThirdSkill/Cd.is_stopped()
	if is_ult:
		
		# Get position of the mouse
		var new_position: Vector2 = get_global_mouse_position()
	
		# Limit new position by radious of third skill
		var radius: int = $ThirdSkill/Range/CollisionShape2D.shape.radius
		var directional_vector: Vector2 = (new_position - position).limit_length(radius)
		
		# Restore new position
		position = directional_vector + position
		
		$FirstSkill/Cd.stop()
		$SecondSkill/Cd.stop()	
		$ThirdSkill/Cd.start()
		
		velocity = Vector2.ZERO
	else:
		velocity = direction * current_speed

# ---------------------------------SIGNALS--------------------------------------------

func _on_skill_animation_finished():
	$AnimatedSprite2D.disconnect("animation_finished", _on_skill_animation_finished)
	$AnimatedSprite2D.play(current_direction + "_idle")
	is_skill_animation_playing = false
	
func _on_hitbox_body_entered(body):
	if body.has_method("enemy_identifier"):
		is_enemy_in_attack_range = true

func _on_hitbox_body_exited(body):
	if body.has_method("enemy_identifier"):
		is_enemy_in_attack_range = false

func _on_enemy_hit(damage):
	health.setter(health.getter() - damage)

func _on_game_over():
	queue_free()

func _on_regenerate_timer_timeout():
	health.setter(health.getter() + 5)

func _on_health_bar_update_health(local_health):
	$HealthBar.value = local_health
