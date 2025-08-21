extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")
const MissionData = preload("res://missions/mission_data.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = MissionData.Id.BULLET_HELL
const BIG_PENGUIN_CHANCE = 0
const MOB_SPEED_MIN = 300
const MOB_SPEED_MAX = 400

var last_mission: bool = false
var timer: int = 30
var playing: bool = true
var lowest_spawning_point: int = 720

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD_Mission/BackButton.connect("pressed", returnToMainMenu)
	$HUD_Mission/NextButton.connect("pressed", nextMission)
	if Utils.get_mission_count() == MISSION_ID:
		last_mission = true
		
	adjustToScreen()
	
	$Player.start($StartPosition.position)
	$Player.contact_monitor = true
	$Player.max_contacts_reported = 100
	$StartTimer.start()
	$HUD_Mission.update_score(timer)
	$HUD_Mission.show_message("Determination.")
	$Music.play()
	_on_mob_timer_timeout()

func _on_start_timer_timeout():
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	mob.init(DeathBox_ref)
	
	# Big penguin if true, small if false
	if randi_range(1, 100) > 100 - (BIG_PENGUIN_CHANCE):
		mob.isBigPenguin = true
	mob.updateScale()

	# Set the mob's spawn position to a random location.
	
	var rand_side = randi_range(0, 2)
	match rand_side:
		0: # Spawn at top
			mob.position = Vector2(randf_range(0,480), -22)
			mob.linear_velocity = Vector2(0.0, randf_range(MOB_SPEED_MIN, MOB_SPEED_MAX))
		1: # Spawn at right
			mob.position = Vector2(502, randf_range(0,lowest_spawning_point))
			mob.linear_velocity = Vector2(-randf_range(MOB_SPEED_MIN, MOB_SPEED_MAX), 0)
		2: # Spawn at left
			mob.position = Vector2(-22, randf_range(0,lowest_spawning_point))
			mob.linear_velocity = Vector2(randf_range(MOB_SPEED_MIN, MOB_SPEED_MAX), 0)

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

func _on_player_collision(mob: Node) -> void:
	if playing:
		playing = false
		$DeathSound.play()
		mob.modulate = Color(1, 0, 0, 0.80)
		missionFinished(false)

func adjustToScreen():
	await get_tree().process_frame
	
	var screen_size = get_viewport().get_visible_rect().size
	lowest_spawning_point = screen_size.y - DeathBox_ref.get_node("CollisionShape2D").shape.get_rect().size.y
	lowest_spawning_point -= 20 # Safety net :)


func _on_mega_timer_timeout() -> void:
	$MobTimer.wait_time = 0.18
