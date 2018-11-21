tool
extends EditorPlugin

# Addon content
var dock = preload("res://addons/level/level.tscn").instance()
var scene

# # # # # # # # # # # # # # # # # # # #
# # #      ROSHAMBO  MANAGER      # # #
# # # # # # # # # # # # # # # # # # # #
func _enter_tree():
#	self.connect("scene_changed", self, "SceneChanged")

	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	if dock:
		dock.queue_free()
#
#
#func level_finalise():
#	var dir = Directory.new()
#	var current = scene.get_filename()
#	get_editor_interface().save_scene()
#	dir.copy(current, 'res://addons/RoshamboManager/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]))
#
#	get_editor_interface().save_scene()
#	dock.get_node("finalise_warning").popup_centered()
#
#
#func level_edit():
#	var dir = Directory.new()
#	var current = scene.get_filename()
#	dir.copy('res://addons/RoshamboManager/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]), current)
#	dir.rename('res://addons/RoshamboManager/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]),'res://addons/RoshamboManager/scenes_bac/' + str(scene.get_filename().split('/', false)[-1]) + '.bac')
#
#	get_editor_interface().reload_scene_from_path(current)
#
#
#
#
#func SceneChanged(scene_root):
#	scene = scene_root
#	level_rails = scene.get_node('level_rails')
#	paths_singles = scene.get_node('paths_singles')
#	paths_special = scene.get_node('paths_special')
#	paths_rails = scene.get_node('paths_rails')
#	waves_enemies = scene.get_node('waves_enemies')
#	waves_data = scene.get_node('waves_data')
#	disabler_enabler()
