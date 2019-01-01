extends "../obj_falling.gd"

onready var levelInstance = get_node("../")
onready var heart_name = get_name()

func _ready():
	levelInstance.register_heart(heart_name)

func push(direction = null):
	destroy_heart()
	return true

func destroy_heart():
	levelInstance.remove_heart(heart_name)
	queue_free()

func bottom_impact(collision):
	var collider = collision.collider
	if (collider.is_in_group("player")):
		collider.kill()