static func get_collision_at(physicsbody, direction, position, print_it = false):
	var target = position + direction
	var collisions = physicsbody.get_world_2d().direct_space_state.intersect_point(target)

	if get_name() == "lvl_sphere" and print_it:
		print("TEST")
		for item in collisions:
			print(item.collider.name)


	for item in collisions:
		if item.collider.is_in_group("player"):
			return { "position": target, "collider": item.collider }

	for item in collisions:
		if item.collider.get_class() == "KinematicBody2D":
			return { "position": target, "collider": item.collider }

	if collisions:
		return { "position": target, "collider": collisions[0].collider }
	else:
		return {}