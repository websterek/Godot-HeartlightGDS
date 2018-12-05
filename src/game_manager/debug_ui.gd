extends Node2D

func _draw():
	draw_cross(Vector2(0, 0), "purple")
	draw_cross(Vector2(1, 1), "limegreen")
	draw_cross(Vector2(2, 2), "purple")
	draw_cross(Vector2(3, 3), "limegreen")
	draw_cross(Vector2(4, 4), "white")

func draw_cross(position, color):
	var tile_size_x =  globals.tile_size.x
	var tile_size_y =  globals.tile_size.y
	var center = Vector2(position.x * tile_size_x, position.y * tile_size_y)
	draw_line(
		Vector2(center.x - 10, center.y - 10), 
		Vector2(center.x + 10, center.y + 10),
		ColorN(color, 1)
	)
	draw_line(
		Vector2(center.x - 10, center.y + 10),
		Vector2(center.x + 10, center.y - 10), 
		ColorN(color, 1)
	)