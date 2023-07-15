extends Sprite2D

var speed = 400
var angular_speep = PI

# method called when scene in already constructed
func _ready():
	var timer = get_node("Timer")
	timer.timeout.connect(_on_timer_timeout)

func _init():
	print("Hello, World!")

func get_direction():
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	elif Input.is_action_pressed("ui_right"):
		direction = 1
	return direction

func get_velocity():
	var velocity = Vector2.ZERO
	if Input.is_key_pressed(KEY_SPACE):
		velocity = Vector2.UP.rotated(rotation) * speed
	return velocity


func _process(delta):
	rotation += get_direction() * angular_speep * delta
	position += get_velocity() * delta

func _unhandled_input(event):
	if event is InputEventKey && event.is_pressed():  
		if event.keycode == KEY_Q:
			get_tree().quit()


func _on_button_pressed():
	set_process(!is_processing())
	var timer = get_node("Timer")
	if timer.is_stopped():
		timer.start()
		visible = true
	else:
		timer.stop()
		visible = false

# SIGNALS 
func _on_timer_timeout():
	visible = not visible
