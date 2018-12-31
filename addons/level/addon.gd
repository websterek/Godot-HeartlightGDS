tool
extends EditorPlugin

# Addon content
var dock = preload("res://addons/level/level.tscn").instance()
var scene

# # # # # # # # # # # # # # # # # # # #
# # #      ROSHAMBO  MANAGER      # # #
# # # # # # # # # # # # # # # # # # # #
func _enter_tree():
	self.connect("scene_changed", self, "SceneChanged")
	dock.get_node("box/sprite_corrector").connect("pressed", self, "sprite_corrector")
	dock.get_node("box/lvl_fin").connect("pressed", self, "level_finalise")
	dock.get_node("box/lvl_edit").connect("pressed", self, "level_edit")
	dock.get_node("box/lvl_sanity").connect("pressed", self, "level_sanity")
	
	dock.get_node("sanity_dialog").connect("confirmed", self, "level_sanity_ok")

	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	if dock:
		dock.queue_free()


func sprite_corrector():
	var tile_sets = [scene.get_node("tile_back").get_tileset(), scene.get_node("tile_decal").get_tileset(), scene.get_node("tile_front").get_tileset(), scene.get_node("tile_objects").get_tileset()]
	for tile_set in tile_sets:
		var tile_ids = tile_set.get_tiles_ids()
		for id in tile_ids:
			var region_x = tile_set.tile_get_region(id).size.x
			var region_y = tile_set.tile_get_region(id).size.y
			print(region_y)
			tile_set.tile_set_texture_offset(id, Vector2( (128 - region_x)/2, (128 - region_y)/2) )
			tile_set.set(str(id) + "/shape_offset", Vector2(64, 64))


func level_finalise():
	var dir = Directory.new()
	var current = scene.get_filename()
	get_editor_interface().save_scene()
	dir.copy(current, 'res://addons/level/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]))
	
	var tile_objects = scene.get_node("tile_objects")
	var objects = { 0: load("res://src/components/baloon/baloon.tscn"),
					4: load("res://src/components/player/player_spawn_point.tscn"),
					1: load("res://src/components/grenade/grenade.tscn"),
					2: load("res://src/components/heart/heart.tscn"),
					3: load("res://src/components/rock/rock.tscn"),
					5: load("res://src/components/door/door_h.tscn"),
					6: load("res://src/components/door/door_v.tscn") }

	for object in objects:
		for tile in tile_objects.get_used_cells_by_id(object):
			var pos = (tile * 128) + Vector2(64, 64)
			var ins = objects[object].instance()
			scene.add_child(ins)
			ins.set_owner(scene)
			ins.set_position(pos)
	
	scene.get_node("tile_objects").free()
	
	get_editor_interface().save_scene()
	dock.get_node("finalise_warning").popup_centered()
	enabler()


func level_edit():
	var dir = Directory.new()
	var current = scene.get_filename()
	dir.copy('res://addons/level/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]), current)
	dir.rename('res://addons/level/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]),'res://addons/level/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]) + '.bac')

	get_editor_interface().reload_scene_from_path(current)


func SceneChanged(scene_root):
	scene = scene_root
	enabler()


func enabler():
	var dir = Directory.new()
	var current = scene.get_filename().split("/")[-1]
	print(current)
	if !current.split("_")[0] == "lvl":
		dock.get_node('box/lvl_fin').set_disabled(true)
		dock.get_node('box/lvl_edit').set_disabled(true)
		dock.get_node('box/lvl_sanity').set_disabled(true)
		dock.get_node('box/sprite_corrector').set_disabled(true)
		dock.get_node('box/HBoxContainer/mode').set_text("no level selected")
		dock.get_node('box/HBoxContainer/mode').set_modulate(Color(1, 0, 0))
	else:
		if dir.file_exists('res://addons/level/scenes_bac/' + str(scene.get_filename().split('/', false)[-1])):
			dock.get_node('box/lvl_fin').set_disabled(true)
			dock.get_node('box/lvl_edit').set_disabled(false)
			dock.get_node('box/lvl_sanity').set_disabled(true)
			dock.get_node('box/sprite_corrector').set_disabled(true)
			dock.get_node('box/HBoxContainer/mode').set_text("finalise mode")
			dock.get_node('box/HBoxContainer/mode').set_modulate(Color(0, 0, 1))
		else:
			dock.get_node('box/lvl_fin').set_disabled(false)
			dock.get_node('box/lvl_edit').set_disabled(true)
			dock.get_node('box/lvl_sanity').set_disabled(false)
			dock.get_node('box/sprite_corrector').set_disabled(false)
			dock.get_node('box/HBoxContainer/mode').set_text("edit mode")
			dock.get_node('box/HBoxContainer/mode').set_modulate(Color(0, 1, 0))

func level_sanity():
	var sanity = dock.get_node("sanity_dialog")
	sanity.popup_centered()
	
	sanity.get_node("VBoxContainer/Tree").clear()
	
	var root = sanity.get_node("VBoxContainer/Tree").create_item()
	var problems = sanity.get_node("VBoxContainer/Tree").create_item(root)
	problems.set_text(0, "")
	
	# position and unkown nodes
	var tile_ = []
	for node in scene.get_children():
		if node.get_class() == "TileMap" and node.get_name().split("_")[0] == "tile":
			tile_.append(node.get_name())
			if node.get_position() != Vector2(0, 0):
				sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, node.get_name() + " wrong position")
		if !["tile_back", "tile_decal", "tile_front", "tile_objects"].has(node.get_name()):
			sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, node.get_name() + " unkown node")
	
	if !tile_.has("tile_back"):
		sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, "tile_back is missing!!!")
	if !tile_.has("tile_decal"):
		sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, "tile_decal is missing!!!")
	if !tile_.has("tile_front"):
		sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, "tile_front is missing!!!")
	if !tile_.has("tile_objects"):
		sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, "tile_objects is missing!!!")
	
	# overlapping nodes
	var over = 0
	if tile_.has("tile_front") and tile_.has("tile_objects"):
		for cell in scene.get_node("tile_objects").get_used_cells():
			if scene.get_node("tile_front").get_cellv(cell) != -1:
				over += 1
	if over > 0:
		sanity.get_node("VBoxContainer/Tree").create_item(problems).set_text(0, "overlapping tiles: " + str(over))


func level_sanity_ok():
	pass
