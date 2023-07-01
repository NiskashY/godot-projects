extends CanvasLayer

signal start_game

func _ready():
	$MessageTimer.timeout.connect(_on_message_timer_timeout)
	$StartButton.pressed.connect(_on_start_button_pressed)

func show_message(text, is_need_to_start = true):
	$MessageLabel.text = text
	$MessageLabel.show()
	if is_need_to_start:
		$MessageTimer.start()


func show_new_game():
	update_score(0)
	show_message("New Game!")


# Function called when player loses. It will show game over
# for 2 second -> Create Title window -> after 1.0 second show start button	
func show_game_over():
	show_message("Game Over!")
	
	# Wait until the MessageTimer has counted down
	await $MessageTimer.timeout
	
	show_message("Dodget the\nCreeps!", false)
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)


func _on_message_timer_timeout():
	$MessageLabel.hide()


func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
	
