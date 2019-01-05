extends "../obj_falling.gd"

const Util = preload("res://src/global/utils.gd")

func _init():
	is_rollable = false

func _ready():
	pass

func bottom_impact(collision):
	if is_tile_of_type(collision, "grass"):
		pass
	else:
		explode()

func is_tile_of_type(collision, type):
	var tile_index = Util.get_tile_id_by_collision(collision)
	return globals.tile_typ[type].has(tile_index)

func explode():
	var collisions = [
		{
			"direction": globals.directions.TOP,
			"value": get_collision_at(globals.directions.TOP)
		},
		{
			"direction": globals.directions.BOTTOM,
			"value": get_collision_at(globals.directions.BOTTOM)
		},
		{
			"direction": globals.directions.LEFT,
			"value": get_collision_at(globals.directions.LEFT)
		},
		{
			"direction": globals.directions.RIGHT,
			"value": get_collision_at(globals.directions.RIGHT)
		}
	]

	var grenade_position = get_position()

	for collision in collisions:
		destroy_item(collision.value, grenade_position + collision.direction)

	instantiate_explosion(grenade_position)

	queue_free()

func destroy_item(collision, position):
	if collision:
		var collider = collision.collider
		if collider.get_class() == "TileMap":
			if !is_tile_of_type(collision, "wall"):
				Util.destroy_tile_by_collision(collision)
				instantiate_explosion(position)
		elif collider.is_in_group("player"):
			collider.kill()
			instantiate_explosion(position)
		elif collider.is_in_group("can_fall"):
			collider.queue_free()
			instantiate_explosion(position)
	else:
		instantiate_explosion(position)
 
func instantiate_explosion(position):
	var level = get_parent()
	var scene = load("res://src/components/explosion/explosion.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_position(position)
	level.add_child(scene_instance)
	
