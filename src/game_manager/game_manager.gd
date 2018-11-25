extends Node

func instantiate_level():
	var scene = load("res://src/levels/lvl_template.tscn")
	var scene_instance = scene.instance()
	scene_instance.set_name("level")
	add_child(scene_instance)

func _ready():
	print(globals.get_current_player())
	instantiate_level()
