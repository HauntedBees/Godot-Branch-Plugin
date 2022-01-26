tool
extends EditorPlugin

var branch_controller_script := preload("res://addons/the_branch/BranchController.gd")
var editor_viewport := get_editor_interface().get_editor_viewport()
var editor_selection := get_editor_interface().get_selection()
var branch_editor:BranchEditor

func _enter_tree():
	# Add "BranchController" custom type
	add_custom_type("BranchController", "Node", branch_controller_script, get_editor_interface().get_base_control().get_icon("Tree", "EditorIcons"))
	# Add the Branch Editor to Godot
	branch_editor = preload("res://addons/the_branch/Editor/BranchEditor.tscn").instance()
	editor_viewport.add_child(branch_editor)
	branch_editor.connect("open_file_dialog", self, "_open_file_dialog")
	make_visible(false)

func _exit_tree():
	if branch_editor: branch_editor.queue_free()
	remove_custom_type("BranchController")

func has_main_screen() -> bool: return true
func make_visible(visible:bool): if branch_editor: branch_editor.visible = visible
func handles(obj): return obj is branch_controller_script 
func get_plugin_name(): return "Branch Editor"
func get_plugin_icon(): return get_editor_interface().get_base_control().get_icon("Tree", "EditorIcons")
