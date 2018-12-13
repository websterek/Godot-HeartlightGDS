extends "../obj_falling.gd"

onready var ray = get_node("ray")

func _ready():
	type = "granade"
	self.connect("traveled_d", self, "explode")

var gui_position = null

func explode(traveled_d):
	var pos = get_position().snapped(globals.tile_size-Vector2(64, 64))
	lock = true
	set_position(pos)
	yield($twe_grv,"tween_completed")
	$twe_grv.stop_all()

	var directions = [
		Vector2(-globals.tile_size.x, 0), 
		Vector2(0, -globals.tile_size.y), 
		Vector2(globals.tile_size.x, 0),
		Vector2(0, globals.tile_size.y)	
	]

	for direction in directions:
		ray.cast_to = direction
		
		if ray.is_colliding():			
			var collider = ray.get_collider()
			if collider.get_class() == "TileMap":
				tilemap_clean(collider, ray.get_collision_point())
			elif collider.is_in_group("rigid"):
				collider.queue_free()
	self.queue_free()


func tilemap_clean(tilemap, collision_point):
	var grenade_position = get_position()
	var global_grenade_position = get_global_transform().origin
	var dir = (global_grenade_position - collision_point).normalized() * tile_size
	var tile_coords = tilemap.world_to_map(grenade_position + dir)
	var tile_type = tilemap.get_cellv(tile_coords)
	print('collision_point: ' + str(collision_point) + 'Grenade: ' + str(grenade_position))
	print('CLEANING: ' + str(tile_type) + ' at ' + str(tile_coords) + ', dir: ' + str(dir))
	if globals.tile_typ["grass"].has(tile_type) or globals.tile_typ["block"].has(tile_type):
		print("SIEMA")
		tilemap.set_cell(tile_coords.x, tile_coords.y, -1)