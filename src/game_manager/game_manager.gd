extends Node

onready var mainCamera = get_node("MainCamera")
var previousLevel = null
var currentLevel = null

func _input(event):
	if !event:
		pass
	elif Input.is_action_pressed("ui_accept"):
		set_level("level_01")

func instantiate_level(levelFilename, position = Vector2(0, 0)):
	var scene = load("res://src/levels/" + levelFilename + ".tscn")
	var scene_instance = scene.instance()
	var scene_instance_bounds = scene_instance.get_node("level").calculate_bounds()

	scene_instance.set_name(levelFilename)
	scene_instance.global_position = Vector2(position.x, position.y - scene_instance_bounds.height / 2)
	get_node("Levels").add_child(scene_instance)

	return scene_instance

func set_level(levelFilename):
	if currentLevel == null:
		currentLevel = instantiate_level(levelFilename)
		mainCamera.align_camera_to_level(currentLevel)
	else:
		var current_level_position = currentLevel.calculate_bounds()
		var new_level = instantiate_level(
			levelFilename, 
			Vector2(
				current_level_position.max.x,
				current_level_position.min.y + current_level_position.height / 2
			)
		)
		if previousLevel != null:
			previousLevel.queue_free()
		previousLevel = currentLevel
		currentLevel = new_level
		mainCamera.align_camera_to_level(currentLevel, 0.7)

func _ready():
	print(globals.get_current_player())
	set_level("lvl_template")