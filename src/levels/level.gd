tool
extends TileMap

var tile_siz = globals.tile_size
var tile_pos = []
var tile_typ = globals.tile_typ


func _ready():
	tile_pos = get_used_cells()


func _process(delta):
	if Engine.is_editor_hint():
		self.set_position(Vector2(0, 0))
	else:
		pass