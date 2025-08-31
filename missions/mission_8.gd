extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")
const MissionData = preload("res://missions/mission_data.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = MissionData.Id.FISH_2
const BIG_PENGUIN_CHANCE = 20
const FISH_TARGET = 5

var last_mission: bool = false
var timer: int = 10
var playing: bool = true
var fish_eaten: int = 0

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
	$HUD_Mission.show_message("Eat the fish!")
	$Music.play()
	
	adjustFishToScreen()

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	$Player.is_dead = false

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
	var velocity = Vector2(0.0, randf_range(250.0, 350.0))
	mob.linear_velocity = velocity

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

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
		$DeathSound.play()
		missionFinished(false)

func missionFinished(passed: bool):
	SceneManager.preload_scene("res://Main.tscn")
	$StartTimer.stop()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD_Mission.hide_origin_marker()
	$Music.stop()
	
	if passed:
		$WinSound.play()
		SaveManager.setMissionComplete(MISSION_ID)
		$HUD_Mission.showCompleteMenu(last_mission)
	else:
		$HUD_Mission.showFailedMenu(last_mission)
		

func returnToMainMenu():
	SceneManager.goto_scene("res://Main.tscn")

func nextMission():
	var s = "res://missions/mission_" + str(MISSION_ID + 1) + ".tscn"
	SceneManager.goto_scene(s)


func _on_fish_body_entered(body: Node2D, fishId: int) -> void:
	if playing:
		var node = "Fish" + str(fishId)
		get_node(node).queue_free()
		
		fish_eaten += 1
		#$Player.scale += Vector2(0.5, 0.5)
		$Player.scale(1.1)
		$Player.mass += 0.05
		if fish_eaten >= FISH_TARGET:
			playing = false
			missionFinished(true)

func adjustFishToScreen():
	await get_tree().process_frame
	for i in range(1, FISH_TARGET + 1):
		var fish = get_node("Fish" + str(i))
		var old_distance_ratio = fish.position.y / 720
		fish.position.y = get_viewport().get_visible_rect().size.y * old_distance_ratio
