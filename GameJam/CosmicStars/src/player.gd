extends Area2D

signal hit

# export keyword allows us to 
# show this variable in 'Inspector' menu
@export var speed = 400 			# how fast player will move (pix/sec)
var screen_size	= Vector2.ZERO	# Size of the game window

func _ready():
	hide()

func _process(delta): 				# called every frame
	screen_size = get_viewport_rect().size

	var velocity = get_velocity()
	change_animation(velocity)
	
	velocity = velocity * speed
	change_position(velocity, delta)


func get_velocity():
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		velocity.y += -1		
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x += -1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		
	return velocity.normalized()
	
func change_animation(velocity):
	if velocity.length() > 0:
		
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk_x"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0:
			$AnimatedSprite2D.animation = "walk_y"			
			$AnimatedSprite2D.flip_v = velocity.y > 0
			
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()


func change_position(velocity, delta):
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


func _on_body_entered(_body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
