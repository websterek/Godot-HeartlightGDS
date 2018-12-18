extends "../obj_falling.gd"


func _ready():
	type = "heart"


func _physics_process(delta):
	yield(get_tree(), "physics_frame")
	if $ray_u.is_colliding():
		var collider = $ray_u.get_collider()
		if collider != null:
			if collider.is_in_group("rigid"):
				if collider.travel_d > 0 and collider.collide_d:
					free_me()


func free_me():
	queue_free()