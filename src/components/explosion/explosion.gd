extends AnimatedSprite

func _ready():
#	connect("animation_finished", self, "_on_animation_finished")
	$audio.set_volume_db(globals.config.get_value("explosion", "volume_db"))
	$audio.connect("finished", self, "_on_animation_finished")
	play()
	$audio.play()

func _on_animation_finished():
	queue_free()