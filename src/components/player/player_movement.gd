extends RigidBody2D

var coll_stats = Physics2DTestMotionResult.new()
var tile_size = globals.tile_size
var tile_typ = globals.tile_typ
var moving = Vector2()


func _ready():
	pass


func _input(event):
	if !event:
		pass
	elif Input.is_action_pressed("ui_left"):
		move(Vector2(globals.tile_size.x, 0))
	elif Input.is_action_pressed("ui_right"):
		move(Vector2(-globals.tile_size.x, 0))
	elif Input.is_action_pressed("ui_down"):
		move(Vector2(0, -globals.tile_size.y))
	elif Input.is_action_pressed("ui_up"):
		move(Vector2(0, globals.tile_size.y))

func coll_test(dir, body=self):
	return Physics2DServer.body_test_motion(body, body.get_global_transform(), dir, 0.16, coll_stats)


func tile_num(dir):
	return (get_position() - (tile_size/2) + dir) / tile_size


func anim(dir, obj=$shape, add=null):
	if add != null:
		$twe.interpolate_property(add, "position", add.get_position() + dir, add.get_position(), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.interpolate_property(obj, "position", $shape.get_position() + dir, $shape.get_position(), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.start()

func move(dir):
	if $tim.time_left == 0:
		moving = dir
		var pos_a = get_position()
		if !coll_test(-dir):
			set_position(get_position() - dir)
			anim(dir)
		else:
			var collider = coll_stats.get_collider()
			if collider.is_in_group("level"):
				var tile_num = tile_num(-dir)
				if collider.get_cellv(tile_num) in tile_typ["grass"]:
					collider.set_cellv(tile_num, -1)
					set_position(get_position() - dir)
					anim(dir)
				else:
					pass
			if collider.is_in_group("sphere") or collider.is_in_group("grenade"):
				if coll_test(-dir, collider):
					pass
				elif collider.get_node("ray_d").is_colliding() and dir.y <= 0:
					collider.movement(-moving.normalized())
					set_position(get_position() - dir)
					anim(dir, $shape, collider)
#					collider.set_position(collider.get_position() - dir)
#					set_position(get_position() - dir)
#					anim(dir, $shape, collider)
			if collider.is_in_group("heart"):
				collider.free_me()
				set_position(get_position() - dir)
				anim(dir)
		if pos_a != get_position():
			$tim.start()




func _on_twe_tween_completed(object, key):
	set_position(get_position().snapped(tile_size) - tile_size/2)
#	moving = Vector2()
