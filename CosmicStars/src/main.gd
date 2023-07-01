extends Node

@export var mob_scene: PackedScene
var score = 0

func _ready():
	$ScoreTimer.timeout.connect(_on_score_timer_timeout)
	$StartTimer.timeout.connect(_on_start_timer_timeout)
	$MobTimer.timeout.connect(_on_mob_timer_timeout)


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.show_new_game()


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_mob_timer_timeout():
	# Create a new instance of mob
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	
	# Set the mob's direction
	mob.rotation = mob_spawn_location.rotation + randf_range(PI / 4, 3 * PI / 4)

	# Set mob velocity
	var velocity = Vector2(randf_range(150.0, 200.0), 0.0)
	mob.linear_velocity = velocity.rotated(mob.rotation)
	
	add_child(mob)
