extends Node

const backgroundColor = Color(0,0,0,1.0)

func _ready():
	OS.center_window()
	VisualServer.set_default_clear_color(backgroundColor)
