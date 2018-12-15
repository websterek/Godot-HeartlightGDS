extends Node

var tictoc = 0
var timer = 0
var delay = 0

const tile_size = Vector2(128, 128)

var tile_typ = {
	"grass": range(0, 10),
	"block": range(10, 21),
	"wall": range(21, 32)
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