extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = 9

var last_mission: bool = false
var timer: int = 10
var playing: bool = true
var mobs: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD_Mission/BackButton.connect("pressed", returnToMainMenu)
	$HUD_Mission/NextButton.connect("pressed", nextMission)
	if Utils.get_mission_count() == MISSION_ID:
		last_mission = true
	
	$Player.start($StartPosition.position)
	$Player.is_dead = true
	$StartTimer.start()
	$HUD_Mission.update_score(timer)
	$HUD_Mission.show_message("Go for a Swim!")
	$Music.play()
	
	initMobs()

func _on_start_timer_timeout():
	$ScoreTimer.start()
	$Player.is_dead = false
	startMobs()

func _on_score_timer_timeout():
	if playing:
		timer -= 1
		$HUD_Mission.update_score(timer)

		if timer <= 0 :
			playing = false
			$DeathSound.play()
			missionFinished(false)

func _on_player_fell() -> void:
	if playing:
		playing = false
		await get_tree().create_timer(0.4).timeout
		missionFinished(true)

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
	
func initMobs():
	var screen_size = get_viewport().get_visible_rect().size
	for child in get_children():
		if child.is_in_group("mobs"):
			child.init(DeathBox_ref, child.ANIMATION.WALK_UP)
			var old_distance_ratio = child.position.y / 720
			child.position.y = get_viewport().get_visible_rect().size.y * old_distance_ratio
			mobs.append(child)
			
func startMobs():
	for mob in mobs:
		mob.linear_velocity = Vector2(0.0, -10)
