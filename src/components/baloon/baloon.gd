extends RigidBody2D

var tween = false
var lock = false
var spawned = false
var collider_a_data = Physics2DTestMotionResult.new()
var collider_b_data = Physics2DTestMotionResult.new()
var collider_a
var collider_b
var collider_u
var ray_u_collider = null
var cargo = 0
var dir = Vector2(0, 0)


func _ready():
	set_position(get_position())


func _physics_process(delta):
	if !spawned:
		set_position(get_position())
		spawned = true
	
	elif !lock and spawned:
		if $ray_u.is_colliding():
			collider_u = $ray_u.get_collider()
			if collider_u.is_in_group("rigid"):
				if !collider_u.collide_u and !collider_u.tween:
					collider_u.movement(Vector2(0, -1))
				elif collider_u.collide_u and !collider_u.tween:
					if collider_u.collider_u.is_in_group("rigid") and !$ray_d.is_colliding():
						collider_u.collider_u.movement(Vector2(0, 1))
						collider_u.movement(Vector2(0, 1))
						movement(Vector2(0, 1))
		else:
			if !tween:
				movement(Vector2(0, -1))


func movement(dir):
	tween = true
	dir = dir * globals.tile_size
	set_position(get_position() + dir)
	$twe.interpolate_property($shape, "position", Vector2(0, 0) - dir, Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$twe.start()


func coll_test(pos, dir, body=self):
	return Physics2DServer.body_test_motion(body, pos, dir, 0.16)


func _on_twe_tween_completed(object, key):
	tween = false
