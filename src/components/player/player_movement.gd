extends RigidBody2D

var coll_stats = Physics2DTestMotionResult.new()
var tile_size = globals.tile_size
var tile_typ = globals.tile_typ

func _ready():
	pass

func kill():
	print("Player dies")

func _input(event):
	if !event:
		pass
	elif Input.is_action_pressed("ui_up"):
		move(globals.directions.TOP)
	elif Input.is_action_pressed("ui_down"):
		move(globals.directions.BOTTOM)
	elif Input.is_action_pressed("ui_left"):
		move(globals.directions.LEFT)
	elif Input.is_action_pressed("ui_right"):
		move(globals.directions.RIGHT)

func coll_test(dir, body=self):
	return Physics2DServer.body_test_motion(body, body.get_global_transform(), dir, 0.16, coll_stats)


func tile_num(dir):
	return (get_position() + dir - (tile_size/2)) / tile_size


func anim(dir, obj=$shape, add=null):
	if add != null:
		$twe.interpolate_property(add, "position", add.get_position() + dir, add.get_position(), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.interpolate_property(obj, "position", $shape.get_position() + dir, $shape.get_position(), 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.start()

func move(direction):
	if $tim.time_left == 0:
		var pos_a = get_position()
		if !coll_test(direction):
			set_player_position(direction)
		else:
			var collider = coll_stats.get_collider()
			if collider.is_in_group("level"):
				var tile_number = tile_num(direction)
				if collider.get_cellv(tile_number) in tile_typ["grass"]:
					collider.set_cellv(tile_number, -1)
					set_player_position(direction)
			
			var can_push = collider.is_in_group("can_be_pushed") and collider.has_method("push")
			var can_collider_roll = (collider.is_in_group("can_roll_down") and collider.is_grounded) or !collider.is_in_group("can_roll_down") 
			if can_push:
				match direction:
					globals.directions.TOP:						
						if collider.push("top"):
							set_player_position(direction)
					globals.directions.BOTTOM:						
						if collider.push("bottom"):
							set_player_position(direction) 
					globals.directions.LEFT:
						if can_collider_roll && collider.push("left"):
							set_player_position(direction)
					globals.directions.RIGHT:						
						if can_collider_roll && collider.push("right"):
							set_player_position(direction)

		if pos_a != get_position():
			$tim.start()

func set_player_position(direction):
	set_position(get_position() + direction)
	anim(-direction)
	

func _on_twe_tween_completed(object, key):
	set_position(get_position().snapped(tile_size) - tile_size/2)
