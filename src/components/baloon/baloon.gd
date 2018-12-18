extends RigidBody2D

var tween = false
var lock = false
var spawned = false
var collider_a = Physics2DTestMotionResult.new()
var collider_b = Physics2DTestMotionResult.new()
var collider_a_x
var collider_b_x
var cargo = 0
var dir = Vector2(0, 0)

#func _ready():
#	if $ray_u.is_colliding():
#		set_position(get_position())


func _physics_process(delta):
	
	if !spawned:
		set_position(get_position())
		spawned = true
	
	elif !lock:
		collider_a_x = Physics2DServer.body_test_motion(self, get_global_transform().translated(Vector2(0, -128)), Vector2(0, 0), 0.16, collider_a)
		collider_b_x = Physics2DServer.body_test_motion(self, get_global_transform().translated(Vector2(0, -256)), Vector2(0, 0), 0.16, collider_b)
		if collider_a_x:
			if collider_a.get_collider().is_in_group("rigid"):
				if collider_b_x:
					if collider_b.get_collider().is_in_group("rigid"):
						cargo = 2
				else:
					cargo = 1
			else:
				cargo = 0
#		if !$ray_d.is_colliding():
#			if !tween:
#				tween = true
#				set_position(get_position() + Vector2(0, 128))
#				$twe.interpolate_property($shape, "position", Vector2(0, 0) - Vector2(0, 128), Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#				$twe.start()


func coll_test(pos, dir, body=self):
	return Physics2DServer.body_test_motion(body, pos, dir, 0.16)


func _on_twe_tween_completed(object, key):
	tween = false
