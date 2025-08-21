extends Node

const mob_scene = preload("res://Mob.tscn")
const Utils = preload("res://static/utils.gd")
const MissionData = preload("res://missions/mission_data.gd")

@onready var DeathBox_ref = $DeathBox

const MISSION_ID = MissionData.Id.BULLY_1
const BIG_PENGUIN_CHANCE = 20
const MOBS_TARGET = 10

var mobs_spawned: int = 0
var mobs_despawned: int = 0
var last_mission: bool = false
var playing: bool = true
var mobs_touched: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD_Mission/BackButton.connect("pressed", returnToMainMenu)
	$HUD_Mission/NextButton.connect("pressed", nextMission)
	if Utils.get_mission_count() == MISSION_ID:
		last_mission = true
	
	$Player.start($StartPosition.position)
	$Player.contact_monitor = true
	$Player.max_contacts_reported = 100
	$StartTimer.start()
	$HUD_Mission.update_score(0)
	$HUD_Mission.show_message("Hit all " + str(MOBS_TARGET) + " penguins!")
	$Music.play()

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	if mobs_spawned < MOBS_TARGET:
		var mob = mob_scene.instantiate()
		mob.init(DeathBox_ref)
		mob.id = mobs_spawned
		mob.connect("despawned", _on_mob_despawned)
		
		# Big penguin if true, small if false
		if randi_range(1, 100) >= 100 - (BIG_PENGUIN_CHANCE):
			mob.isBigPenguin = true
		mob.updateScale()

		# Set the mob's spawn position to a random location.
		mob.position = Vector2(randf_range(0,480), -22)

		# Choose the velocity for the mob.
		var velocity = Vector2(0.0, randf_range(150.0, 200.0))
		mob.linear_velocity = velocity

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
	
		mobs_spawned += 1


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
		mobs_touched[mob.id] = true
		mob.modulate = Color(0, 1, 0, 0.80)
		$HUD_Mission.update_score(mobs_touched.size())
		
func _on_mob_despawned(mob_id: int) -> void:
	if playing:
		mobs_despawned += 1
		if mobs_despawned == MOBS_TARGET:
			missionFinished(mobs_touched.size() == MOBS_TARGET)
