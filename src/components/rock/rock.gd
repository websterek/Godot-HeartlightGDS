extends RigidBody2D

var spawned = false


func _ready():
	if $ray.is_colliding():
		set_position(get_position())


func _physics_process(delta):
	if !spawned:
		set_position(get_position())
		spawned = true
	else:
		if $ray.is_colliding() or get_colliding_bodies().size() > 0:
			$twe_grv.stop_all()
			set_position(get_position().snapped(Vector2(64, 64)))
		else:
			$tim.start()
			$twe_grv.interpolate_property(self, "position", get_position(), get_position() + Vector2(0, 128), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$twe_grv.start()


func anim(dir, obj=$shape):
	$twe.interpolate_property(obj, "position", $shape.get_position() + dir, $shape.get_position(), 0.075, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$twe.start()