extends "../obj_falling.gd"

# Override default obj_falling fields
func _init():
	movement_delay = 0.2

func _ready():
	pass

func bottom_impact(collision):
	var collider = collision.collider
	if (collider.is_in_group("player")):
		collider.kill()
	if (collider.is_in_group("grenade")):
		collider.explode()