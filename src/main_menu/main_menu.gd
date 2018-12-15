extends Container

onready var menu_container = get_node("Container/Panel/Margins")

func _ready():
	self.rect_size = Vector2(
			ProjectSettings.get_setting("display/window/size/width"), 
			ProjectSettings.get_setting("display/window/size/height")
		)
		
func activateMenu(menuNodeName):
	for menu in menu_container.get_children():
		if menu.get_name() != menuNodeName:
			menu.visible = false
		else:
			menu.visible = true

func startGame(playerId):
	globals.set_current_player(playerId)
	get_tree().change_scene("res://src/game_manager/game_manager.tscn")

func exitGame():
	get_tree().quit()
