extends RigidBody2D

onready var game_manager = get_node("/root/Root")

# ###########
# Node references
# ###########
onready var object_sprite = $shape
onready var movement_animator = $twe
onready var movement_delay_timer = $tim

var coll_stats = Physics2DTestMotionResult.new()
var tile_size = globals.tile_size
var tile_typ = globals.tile_typ

var is_locked = false
var is_moving = false

var movement_duration = 0.15
var movement_delay = 0.03
var jump_anim_first_frame = 0
var jump_anim_last_frame = 13

func _ready():
	movement_delay_timer.set_wait_time(movement_delay)

func kill():
	print("Player dies")
	game_manager.reset_current_level()

func _physics_process(event):
	if !is_locked and !is_moving and movement_delay_timer.is_stopped():
		if Input.is_action_pressed("ui_up"):
			move(globals.directions.TOP)
		elif Input.is_action_pressed("ui_down"):
			move(globals.directions.BOTTOM)
		elif Input.is_action_pressed("ui_left"):
			move(globals.directions.LEFT)
		elif Input.is_action_pressed("ui_right"):
			move(globals.directions.RIGHT)

func coll_test(dir, body=self):
	return Physics2DServer.body_test_motion(body, body.get_global_transform(), dir, 0.16, coll_stats)


func get_tile_coordinates(dir):
	return (get_position() + dir - (tile_size/2)) / tile_size

func move(direction):	
	if !coll_test(direction):
		set_player_position(direction)
	else:
		var collider = coll_stats.get_collider()
		if collider.is_in_group("level"):				
			var tile_coordinates = collider.world_to_map(get_position() + direction)
			if collider.get_cellv(tile_coordinates) in tile_typ["grass"]:
				collider.set_cellv(tile_coordinates, -1)
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

func set_player_position(direction):	
	is_moving = true
	set_position(get_position() + direction)
	anim(direction)
	
func anim(direction, add=null):
	if direction == globals.directions.RIGHT:
		object_sprite.set_flip_h(false)
	elif direction == globals.directions.LEFT:
		object_sprite.set_flip_h(true)

	movement_animator.connect("tween_completed", self, "_on_movement_finished", [], CONNECT_ONESHOT)
	movement_animator.interpolate_property(
		object_sprite,
		"position",
		-direction,
		Vector2(0,0),
		movement_duration,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)
	movement_animator.interpolate_property(
		object_sprite,
		"frame",
		jump_anim_first_frame,
		jump_anim_last_frame,
		movement_duration,
		Tween.TRANS_CIRC,
		Tween.EASE_OUT
	)
	movement_animator.start()

func _on_movement_finished(object, key):
	is_moving = false
	object_sprite.set_frame(0)	
	movement_delay_timer.start()

func _on_win_finished():	
	is_locked = false
	object_sprite.stop()
	object_sprite.set_animation("jump")
	game_manager.go_to_next_level()

func play_win_animation():	
	is_locked = true
	object_sprite.connect("animation_finished", self, "_on_win_finished", [], CONNECT_ONESHOT)
	object_sprite.play("win")
