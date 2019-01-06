extends PhysicsBody2D

# const Util = preload("res://src/global/utils.gd")

# ###########
# Node references
# ###########
onready var object_sprite = $shape
onready var movement_animator = $movement_animator
onready var movement_delay_timer = $timer

# ###########
# Object configuration
# ###########
var movement_duration = globals.config.get_value("owl", "movement_duration")
var movement_delay = globals.config.get_value("owl", "movement_delay")

# ###########
# Helper variables
# ###########
var current_position = null # Current object position to use during one physics frame
var is_moving = false
var is_moving_direction = null

func _ready():
	movement_delay_timer.set_wait_time(movement_delay)
	add_to_group("can_be_pushed")

func _physics_process(delta):
	# Handle object physics only if it is not currently moving
	print(movement_delay_timer.is_stopped())
	if !is_moving and movement_delay_timer.is_stopped():
		update_world_state()
		var collision_at_top = get_collision_at(globals.directions.TOP)
	
		if collision_at_top:
			handle_top_collision(collision_at_top)
		else:
			move(globals.directions.TOP)
		
# ###########
# Physics handlers
# ###########
func handle_top_collision(collision):
	var collider = collision.collider
	var can_push = collider.is_in_group("can_be_pushed") and collider.has_method("elevate")
	if can_push:
		if collider.elevate():
			move(globals.directions.TOP)

func move(direction):
	# Block physics calculation for movement duration
	is_moving = true
	is_moving_direction = direction

	set_global_position(current_position + direction)
	current_position = get_global_position()

	# Animate sprite after changing position and check on impact the such option was provided
	movement_animator.connect("tween_completed", self, "_on_movement_finished", [], CONNECT_ONESHOT)
	movement_animator.interpolate_property(
		object_sprite, 
		"position",
		-direction,
		Vector2(0,0),
		movement_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	movement_animator.interpolate_property(
		$shape, 
		"frame",
		0,
		11,
		movement_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	movement_animator.start()

func _on_movement_finished(object, key):
	movement_delay_timer.start()
	is_moving = false
	is_moving_direction = null

func push(direction):
	var can_player_move = can_be_pushed(direction)

	if can_player_move:
		match direction:
			"left":
				move(globals.directions.LEFT)
			"right":
				move(globals.directions.RIGHT)

	return can_player_move

# ###########
# Physics state helpers
# ###########
func update_world_state():
	current_position = get_global_position()

# ###########
# Assertions
# ###########	
func can_be_pushed(direction):
	var side_collision = null
	match direction:
		"left":
			side_collision =  get_collision_at(globals.directions.LEFT)
		"right":
			side_collision =  get_collision_at(globals.directions.RIGHT)
		_:
			return false
	return !is_moving and !side_collision

func get_collision_at(direction):
	var target = current_position + direction
	var result = get_world_2d().direct_space_state.intersect_point(target)

	if result:
		return { "position": target, "collider": result[0].collider }
	else:
		return {}