extends Node

onready var mainCamera = get_node("MainCamera")
var previousLevel = null
var currentLevel = null
var playerInstance = null

func _input(event):
    if !event:
        pass
    elif Input.is_action_pressed("ui_cancel"):
        playerInstance.kill()

func _ready():
	go_to_next_level()

func instantiate_level(level_filename, position = Vector2(0, 0), ignoreAligning = false):
	var scene = load("res://src/levels/" + level_filename + ".tscn")
	if scene:
		var scene_instance = scene.instance()
		var scene_instance_bounds = scene_instance.calculate_bounds()

		scene_instance.set_name(level_filename)
		if !ignoreAligning:
			
			var camera_zoom = scene_instance.calculate_zoom(scene_instance_bounds)
			var screen_offset = calculate_screen_offset(scene_instance_bounds.width, camera_zoom)

			scene_instance.set_global_position(Vector2(
				position.x + screen_offset,
				position.y - scene_instance_bounds.height / 2
			))
		else:
			scene_instance.set_global_position(position)
		get_node("Levels").add_child(scene_instance)

		scene_instance.level_filename = level_filename
		return scene_instance
	else:
		print("No level with filename '" + level_filename + "' found.")
		return null

func go_to_next_level():
	if currentLevel == null:
		# Load current level and next level for smooth animation
		currentLevel = instantiate_level("lvl_001")
		spawn_player_at_current_level()
	else:
		# Stop processing current level, set next level as a current one
		if previousLevel != null:
			previousLevel.queue_free()

		previousLevel = currentLevel

		currentLevel = append_new_level()

		if currentLevel:
			spawn_player_at_current_level(true, 0.7)
		else:
			printerr("No more levels!")	

func win_level():
	playerInstance.play_win_animation()

func append_new_level(ignoreOffset = false):
	var level_filename = get_next_level_filename()
	var old_level_bounds = currentLevel.calculate_bounds()

	var screen_offset = 0

	if !ignoreOffset:
		var camera_zoom = currentLevel.calculate_zoom(old_level_bounds)
		screen_offset = calculate_screen_offset(old_level_bounds.width, camera_zoom)

	var level_instance = instantiate_level(
		level_filename, 
		Vector2(
			old_level_bounds.max.x + screen_offset,
			old_level_bounds.min.y + old_level_bounds.height / 2
		)
	)
	return level_instance

func calculate_screen_offset(level_width, zoom = 1):
	# If level is narrower than a screen, add offset to spawn next level so there is always only one level visible on a screen
	var screen_width = ProjectSettings.get_setting("display/window/size/width")
	var zoomed_screen_width = screen_width * zoom

	if zoomed_screen_width > level_width:
		var offset = zoomed_screen_width / 2 - level_width / 2
		return ceil(offset / 64) * 64
	else:
		return 0


func get_next_level_filename():
	var current_level_filename = currentLevel.level_filename
	# Trim first 4 characters as for "lvl_" and convert the rest to number as for "001" to 1
	var current_level_number = current_level_filename.substr(4, 3).to_int()
	# Return new level filename in format "lvl_000" 
	return "lvl_" + str(current_level_number + 1).pad_zeros(3)

func reset_current_level():
	var new_instance = instantiate_level(
		currentLevel.level_filename, 
		currentLevel.get_global_position(),
		true
	)
	currentLevel.queue_free()
	currentLevel = new_instance
	spawn_player_at_current_level(false)


func create_player_instance():
	var scene = load("res://src/components/player/player.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("player")
	return scene_instance

func spawn_player_at_current_level(alignCamera = true, transitionTime = null):
	if playerInstance == null:
		playerInstance = create_player_instance()

	var player_instance_parent = playerInstance.get_parent()
	if (player_instance_parent):
		player_instance_parent.remove_child(playerInstance)

	var spawn_point = currentLevel.get_node("character_spawn_point")
	playerInstance.set_position(spawn_point.get_position())
	spawn_point.get_parent().add_child(playerInstance)
	
	get_tree().set_pause(true)
	if alignCamera:
		if transitionTime:
			var camera_animator = mainCamera.get_node("tween")
			mainCamera.align_camera_to_level(currentLevel, transitionTime)
			yield(camera_animator, "tween_completed")
		else:
			mainCamera.align_camera_to_level(currentLevel)
	
	yield(get_tree(), "physics_frame")
	spawn_point.queue_free()
	get_tree().set_pause(false)
	