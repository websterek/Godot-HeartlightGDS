extends Node

onready var mainCamera = get_node("MainCamera")
var previousLevel = null
var currentLevel = null
var nextLevel = null
var playerInstance = null

func _input(event):
    if !event:
        pass
    elif Input.is_action_pressed("ui_accept"):
        go_to_next_level()

func _ready():
	go_to_next_level()

func instantiate_level(level_filename, position = Vector2(0, 0)):
	var scene = load("res://src/levels/" + level_filename + ".tscn")
	if scene:
		var scene_instance = scene.instance()
		var scene_instance_bounds = scene_instance.calculate_bounds()

		scene_instance.set_name(level_filename)
		scene_instance.global_position = Vector2(position.x, position.y - scene_instance_bounds.height / 2)
		get_node("Levels").add_child(scene_instance)

		return scene_instance
	else:
		print("No level with filename '" + level_filename + "' found.")
		return null

func go_to_next_level():
	if currentLevel == null:
		# Load current level and next level for smooth animation
		currentLevel = instantiate_level("lvl_001")
		spawn_player_at_current_level()

		nextLevel = append_new_level()

		mainCamera.align_camera_to_level(currentLevel)
	else:
		# Stop processing current level, set next level as a current one
		if previousLevel != null:
			previousLevel.queue_free()

		previousLevel = currentLevel
		previousLevel.set_pause_mode(PAUSE_MODE_STOP)

		if nextLevel:
			nextLevel.set_pause_mode(PAUSE_MODE_PROCESS)
			currentLevel = nextLevel
			spawn_player_at_current_level()
		else:
			print("FINISHED THE GAME!")

		# Queue new level
		nextLevel = append_new_level()
		if !nextLevel:
			print("No more levels!")

		mainCamera.align_camera_to_level(currentLevel, 0.7)

func append_new_level():
	var level_filename = get_next_level_filename()
	var old_level_position = currentLevel.calculate_bounds()
	var level_instance = instantiate_level(
		level_filename, 
		Vector2(
			old_level_position.max.x,
			old_level_position.min.y + old_level_position.height / 2
		)
	)
	if level_instance:	
		level_instance.set_pause_mode(PAUSE_MODE_STOP)
	return level_instance

func get_next_level_filename():
	var current_level_filename = currentLevel.get_name()
	# Trim first 4 characters as for "lvl_" and convert the rest to number as for "001" to 1
	var current_level_number = current_level_filename.substr(4, 3).to_int()
	# Return new level filename in format "lvl_000" 
	return "lvl_" + str(current_level_number + 1).pad_zeros(3)

func create_player_instance():
	var scene = load("res://src/components/player/player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("player")
	return scene_instance

func spawn_player_at_current_level():
	if playerInstance == null:
		playerInstance = create_player_instance()

	var player_instance_parent = playerInstance.get_parent()
	if (player_instance_parent):
		player_instance_parent.remove_child(playerInstance)

	var spawn_point = currentLevel.get_node("character_spawn_point")
	playerInstance.set_position(spawn_point.get_position())
	spawn_point.get_parent().add_child(playerInstance)