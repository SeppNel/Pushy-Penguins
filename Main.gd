extends Node

@export var mob_scene: PackedScene
var score
var bigPenguinChance = 10
var difficultyFactor = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_over():
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_origin_marker()
	$Music.stop()
	$DeathSound.play()

func new_game():
	score = 0
	difficultyFactor = 0
	$Player.start($StartPosition.position)
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	# Small penguin if true, big if false
	if randi_range(1, 100) < 100 - (bigPenguinChance + 5 * difficultyFactor):
		mob.get_node("AnimatedSprite2D").scale = Vector2(0.05, 0.05)
		mob.get_node("CollisionShape2D").scale = Vector2(0.5, 0.5)

	# Set the mob's spawn position to a random location.
	mob.position = Vector2(randf_range(0,480), -20)

	# Choose the velocity for the mob.
	var velocity = Vector2(0.0, randf_range(150.0, 250.0))
	velocity += Vector2(0.0, 25.0 * difficultyFactor)
	mob.linear_velocity = velocity

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout():
	score += 1
	if score % 50 == 0:
		difficultyFactor += 1
		$MobTimer.wait_time -= 0.01
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_player_touch(pos):
	if pos != Vector2.INF:
		$HUD.show_origin_marker(pos)
	else:
		$HUD.hide_origin_marker()
