extends Container

# ###########
# Node references
# ###########
onready var game_manager = get_node("/root/Root")

onready var hearts_left = get_node("hearts/left")
onready var hearts_max = get_node("hearts/max")

var current_level = null

func _ready():
	game_manager.connect("current_level_changed", self, "_level_changed")

func _level_changed(new_level):
	if current_level and current_level.is_connected("hearts_changed", self, "_hearts_changed"):
		current_level.disconnect("hearts_changed", self, "_hearts_changed")
	current_level = new_level
	update_hearts_ui(current_level.remaining_hearts.size(), current_level.max_hearts)
	current_level.connect("hearts_changed", self, "_hearts_changed")

func _hearts_changed(remaining_h, max_h):
	update_hearts_ui(remaining_h, max_h)

func update_hearts_ui(remaining_h, max_h):
	hearts_left.set_text(str(remaining_h))
	hearts_max.set_text(str(max_h))