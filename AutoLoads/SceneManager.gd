extends Node

var current_scene = null

func _ready() -> void:
	current_scene = get_tree().current_scene


func goto_scene(path) -> void:
	current_scene = get_tree().current_scene
	
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(path)

	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	# Check that new scene is loaded.
	while ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(0.1).timeout
	
	# It is now safe to remove the current scene
	current_scene.free()
	
	# Add new scene
	var s = ResourceLoader.load_threaded_get(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func preload_scene(path):
	if ResourceLoader.load_threaded_get_status(path) != ResourceLoader.THREAD_LOAD_LOADED:
		ResourceLoader.load_threaded_request(path)
