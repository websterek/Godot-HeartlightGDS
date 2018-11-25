extends Node

const tile_size = Vector2(128, 128)

const tile_typ = {
	"grass": [1], 
	"block": [0]
}

var currentPlayer = null

func set_current_player(playerId):
	currentPlayer = playerId	
	print("Current player set to: " + playerId)
	
func get_current_player():
	print("Current player is: " + currentPlayer)
	return currentPlayer
