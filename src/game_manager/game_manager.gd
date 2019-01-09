extends Node

onready var mainCamera = get_node("MainCamera")
var previousLevel = null
var currentLevel = null
var playerInstance = null
var volume_music = globals.config.get_value("music", "volume_db_game")

var levels = []
var passed_levels = []

signal current_level_changed(new_level)
signal level_passed(passed_l, max_l)

func _input(event):
    if !event:
        pass
    elif Input.is_action_pressed("ui_cancel"):
        playerInstance.kill()
    elif Input.is_action_pressed("ui_page_up"):
        go_to_next_level()
    elif Input.is_action_pressed("ui_page_down"):
        go_to_next_level(true)

func _ready():
	get_all_levels_list()
	emit_signal("level_passed", passed_levels, levels)
	go_to_next_level()
	$audio.set_volume_db(volume_music)

# ###########
# Level counting functions
# ###########

func get_all_levels_list():
	var directory = Directory.new()
	var level_number = 1
	var found_end = false

	while !found_end:
		var level_file_name = "lvl_" + str(level_number).pad_zeros(3)
		if directory.file_exists("res://src/levels/" + level_file_name + ".tscn"):
			add_level_to_list(levels, level_file_name)
		else:
			found_end = true

		level_number += 1
	
func add_level_to_list(list, level_name):
	if list.find(level_name) == -1:
		list.append(level_name)
	
# ###########
# Level queue functions
# ###########

func instantiate_level(level_filename, position = Vector2(0, 0), ignoreAligning = false, stick_by_right_side = false):
	var scene = load("res://src/levels/" + level_filename + ".tscn")
	if scene:
		var scene_instance = scene.instance()
		var scene_instance_bounds = scene_instance.calculate_bounds()

		scene_instance.set_name(level_filename)
		if !ignoreAligning:
			
			var camera_zoom = scene_instance.calculate_zoom(scene_instance_bounds)
			var screen_offset = calculate_screen_offset(scene_instance_bounds.width, camera_zoom)

			var scene_x = 0

			if !stick_by_right_side:
				scene_x = position.x + screen_offset
			else:
				scene_x = position.x - scene_instance_bounds.width - screen_offset

			scene_instance.set_global_position(Vector2(
				scene_x,
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

func set_current_level(new_level):
	currentLevel = new_level
	emit_signal("current_level_changed", currentLevel)

func go_to_next_level(previous = false):
	if currentLevel == null:
		# Load current level and next level for smooth animation
		var first_level_filename = globals.config.get_value("base", "first_level_filename")
		set_current_level(instantiate_level(first_level_filename))
		emit_signal("current_level_changed", currentLevel)
		spawn_player_at_current_level()
		play_song(currentLevel.get_name())
	else:
		# Stop processing current level, set next level as a current one
		if previousLevel != null:
			previousLevel.queue_free()

		previousLevel = currentLevel

		set_current_level(append_new_level(previous))

		if currentLevel:
			spawn_player_at_current_level(true, 0.7)
			play_song(currentLevel.get_name())
		else:
			printerr("No more levels!")	

func win_level():
	add_level_to_list(passed_levels, currentLevel.level_filename)
	emit_signal("level_passed", passed_levels, levels)
	playerInstance.play_win_animation()

func append_new_level(previous = false):
	var level_filename = null
	if !previous:
		level_filename = get_next_level_filename()
	else:
		level_filename = get_previous_level_filename()
	var old_level_bounds = currentLevel.calculate_bounds()

	var camera_zoom = currentLevel.calculate_zoom(old_level_bounds)
	var screen_offset = calculate_screen_offset(old_level_bounds.width, camera_zoom)

	var new_x = 0

	if !previous:
		new_x = old_level_bounds.max.x + screen_offset
	else:
		new_x = old_level_bounds.min.x - screen_offset

	var level_instance = instantiate_level(
		level_filename, 
		Vector2(
			new_x,
			old_level_bounds.min.y + old_level_bounds.height / 2
		),
		false,
		previous
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

func get_previous_level_filename():
	var first_level_filename = levels.front()
	if currentLevel.level_filename == first_level_filename:
		return levels.back()	
	else:
		# Return new level filename in format "lvl_000" 
		return "lvl_" + str(currentLevel.get_level_number() - 1).pad_zeros(3)

func get_next_level_filename():
	var last_level_filename = levels.back()
	if currentLevel.level_filename == last_level_filename:
		return levels.front()	
	else:
		# Return new level filename in format "lvl_000" 
		return "lvl_" + str(currentLevel.get_level_number() + 1).pad_zeros(3)

func reset_current_level():
	var new_instance = instantiate_level(
		currentLevel.level_filename, 
		currentLevel.get_global_position(),
		true
	)
	currentLevel.queue_free()
	set_current_level(new_instance)
	emit_signal("current_level_changed", currentLevel)
	spawn_player_at_current_level(false)


# ###########
# Player functions
# ###########

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

# ###########
# Audio functions
# ###########

func play_song(song):
	var speech_player = AudioStreamPlayer.new()
	var audio_file = "res://assets/audio_music/" + song + ".sample"
	var music
	if File.new().file_exists(audio_file):
	    music = load(audio_file)
	
	if $audio.is_playing():
		get_node("audio/twe").interpolate_property($audio, "volume_db", volume_music, -80, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("audio/twe").start()
		yield(get_node("audio/twe"), "tween_completed")
		$audio.stop()
	$audio.stream = music
	$audio.play(0)
	get_node("audio/twe").interpolate_property($audio, "volume_db", -80, volume_music, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("audio/twe").start()
