extends Node

var currentLevel = null

func instantiate_level(levelFilename, position = Vector2(0, 0)):
	var scene = load("res://src/levels/" + levelFilename + ".tscn")
	var scene_instance = scene.instance()

	scene_instance.set_name(levelFilename)
	scene_instance.global_position = position
	get_node("Levels").add_child(scene_instance)

	return scene_instance

func align_camera_to_level(levelInstance):
	var camera = get_node("MainCamera")
	var tilemap = levelInstance.get_node("level")
	var tilemap_bounds = calculate_tilemap_bounds(tilemap)
	var screen_height = ProjectSettings.get_setting("display/window/size/height")
	var screen_width = ProjectSettings.get_setting("display/window/size/width")

	# Scale zoom to always contain whole level
	var zoom_x = tilemap_bounds.width / screen_width
	var zoom_y = tilemap_bounds.height / screen_height
	var zoom = zoom_x if zoom_x > zoom_y else zoom_y
	
	camera.zoom = Vector2(zoom, zoom)

	# Center view to level
	camera.position = Vector2(
		tilemap_bounds.min.x + tilemap_bounds.width / 2 - zoom * screen_width / 2,
		tilemap_bounds.min.y + tilemap_bounds.height / 2 - zoom * screen_height / 2
	)


func set_level(levelFilename):
	if currentLevel == null:
		currentLevel = instantiate_level(levelFilename)
		align_camera_to_level(currentLevel)
	else:
		var newLevel = instantiate_level()
		pass	

func calculate_tilemap_bounds(tilemap):
	var used_cells = tilemap.get_used_cells()
	var min_x = 0
	var min_y = 0
	var max_x = 1
	var max_y = 1

	for pos in used_cells:
		if pos.x < min_x:
			min_x = int(pos.x)
		elif pos.x > max_x:
			max_x = int(pos.x)
		if pos.y < min_y:
			print("pos.y")
			print(pos.y)
			min_y = int(pos.y)
		elif pos.y > max_y:
			max_y = int(pos.y)

	return {
		"min": Vector2(
			min_x * globals.tile_size.x, 
			min_y * globals.tile_size.y
		),
		"max": Vector2(
			(max_x + 1) * globals.tile_size.x,
			(max_y + 1) * globals.tile_size.y
		),
		"height": (max_y + 1 - min_y) * globals.tile_size.y,
		"width": (max_x + 1 - min_x) * globals.tile_size.x
	}

func _ready():
	print(globals.get_current_player())
	set_level("lvl_template")