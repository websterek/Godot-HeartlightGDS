extends Node2D

onready var tilemap = get_node("level")

func _ready():
	pass

func calculate_bounds():
	return tilemap.calculate_bounds()