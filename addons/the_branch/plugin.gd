tool
extends EditorPlugin

var branch_controller_script := preload("res://addons/the_branch/BranchController.gd")
var editor_viewport := get_editor_interface().get_editor_viewport()
var editor_selection := get_editor_interface().get_selection()
var branch_editor:BranchEditor
var file_dialog:FileDialog

func _enter_tree():
	# Add "BranchController" custom type
	add_custom_type("BranchController", "Node", branch_controller_script, get_editor_interface().get_base_control().get_icon("Tree", "EditorIcons"))
	
	# Add the Branch Editor to Godot
	branch_editor = preload("res://addons/the_branch/Editor/BranchEditor.tscn").instance()
	editor_viewport.add_child(branch_editor)
	branch_editor.connect("open_file_dialog", self, "_open_file_dialog")
	make_visible(false)

	# Set up File Dialog
	file_dialog = FileDialog.new()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.set_filters(PoolStringArray(["*.json ; DataTree JSON Files"]))
	file_dialog.connect("file_selected", self, "on_file_saved")
	var base_control := get_editor_interface().get_base_control()
	base_control.add_child(file_dialog)

func _exit_tree():
	if branch_editor: branch_editor.queue_free()
	remove_custom_type("BranchController")

func _open_file_dialog(): file_dialog.popup_centered_ratio()
func on_file_saved(path:String):
	if path == null || path == "" || path.find("res://") != 0: return
	branch_editor.got_file_path(path)
	
func has_main_screen() -> bool: return true
func make_visible(visible:bool): if branch_editor: branch_editor.visible = visible
func handles(obj): return obj is branch_controller_script 
func get_plugin_name(): return "Branch Editor"
func get_plugin_icon(): return get_editor_interface().get_base_control().get_icon("Tree", "EditorIcons")
