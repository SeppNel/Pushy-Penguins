extends Node
	
static func get_mission_count() -> int:
	var i: int = 1
	var path: String
	while true:
		path = "res://missions/mission_" + str(i) + ".tscn"
		if !ResourceLoader.exists(path):
			break
		i += 1
	return i - 1
