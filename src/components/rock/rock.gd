extends "../obj_falling.gd"

# Override default obj_falling fields
func _init():
	movement_duration = globals.config.get_value("rock", "movement_duration")
	

func _ready():
	$audio.set_volume_db(globals.config.get_value("rock", "volume_db"))

func bottom_impact(collision):
	var collider = collision.collider
	if (collider.is_in_group("player")):
		collider.kill()
	if (collider.is_in_group("grenade")):
		collider.explode()