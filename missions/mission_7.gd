extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = 7
const BIG_PENGUIN_CHANCE = 25

var last_mission: bool = false
var timer: int = 20
var playing: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD_Mission/BackButton.connect("pressed", returnToMainMenu)
	$HUD_Mission/NextButton.connect("pressed", nextMission)
	if Utils.get_mission_count() == MISSION_ID:
		last_mission = true
	
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD_Mission.update_score(timer)
	$HUD_Mission.show_message("Survive!")
	$Music.play()

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	mob.init(DeathBox_ref)
	
	# Big penguin if true, small if false
	if randi_range(1, 100) >= 100 - (BIG_PENGUIN_CHANCE):
		mob.isBigPenguin = true
	mob.updateScale()

	# Set the mob's spawn position to a random location.
	mob.position = Vector2(randf_range(0,480), -22)

	# Choose the velocity for the mob.
	var velocity = Vector2(0.0, randf_range(350.0, 450.0))
	mob.linear_velocity = velocity

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_score_timer_timeout():
	if playing:
		timer -= 1
		$HUD_Mission.update_score(timer)

		if timer <= 0 :
			playing = false
			missionFinished(true)

func _on_player_fell() -> void:
	if playing:
		playing = false
		$DeathSound.play()
		await get_tree().create_timer(0.4).timeout
		missionFinished(false)

func missionFinished(passed: bool):
	SceneManager.preload_scene("res://Main.tscn")
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
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
