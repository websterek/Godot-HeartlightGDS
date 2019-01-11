extends Node

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
	"grass": range(0, 10),
	"block": range(10, 20),
	"wall": range(21, 32)
}

var current_player = null
var config = ConfigFile.new()

func set_current_player(playerId):
	current_player = playerId	
	print("Current player set to: " + playerId)
	
func get_current_player():
	print("Current player is: " + current_player) 
	return current_player

func _ready():
	var config_file_path = "res://settings.cfg"
	config.load(config_file_path)	
	set_config_values()
	config.save(config_file_path)

func set_config_values():
	if !config.has_section_key("base", "first_level_filename"):
		config.set_value("base", "first_level_filename", "lvl_001")

	if !config.has_section_key("player", "movement_duration"):
		config.set_value("player", "movement_duration", 0.15)

	if !config.has_section_key("player", "movement_delay"):
		config.set_value("player", "movement_delay", 0.03)

	if !config.has_section_key("player", "volume_db_grass"):
		config.set_value("player", "volume_db_grass", -24)

	if !config.has_section_key("player", "volume_db_nograss"):
		config.set_value("player", "volume_db_nograss", -24)
		
	if !config.has_section_key("dynamic_objects", "default_movement_duration"):
		config.set_value("dynamic_objects", "default_movement_duration", 0.2)
		
	if !config.has_section_key("owl", "movement_duration"):
		config.set_value("owl", "movement_duration", 0.15)
		
	if !config.has_section_key("owl", "movement_delay"):
		config.set_value("owl", "movement_delay", 0.15)
		
	if !config.has_section_key("rock", "movement_duration"):
		config.set_value("rock", "movement_duration", 0.15)
		
	if !config.has_section_key("rock", "volume_db"):
		config.set_value("rock", "volume_db", -8)
		
	if !config.has_section_key("door", "volume_db"):
		config.set_value("door", "volume_db", -12)
		
	if !config.has_section_key("explosion", "volume_db"):
		config.set_value("explosion", "volume_db", -8)
		
	if !config.has_section_key("heart", "volume_db"):
		config.set_value("heart", "volume_db", -4)
		
	if !config.has_section_key("music", "volume_db_game"):
		config.set_value("music", "volume_db_game", -4)
		
	if !config.has_section_key("music", "volume_db_menu"):
		config.set_value("music", "volume_db_menu", -4)
