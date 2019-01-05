extends StaticBody2D

onready var levelInstance = get_node("../")
onready var gameManager = get_node("/root/Root")
onready var animator = get_node("AnimationPlayer")

var is_open = false

func _ready():		
	levelInstance.connect("heart_added", self, "close")
	levelInstance.connect("all_hearts_taken", self, "open")

func open():
	is_open = true
	animator.play("open")
	
func close():
	is_open = false
	animator.play("close")

func push(direction = null):
	if is_open:
		gameManager.win_level()
		return true
	else:
		return false