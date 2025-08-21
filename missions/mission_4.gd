extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")
const MissionData = preload("res://missions/mission_data.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = MissionData.Id.WALK_1
const MAX_DISTANCE = 20.0
const ROTATION_SPRITES = ["right", "down", "down", "down", "left", "upleft", "up", "upright", "right"]

var last_mission: bool = false
var playing: bool = true
var is_tutorial: bool = false
var score = 0
var waiting_for_loop: bool = false
var timer: int = 10

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
		if $CirclePath2D/PathFollow2D.progress_ratio < 1.0:
			$CirclePath2D/PathFollow2D.progress_ratio += delta * 0.2
			sprite_rotation()
		else:
			$CirclePath2D/PathFollow2D/DummyPenguin.hide()
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
		$WinSound.play()
		SaveManager.setMissionComplete(MISSION_ID)
		$HUD_Mission.showCompleteMenu(last_mission)
	else:
		$DeathSound.play()
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
		var score = compareLines()
		score = round(score * 100)
		$HUD_Mission.animateScore(score)
		
		await get_tree().create_timer(2.5).timeout
		if score < 50:
			missionFinished(false)
		else:
			missionFinished(true)
		
func compareLines():
	var total_score := 0.0
	var count := 0

	for target_point in $CirclePath2D/Line2D.points:
		var closest_distance := INF
		for player_point in $PlayerTrail.points:
			var player_local = $CirclePath2D.to_local(player_point)
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

func sprite_rotation():
	var index = round($CirclePath2D/PathFollow2D.progress_ratio / 0.125)
	$CirclePath2D/PathFollow2D/DummyPenguin/AnimatedSprite2D.play(ROTATION_SPRITES[index])
