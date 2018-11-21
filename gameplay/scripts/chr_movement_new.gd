extends RigidBody2D

var coll_stats = Physics2DTestMotionResult.new()
var tile_size = globals.tile_size
var tile_typ = globals.tile_typ
var moving = false


func _ready():
	pass


func _process(delta):
	var input_direction = get_input_direction()*tile_size
	print(input_direction)
	if !coll_test(input_direction):
		move_to(input_direction)


func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		)


func coll_test(dir, body=self):
	return Physics2DServer.body_test_motion(body, body.get_transform(), dir, 0.16, coll_stats)


func tile_num(dir):
	return (get_position() - (tile_size/2) + dir) / tile_size


func move_to(input_direction):
	set_process(false)
	anim(input_direction)
	yield($twe, "tween_completed")
	set_process(true)


func anim(dir, add=null):
	if add != null:
		$twe.interpolate_property(add, "position", add.get_position() + dir, add.get_position(), 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.interpolate_property(self, "position", get_position(), get_position() + dir, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$twe.start()