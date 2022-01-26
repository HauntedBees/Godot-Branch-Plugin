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
	branch_editor.connect("view_source", self, "_go_to_source")
	editor_selection.connect("selection_changed", self, "_on_selection_changed")
	add_to_group("graph_editor_parent")
	make_visible(false)

func _exit_tree():
	if branch_editor: branch_editor.queue_free()
	editor_selection.disconnect("selection_changed", self, "_on_selection_changed")
	remove_from_group("graph_editor_parent")
	remove_custom_type("BranchController")

func has_main_screen() -> bool: return true
func make_visible(visible:bool): if branch_editor: branch_editor.visible = visible
func handles(obj): return obj is branch_controller_script 
func get_plugin_name(): return "Branch Editor"
func get_plugin_icon(): return get_editor_interface().get_base_control().get_icon("Tree", "EditorIcons")

func _on_selection_changed():
	var n = editor_selection.get_selected_nodes()
	if branch_editor == null: return
	elif n.size() == 1 && n[0] is BranchController: branch_editor.set_up_branch(n[0])
	else: branch_editor.set_up_branch(null)

func _go_to_source(func_info:Dictionary, is_bool:bool):
	var n = editor_selection.get_selected_nodes()
	if n.size() != 1 || !(n[0] is BranchController): return
	var parent:Node = (n[0] as BranchController).get_parent()
	if parent == null:
		branch_editor.display_view_source_error("The BranchController must be the child of some other node to view its source.")
		return
	var script:Script = parent.get_script()
	if script == null:
		branch_editor.display_view_source_error("No script file is present on %s." % parent.name)
		return
	var code := script.source_code.split("\n")
	for line_no in code.size():
		var line:String = code[line_no]
		if line.find("func %s" % func_info["name"]) == 0:
			get_editor_interface().set_main_screen_editor("Script")
			get_editor_interface().edit_script(script, line_no + 1)
			return
	print("Function %s not found; creating skeleton." % func_info["name"])
	var params := []
	for idx in func_info["params"].size():
		var p:Dictionary = func_info["params"][idx]
		var type_str := ""
		match p["type"]:
			0: type_str = ":String"
			1: type_str = ":int"
			2: type_str = ":float"
			3: type_str = ":bool"
			4: type_str = ""
		params.append("%s%s" % [_clean_param_name(p["name"], idx), type_str])
	var new_line:String = "func %s(%s)%s:\n\treturn true # TODO: create function" % [
		func_info["name"],
		PoolStringArray(params).join(", "),
		" -> bool" if is_bool else ""]
	var new_source:String = "%s\n%s" % [script.source_code, new_line]

	var open_files:Array = get_editor_interface().get_script_editor().get_open_scripts()
	for o in open_files:
		if o.resource_path == script.resource_path:
			print("Cannot create skeleton as script is currently open.")
			get_editor_interface().set_main_screen_editor("Script")
			get_editor_interface().edit_script(script, code.size())
			return

	var f := File.new()
	var opened := f.open(script.resource_path, File.WRITE)
	if opened != OK:
		branch_editor.display_view_source_error("Unable to write to %s (error code %s)." % [script.resource_path, opened])
		return
	f.store_string(new_source)
	f.close()

	get_editor_interface().set_main_screen_editor("Script")
	get_editor_interface().edit_script(script, code.size() + 1)
func _clean_param_name(param:String, idx:int) -> String:
	if param == "Value": return ("arg%s" % idx)
	return param.to_lower().replace(" ", "_")
