extends "../obj_falling.gd"

func _ready():
	type = "heart"

func free_me():
	queue_free()