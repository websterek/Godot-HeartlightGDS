extends Camera2D

onready var tween = $tween

func _ready():
	pass

func align_camera_to_level(levelInstance, duration = 0):
	var tilemap_bounds = levelInstance.calculate_bounds()
	
	var screen_height = ProjectSettings.get_setting("display/window/size/height")
	var screen_width = ProjectSettings.get_setting("display/window/size/width")

	# Scale zoom to always contain whole level
	var zoom_x = tilemap_bounds.width / screen_width
	var zoom_y = tilemap_bounds.height / screen_height
	var zoom = zoom_x if zoom_x > zoom_y else zoom_y

	self.zoom = Vector2(zoom, zoom)
	
	var new_position = Vector2(
				tilemap_bounds.min.x + tilemap_bounds.width / 2 - zoom * screen_width / 2,
				tilemap_bounds.min.y + tilemap_bounds.height / 2 - zoom * screen_height / 2
			)

	# Center view to level
	if duration <= 0:
		self.set_position(new_position)
	else:
		tween.interpolate_property(
			self,
			"position",
			self.get_position(),
			new_position,
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		tween.start()