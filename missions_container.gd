extends VBoxContainer

func _on_mission_start_pressed(missionId: int) -> void:
	var path = "res://missions/mission_" + str(missionId) + ".tscn"
	SceneManager.goto_scene(path)
