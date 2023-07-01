extends CharacterBody2D

const speed = 100
var current_direction
var is_skill_animation_playing = false

func _ready():
	$AnimatedSprite2D.play("side_idle")
	current_direction = "side"

func _physics_process(delta):
	var direction = player_movement(delta)
	play_animation(direction)
	play_animation_skills(current_direction)
	

func get_prefix_direction(direction):
	if direction.x == 0:
		return "front" if direction.y > 0 else "back"
	return "side"

func play_animation_skills(direction_type: String):
	if !($FirstSkill/Cd.is_stopped() && $SecondSkill/Cd.is_stopped()):
		return
		
	var is_lmb: bool = Input.is_action_pressed("ui_lmb")
	var is_rmb: bool = Input.is_action_pressed("ui_rmb")
	
	if is_lmb || is_rmb:
		if is_lmb:
			$AnimatedSprite2D.play(direction_type + "_skill_first")
			$FirstSkill/Cd.start()
		else:
			$AnimatedSprite2D.play(direction_type + "_skill_second")
			$SecondSkill/Cd.start()
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
	
func player_movement(_delta): 
	var direction = Vector2.ZERO	 
	
	direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	direction.y = int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
	
	var current_speed = speed
	if Input.is_action_pressed("ui_shift"):
		current_speed <<= 1
	
	velocity = direction.normalized() * current_speed
	move_and_slide()
	
	return direction.normalized()

func get_animation_time(animation: AnimatedSprite2D):
	var count = animation.sprite_frames.get_frame_count(animation.get_animation())
	var duration = animation.sprite_frames.get_frame_duration(animation.get_animation(), 0)
	return duration * count

func _on_cd_timeout():
	pass

func _on_skill_animation_finished():
	$AnimatedSprite2D.disconnect("animation_finished", _on_skill_animation_finished)
	$AnimatedSprite2D.play(current_direction + "_idle")
	is_skill_animation_playing = false		
		
