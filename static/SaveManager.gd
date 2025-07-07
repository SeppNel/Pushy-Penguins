extends Node

const Utils = preload("res://static/utils.gd")

static var mission_count: int = 0

static var highScore: int = 0
static var username: String = ""
static var missions_completed: Array[int] = []

static func _static_init() -> void:
	save_load()

static func saveHighScore(h: int) -> void:
	highScore = h
	save()
	
static func getHighScore() -> int:
	return highScore
	
static func saveName(n: String) -> void:
	username = n
	save()
	
static func getUserName() -> String:
	return username
	
static func setMissionComplete(id: int):
	if id not in missions_completed:
		missions_completed.append(id)
		save()

static func getCompletedMissions() -> Array[int]:
	return missions_completed
	
static func isMissionCompleted(id: int) -> bool:
	return id in missions_completed
	
static func save() -> void:
	var save_dict = {
		"high_score" : highScore,
		"name" : username,
		"missions" : missions_completed
	}

	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)

static func save_load() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = save_file.get_line()

	# Creates the helper class to interact with JSON
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string
	if not json.parse(json_string) == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

	# Get the data from the JSON object
	var data = json.get_data()
	highScore = data["high_score"]
	username = data["name"]
	
	if "missions" in data:
		for id:int in data["missions"]:
			missions_completed.append(id)
			
