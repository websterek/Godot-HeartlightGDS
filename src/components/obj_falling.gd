extends RigidBody2D

var spawned = false
var tween = false
var moving = false
var travel_d = 0
var collide_d = true
var lock = false
var tile_size = globals.tile_size
var roll = false
var type = null

signal traveled_d

func _ready():
	randomize()
	$twe_grv.connect("tween_completed", self, "_on_twe_grv_tween_completed")
	if $ray_d.is_colliding():
		set_position(get_position())
		


func _physics_process(delta):
	if !spawned:
		set_position(get_position())
		spawned = true
	
	elif !lock:
		if $ray_d.is_colliding() and globals.tictoc == 0 and type == "granade": # czy jest granatem nie moze byc tutaj bo blokuje sprawdzanie spadania!!!
			if $ray_d.get_collider().is_in_group("rigid"):
				collide_d = $ray_d.get_collider().collide_d
			else:
				collide_d = true
				
			if travel_d > 0 and collide_d == true:
				emit_signal("traveled_d", travel_d)
				travel_d = 0
			set_position(get_position().snapped(Vector2(64, 64)))
			
		if $ray_d.is_colliding() and globals.tictoc == 0 and type != "granade":
			collide_d = true
		
		
		elif !tween and !$ray_d.is_colliding() and globals.tictoc == 0:
			collide_d = false
			tween = true
			set_position(get_position() + Vector2(0, 128))
			$twe_grv.interpolate_property($shape, "position", Vector2(0, 0) - Vector2(0, 128), Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$twe_grv.start()
			travel_d += 1
		
		if !tween and !$ray_l.is_colliding() and !$ray_ld.is_colliding() and $ray_d.is_colliding() and globals.tictoc == 1 and collide_d:
			if $ray_d.get_collider().is_in_group("rigid"):
				tween = true
				set_position(get_position() + Vector2(-128, 0))
				$twe_grv.interpolate_property($shape, "position", Vector2(0, 0) - Vector2(-128, 0), Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$twe_grv.interpolate_property($shape, "rotation_degrees", get_rotation_degrees(), get_rotation_degrees() - rand_range(45, 135), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$twe_grv.start()
		elif !tween and !$ray_r.is_colliding() and !$ray_rd.is_colliding() and $ray_d.is_colliding() and globals.tictoc == 2 and collide_d:
			if $ray_d.get_collider().is_in_group("rigid"):
				tween = true
				set_position(get_position() + Vector2(128, 0))
				$twe_grv.interpolate_property($shape, "position", Vector2(0, 0) - Vector2(128, 0), Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$twe_grv.interpolate_property($shape, "rotation_degrees", get_rotation_degrees(), get_rotation_degrees() + rand_range(45, 135), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				$twe_grv.start()

func anim(dir, obj=$shape):
	$twe.interpolate_property(obj, "position", $shape.get_position() + dir, $shape.get_position(), 0.075, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$twe.start()

func _on_twe_grv_tween_completed(object, key):
	tween = false

func tilemap_type(tilemap, pos):
	var cell_pos =  ((get_position() + pos)-tile_size/2)/tile_size
