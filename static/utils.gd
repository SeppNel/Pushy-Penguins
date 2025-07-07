extends Node


static func get_mission_count() -> int:
	var dir_path = "res://missions"
	var dir = DirAccess.open(dir_path)
	if dir == null:
		push_error("Failed to open directory: %s" % dir_path)
		return 0

	var count = 0
	for file_name in dir.get_files():
		if file_name.begins_with("mission_") and file_name.ends_with(".tscn"):
			count += 1
	return count
