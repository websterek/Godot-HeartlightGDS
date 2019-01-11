extends StaticBody2D

onready var main_camera = get_node("/root/Root/MainCamera")

var active = false

func _ready():
	pass

func push(direction = null):
	if !active:
		active = true
		var camera_animator = main_camera.get_node("tween")
		camera_animator.connect("tween_completed", self, "_on_fade_finished", [], CONNECT_ONESHOT)
		main_camera.fade_down()

func _on_fade_finished(object, key):
	get_tree().change_scene("res://src/end_game_cutscene/end_game.tscn")