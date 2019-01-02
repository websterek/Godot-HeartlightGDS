extends Node

var tictoc = 0
var timer = 0
var delay = 0

const tile_size = Vector2(128, 128)

var directions = {
	"TOP": Vector2(0, -tile_size.y),
	"BOTTOM": Vector2(0, tile_size.y),
	"LEFT": Vector2(-tile_size.x, 0),
	"RIGHT": Vector2(tile_size.x, 0),
	"TOP_LEFT": Vector2(-tile_size.x, -tile_size.y),
	"TOP_RIGHT": Vector2(tile_size.x, -tile_size.y),
	"BOTTOM_LEFT": Vector2(-tile_size.x, tile_size.y),
	"BOTTOM_RIGHT": Vector2(tile_size.x, tile_size.y),
}

var tile_typ = {
	"grass": range(0, 9),
	"block": range(10, 20),
	"wall": range(21, 31)
}

var current_player = null

func set_current_player(playerId):
	current_player = playerId	
	print("Current player set to: " + playerId)
	
func get_current_player():
	print("Current player is: " + current_player) 
	return current_player

func _ready():
	pass

func _physics_process(delta):
	delay += delta
	if delay > 0.025:
		tictoc_yeld()
		delay = 0

func tictoc_yeld():
	if tictoc == 2:
		tictoc = 0
	else:
		tictoc += 1