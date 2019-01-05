extends PhysicsBody2D

const Util = preload("res://src/global/utils.gd")

# ###########
# Node references
# ###########
onready var object_sprite = $shape
onready var movement_animator = $movement_animator

# ###########
# Object configuration
# ###########
var is_rollable = true
var is_pushable = true
var movement_delay = 0.2

# ###########
# Helper variables
# ###########
var current_position = null # Current object position to use during one physics frame
var is_moving = false
var is_moving_direction = null
var is_grounded = false

# ###########
# Lifecycle Hooks
# ###########
func _ready():
	add_to_group("can_fall")
	if is_rollable:
		add_to_group("can_roll_down")
	if is_pushable:
		add_to_group("can_be_pushed")

func _physics_process(delta):
	# Handle object physics only if it is not currently moving
	if !is_moving:
		update_world_state()
		var collision_at_bottom = get_collision_at(globals.directions.BOTTOM)
		
		if collision_at_bottom:
			handle_bottom_collision(collision_at_bottom)
		else:
			var far_bottom_collision = get_collision_at(globals.directions.BOTTOM + globals.directions.BOTTOM)
			if !far_bottom_collision or !far_bottom_collision.collider.is_in_group("balloon"):
				move(globals.directions.BOTTOM, true)

# ###########
# Physics handlers
# ###########
func handle_bottom_collision(collision):
	if can_roll():
		try_rolling_sideways()

func try_rolling_sideways():
	# First try rolling left
	if has_space_to_roll("left"):
		# Check if there is no element on the other side rolling to the same spot
		var far_left_collision = get_collision_at(globals.directions.LEFT + globals.directions.LEFT)
		if far_left_collision:
			var collider = far_left_collision.collider
			if collider.is_in_group("can_roll_down") and collider.is_moving and collider.is_moving_direction == globals.directions.RIGHT:
				return

		move(globals.directions.LEFT)
	# If left side is blocked, try rolling right
	elif has_space_to_roll("right"):
		move(globals.directions.RIGHT)	

func move(direction, handle_impact = false):
	# Block physics calculation for movement duration
	is_moving = true
	is_moving_direction = direction

	set_global_position(current_position + direction)
	current_position = get_global_position()

	# Animate sprite after changing position and check on impact the such option was provided
	movement_animator.connect("tween_completed", self, "_on_movement_finished", [handle_impact], CONNECT_ONESHOT)
	movement_animator.interpolate_property(
		object_sprite, 
		"position",
		-direction,
		Vector2(0,0),
		movement_delay,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	movement_animator.start()

func push(direction):
	var can_player_move = can_be_pushed(direction)

	if can_player_move:
		match direction:
			"left":
				move(globals.directions.LEFT)
			"right":
				move(globals.directions.RIGHT)
			"top":
				can_player_move = false

	return can_player_move

func elevate():
	var can_player_move = can_be_pushed("top")
	if can_player_move:
		move(globals.directions.TOP)
	return can_player_move

func _on_movement_finished(object, key, handle_impact):
	is_moving = false
	is_moving_direction = null
	# Add "bottom_impact" function in a script that extends obj_falling to handle impact
	if handle_impact and has_method("bottom_impact"):
		var collision_after_move = get_collision_at(globals.directions.BOTTOM)
		if collision_after_move:
			bottom_impact(collision_after_move)

# ###########
# Physics state helpers
# ###########
func update_world_state():
	current_position = get_global_position()
	update_grounded_state()

func update_grounded_state():
	var collision = get_collision_at(globals.directions.BOTTOM)
	if collision:
		var collider = collision.collider
		if collider.get_class() == "TileMap" or collider.is_in_group("balloon"):
			is_grounded = true
		elif collider.is_in_group("can_fall"):
			is_grounded = collider.is_grounded
		else:
			is_grounded = false

# ###########
# Assertions
# ###########
func can_be_pushed(direction):
	var side_collision = null
	match direction:
		"left":
			side_collision =  get_collision_at(globals.directions.LEFT)
			return is_grounded and !is_moving and !side_collision
		"right":
			side_collision =  get_collision_at(globals.directions.RIGHT)
			return is_grounded and !is_moving and !side_collision
		"top":
			var top_collision =  get_collision_at(globals.directions.TOP)
			return !is_moving and !top_collision
		_:
			return false

func can_roll():
	var bottom_collision = get_collision_at(globals.directions.BOTTOM)
	var is_ground_slippery = true 

	if (bottom_collision.collider.get_class() == "TileMap"):
		var tile_index = Util.get_tile_id_by_collision(bottom_collision)		
		if (tile_index == -1 or globals.tile_typ["grass"].has(tile_index)):
			is_ground_slippery = false
	elif bottom_collision.collider.is_in_group("player"):
		is_ground_slippery = false

	return is_grounded and is_rollable and is_ground_slippery

func has_space_to_roll(direction):
	var side_collision = null
	var bottom_collision = null
	var top_collision = null
	match direction:
		"left":
			side_collision =  get_collision_at(globals.directions.LEFT)
			bottom_collision =  get_collision_at(globals.directions.BOTTOM_LEFT)
			top_collision =  get_collision_at(globals.directions.TOP_LEFT)
		"right":
			side_collision =  get_collision_at(globals.directions.RIGHT)
			bottom_collision =  get_collision_at(globals.directions.BOTTOM_RIGHT)
			top_collision =  get_collision_at(globals.directions.TOP_RIGHT)
		_:
			printerr("Wrong argument provided for 'has_space_to_roll' function!")
			return false

	var something_is_above = top_collision and top_collision.collider.is_in_group("can_fall")

	return !side_collision and !bottom_collision and !something_is_above

func get_collision_at(direction):
	var target = current_position + direction
	var result = get_world_2d().direct_space_state.intersect_point(target)

	if result:
		return { "position": target, "collider": result[0].collider }
	else:
		return {}