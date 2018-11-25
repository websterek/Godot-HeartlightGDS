extends Node

const tile_size = Vector2(128, 128)

const tile_typ = {
	"grass": [1], 
	"block": [0]
}

var current_player = null

func set_current_player(playerId):
	current_player = playerId	
	print("Current player set to: " + playerId)
	
func get_current_player():
	print("Current player is: " + current_player) 
	return current_player
