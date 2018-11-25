extends Container

onready var Player1Button = get_node("Options/Player1")
onready var Player2Button = get_node("Options/Player2")
onready var Player3Button = get_node("Options/Player3")

func _ready():
	self.rect_size = Vector2(
			ProjectSettings.get_setting("display/window/size/width"), 
			ProjectSettings.get_setting("display/window/size/height")
		)
	
	Player1Button.connect("pressed", self, "startGame", ["Player1"])
	Player2Button.connect("pressed", self, "startGame", ["Player2"])
	Player3Button.connect("pressed", self, "startGame", ["Player3"])
	pass

func startGame(playerId):
	globals.set_current_player(playerId)
	get_tree().change_scene("res://src/game_manager/game_manager.tscn")
	pass
