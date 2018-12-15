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
	
	for ray in [$ray_u, $ray_d, $ray_l, $ray_r]:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.get_class() == "TileMap":
				tilemap_clean(collider, ray.get_collision_point())
			elif collider.is_in_group("rigid"):
				collider.queue_free()
	self.queue_free()


func tilemap_clean(tilemap, collision_point):
	var cell = tilemap_coll(tilemap, collision_point)
	
	if !globals.tile_typ["wall"].has(tilemap.get_cellv(cell)):
		tilemap.set_cellv(cell, -1)
