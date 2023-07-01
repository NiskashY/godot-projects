extends CharacterBody2D

@export var movespeed = 500
@export var bulletspeed = 500
var screen_size
var bullet_scene = preload("res://bullet.tscn")

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size

func get_animation_size():
	var frames = $AnimatedSprite2D.get_sprite_frames()
	var texture = frames.get_frame_texture("default-player", $AnimatedSprite2D.get_index())
	return texture.get_size()


func change_body_position():
	var direction = process_movement()
	velocity = direction * movespeed
	move_and_slide()
	
	# Restrict player moves: do not allow to go outside screen
	var size = get_animation_size()
	position.x = clamp(position.x, size.x, screen_size.x - size.x)
	position.y = clamp(position.y, size.y, screen_size.y - size.y)
	

func _physics_process(_delta):
	change_body_position()
	
	# target player by mouse
	look_at(get_global_mouse_position())
	
	if $BuletTimer.is_stopped() && Input.is_action_pressed("left_mouse_button"):
		fire()
		
func process_movement():
	var direction = Vector2.ZERO

	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		
	return direction.normalized()
	
	
func fire():	
	$BuletTimer.start()

	var bullet = bullet_scene.instantiate()
	var size = get_animation_size()
	bullet.position = Vector2(size.x, 0).rotated(rotation) + position
	bullet.rotation = rotation
	bullet.apply_impulse(Vector2(bulletspeed, 0).rotated(rotation))	
	
	get_tree().get_root().call_deferred("add_child", bullet)


func kill():
	for item in get_tree().get_root().get_children():
		item.queue_free()
	get_tree().reload_current_scene()
	$BuletTimer.stop()
	
func _on_area_2d_body_entered(body):
	if "Enemy" in body.name:
		kill()
