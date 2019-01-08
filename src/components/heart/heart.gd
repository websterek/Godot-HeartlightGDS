extends "../obj_falling.gd"

onready var levelInstance = get_node("../")
onready var heart_name = get_name()

func _ready():
	levelInstance.register_heart(heart_name)
	$audio.set_volume_db(globals.config.get_value("rock", "volume_db"))
	$audio_take.set_volume_db(globals.config.get_value("heart", "volume_db"))

func push(direction = null):
	set_visible(false)
	$col.set_disabled(true)
	$audio_take.play()
	yield($audio_take, "finished")
	destroy_heart()
	return true

func destroy_heart():
	levelInstance.remove_heart(heart_name)
	queue_free()

func bottom_impact(collision):
	var collider = collision.collider
	if (collider.is_in_group("player")):
		collider.kill()