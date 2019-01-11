extends Camera2D

onready var tween = $tween
onready var overlay = get_node("canvas/ColorRect")

signal transition_completed

func _ready():
	pass

func align_camera_to_level(levelInstance, duration = 0):
	var tilemap_bounds = levelInstance.calculate_bounds()
	var level_position = levelInstance.get_global_position()

	# Scale zoom to always contain whole level
	var zoom = levelInstance.calculate_zoom(tilemap_bounds)

	var new_position = Vector2(
		level_position.x + tilemap_bounds.offset.x + tilemap_bounds.width / 2,
		level_position.y + tilemap_bounds.offset.y + tilemap_bounds.height / 2
	)

	# Center view to level
	if levelInstance.level_filename == "lvl_final":
		tween.connect("tween_completed", self, "_on_fade_finished", [new_position, zoom], CONNECT_ONESHOT)
		fade_down()
	elif duration <= 0:
		self.set_position(new_position)
		self.zoom = Vector2(zoom, zoom)
	else:
		tween.connect("tween_completed", self, "_on_transition_finished", [], CONNECT_ONESHOT)
		tween.interpolate_property(
			self,
			"position",
			self.get_position(),
			new_position,
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		tween.interpolate_property(
			self,
			"zoom",
			self.zoom,
			Vector2(zoom, zoom),
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		tween.start()

func fade_down():
	tween.interpolate_property(
		overlay,
		"color",
		Color(0, 0, 0, 0),
		Color(0, 0, 0, 1),
		2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_fade_finished(object, key, new_position, zoom):
	self.set_position(new_position)
	self.zoom = Vector2(zoom, zoom)

	tween.connect("tween_completed", self, "_on_transition_finished", [], CONNECT_ONESHOT)
	tween.interpolate_property(
		overlay,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween.start()

func _on_transition_finished(object, key):
	emit_signal("transition_completed")