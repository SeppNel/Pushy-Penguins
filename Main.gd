extends Node

const mob_scene = preload("res://Mob.tscn")
const SaveManager = preload("res://static/SaveManager.gd")

@onready var DeathBox_ref = $DeathBox

const BIG_PENGUIN_CHANCE = 10

var score: int
var highScore: int = 0
var difficultyFactor = 0
var defaultMobTimerWaitTime
var highScoreUpdated : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	highScore = SaveManager.getHighScore()
	$HUD/Settings/Name/NameField.text = SaveManager.getUserName()
	
	defaultMobTimerWaitTime = $MobTimer.wait_time
	$HUD.update_high_score(highScore)
	$HUD.settings_changed.connect(save_settings)

func game_over():
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$HUD.hide_origin_marker()
	$HUD/HighScoreMsg.show()
	$Music.stop()
	$DeathSound.play()

	if highScoreUpdated:
		$HUD.update_high_score(highScore)
		send_highscore_leaderboard()
		$HUD/NewHighScore.show()
		SaveManager.saveHighScore(highScore)

func send_highscore_leaderboard():
	var url = "http://pertusa.myftp.org/.resources/php/ppp/leaderboard_set.php"
	var data = {
		"name" : $HUD/Settings/Name/NameField.text,
		"score" : highScore,
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)

func new_game():
	score = 0
	highScoreUpdated = false
	difficultyFactor = 0
	$MobTimer.wait_time = defaultMobTimerWaitTime
	#$MobTimer.paused = true
	$Player.start($StartPosition.position)
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	mob.init(DeathBox_ref)
	
	# Small penguin if true, big if false
	if randi_range(1, 100) < 100 - (BIG_PENGUIN_CHANCE + 5 * difficultyFactor):
		mob.get_node("AnimatedSprite2D").scale = Vector2(0.05, 0.05)
		mob.get_node("CollisionShape2D").scale = Vector2(0.5, 0.5)
	else:
		mob.isBigPenguin = true
		mob.get_node("Shadow").scale = Vector2(0.6, 0.45)
		mob.get_node("Shadow").modulate = Color(1, 1, 1, 0.35)

	# Set the mob's spawn position to a random location.
	mob.position = Vector2(randf_range(0,480), -22)

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
		$MobTimer.wait_time -= 0.02
	
	if score > highScore:
		highScore = score
		highScoreUpdated = true

	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


func _on_player_touch(pos):
	if pos != Vector2.INF:
		$HUD.show_origin_marker(pos)
	else:
		$HUD.hide_origin_marker()

func save_settings(reset: bool):
	if reset:
		highScore = 0
	SaveManager.saveName($HUD/Settings/Name/NameField.text)
