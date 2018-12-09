tool
extends TileMap

var tile_size = globals.tile_size
var tile_pos = []
var tile_typ = globals.tile_typ

func _ready():
	tile_pos = get_used_cells()


func _process(delta):
	if Engine.is_editor_hint():
		self.set_position(Vector2(0, 0))
	else:
		pass

func calculate_bounds():
	var level_instance = get_parent()
	var used_cells = self.get_used_cells()
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
			min_x * tile_size.x + level_instance.position.x, 
			min_y * tile_size.y + level_instance.position.y
		),
		"max": Vector2(
			(max_x + 1) * tile_size.x + level_instance.position.x,
			(max_y + 1) * tile_size.y + level_instance.position.y
		),
		"height": (max_y + 1 - min_y) * tile_size.y,
		"width": (max_x + 1 - min_x) * tile_size.x
	}