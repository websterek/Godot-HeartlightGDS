extends Node

var additional = []



func _ready():
	for child in $additional.get_children():
		additional.append(child)

func _process(delta):
	randomize()
	