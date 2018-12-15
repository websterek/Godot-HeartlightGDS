tool
extends TileMap


func _process(delta):
	if Engine.is_editor_hint():
		set_position(Vector2(0, 0))