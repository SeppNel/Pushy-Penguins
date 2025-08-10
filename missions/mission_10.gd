extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")

@onready var DeathBox_ref = $DeathBox
@onready var pathFollow_ref: PathFollow2D = $Path2D/PathFollow2D
@onready var dummyPenSprite_ref: AnimatedSprite2D = $Path2D/PathFollow2D/DummyPenguin/AnimatedSprite2D

const MISSION_ID = 10
const MAX_DISTANCE = 14.0

var last_mission: bool = false
var playing: bool = true
var is_tutorial: bool = false
var score = 0
var waiting_for_loop: bool = false
var timer: int = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD_Mission/BackButton.connect("pressed", returnToMainMenu)
	$HUD_Mission/NextButton.connect("pressed", nextMission)
	if Utils.get_mission_count() == MISSION_ID:
		last_mission = true
	
	$Player.start($StartPosition.position)
	$Player.is_dead = true
	$StartTimer.start()
	$HUD_Mission.show_message("Copy Him!")
	$HUD_Mission.update_score(timer)
	$Music.play()

func _process(delta: float) -> void:
	if is_tutorial:
		if pathFollow_ref.progress_ratio < 1.0:
			pathFollow_ref.progress_ratio += delta * 0.18
			sprite_rotation(pathFollow_ref.progress_ratio)
		else:
			$Path2D/PathFollow2D/DummyPenguin.hide()
			is_tutorial = false
			$Player.is_dead = false
			$Player.start($StartLoopPos.position)
			$TrailTimer.start()
			$ScoreTimer.start()

func _on_start_timer_timeout():
	is_tutorial = true

func _on_score_timer_timeout():
	if playing:
		timer -= 1
		$HUD_Mission.update_score(timer)

		if timer <= 0 :
			playing = false
			$DeathSound.play()
			$TrailTimer.stop()
			missionFinished(false)

func _on_player_fell() -> void:
	if playing:
		playing = false
		await get_tree().create_timer(0.4).timeout
		missionFinished(false)

func missionFinished(passed: bool):
	SceneManager.preload_scene("res://Main.tscn")
	$StartTimer.stop()
	$ScoreTimer.stop()
	$HUD_Mission.hide_origin_marker()
	$Music.stop()
	
	if passed:
		# TODO: Play Happy Music
		SaveManager.setMissionComplete(MISSION_ID)
		$HUD_Mission.showCompleteMenu(last_mission)
	else:
		$HUD_Mission.showFailedMenu(last_mission)
		

func returnToMainMenu():
	SceneManager.goto_scene("res://Main.tscn")

func nextMission():
	var s = "res://missions/mission_" + str(MISSION_ID + 1) + ".tscn"
	SceneManager.goto_scene(s)

func _on_trail_timer_timeout() -> void:
	$PlayerTrail.add_point($Player.position)

func _on_loop_trigger_body_exited(body: Node2D) -> void:
	if playing and body.name == "Player":
		waiting_for_loop = true

func _on_loop_trigger_body_entered(body: Node2D) -> void:
	if playing and waiting_for_loop:
		$TrailTimer.stop()
		$ScoreTimer.stop()
		var score: float = compareLines()
		score = round(score * 100)
		animateScore(int(score))
		
		await get_tree().create_timer(2.5).timeout
		if score < 50:
			missionFinished(false)
		else:
			missionFinished(true)
		
func compareLines() -> float:
	var total_score: float = 0.0
	var count: int = 0

	for target_point in $Path2D/Line2D.points:
		var closest_distance = INF
		for player_point in $PlayerTrail.points:
			var player_local = $Path2D.to_local(player_point)
			var dist = target_point.distance_to(player_local)
			if dist < closest_distance:
				closest_distance = dist
		
		if closest_distance < MAX_DISTANCE:
			var score = 1.0 - (closest_distance / MAX_DISTANCE)
			total_score += score
		count += 1

	if count == 0:
		return 0.0

	return total_score / count  # normalized 0.0 to 1.0
	
func animateScore(score):
	for i in range(100):
		var rand = randi_range(1, 100)
		$HUD_Mission.update_score(rand)
		await get_tree().create_timer(0.01).timeout
	$HUD_Mission.update_score(score)
	
func sprite_rotation(progress_ratio: float):
	if progress_ratio < 0.3:
		dummyPenSprite_ref.play("down")
	elif progress_ratio < 0.5:
		dummyPenSprite_ref.play("right")
	elif progress_ratio < 0.8:
		dummyPenSprite_ref.play("upleft")
	else:
		dummyPenSprite_ref.play("right")
