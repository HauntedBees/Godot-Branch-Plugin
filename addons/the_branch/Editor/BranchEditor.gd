tool
class_name BranchEditor
extends Control

signal view_source

onready var graph:BGraphEdit = $MainView/GraphEdit
onready var save_button := $MainView/Buttons/InnerContainer/SaveButton
onready var save_template_button := $MainView/Buttons/SaveTemplateButton
onready var save_template_popup := $MainView/TemplateDialog
onready var save_template_name := $MainView/TemplateDialog/VBoxContainer/NameGroup/TemplateName
onready var save_template_group := $MainView/TemplateDialog/VBoxContainer/GroupGroup/GroupName
onready var template_button := $MainView/Buttons/InnerContainer/Template

onready var no_selection_message := $NoSelectionMessage
onready var add_new_message := $AddNewMessage
onready var main_view := $MainView
onready var source_popup := $ViewSourceError
onready var source_error := $ViewSourceError/VSMessage

var active_branch:BranchController
var file_dialog:FileDialog

func _ready():
	_set_up_file_dialog()
	set_up_branch(null)
	load_templates()

func _set_up_file_dialog():
	file_dialog = FileDialog.new()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.set_filters(PoolStringArray(["*.json ; Branch JSON Files"]))
	file_dialog.connect("file_selected", self, "_on_file_saved")
	add_child(file_dialog)
func _open_file_dialog(mode:int):
	file_dialog.mode = mode
	file_dialog.popup_centered_ratio()
func _on_file_saved(path:String):
	if path == null || path == "" || path.find("res://") != 0: return
	got_file_path(path)

func _on_OpenBranchButton_pressed(): _open_file_dialog(FileDialog.MODE_OPEN_FILE)
func _on_NewBranchButton_pressed(): _open_file_dialog(FileDialog.MODE_SAVE_FILE)
func _on_CreateNewButton_pressed(): _open_file_dialog(FileDialog.MODE_SAVE_FILE)
func got_file_path(path:String):
	if active_branch == null:
		active_branch = BranchController.new()
		active_branch.not_in_scene = true
	active_branch.file_path = path
	set_up_branch(active_branch)
	_on_save()

func set_up_branch(branch:BranchController):
	if graph == null || !graph.is_inside_tree(): return
	graph.clear()
	var has_loaded_data := false
	if branch == null:
		no_selection_message.visible = true
		add_new_message.visible = false
		main_view.visible = false
	else:
		no_selection_message.visible = false
		if branch.file_path == "":
			add_new_message.visible = true
			main_view.visible = false
		else:
			add_new_message.visible = false
			main_view.visible = true
			has_loaded_data = _open_file(branch.file_path)
	active_branch = branch
	if !has_loaded_data:
		for c in graph.get_children():
			if c is BaseBNode: graph.remove_child(c)
		var sn:BStartNode = preload("res://addons/the_branch/Nodes/BStartNode.gd").new()
		graph.add_node(sn, true)
	save_button.text = "Save"
func _open_file(tree_path:String) -> bool:
	var f := File.new()
	var file_open := f.open(tree_path, File.READ)
	var json_string := f.get_as_text() if file_open == OK else ""
	f.close()
	if json_string == "": return false
	var json:Array = parse_json(json_string)
	if json.size() == 0: return false
	graph.clear()
	for c in json:
		if c.has("is_connection_list"):
			graph.zoom = c["zoom"]
			graph.scroll_offset = Vector2(c["offset_x"], c["offset_y"])
			for cn in c["connections"]:
				graph.connect_dictionary(cn)
		else: graph.restore_bnode_from_dictionary(c)
	return true

func _on_change_made(): save_button.text = "Save (*)"
func _on_save():
	if active_branch == null || active_branch.file_path == "": return
	var res := graph.get_save_data()
	var f := File.new()
	f.open(active_branch.file_path, File.WRITE)
	f.store_string(to_json(res))
	f.close()
	save_button.text = "Save"

func _on_bnode_selected():
	save_template_button.disabled = false
	save_template_popup.visible = false
func _on_bnode_unselected():
	save_template_button.disabled = true
	save_template_popup.visible = false
func _on_SaveTemplateButton_pressed():
	save_template_name.text = ""
	save_template_group.text = ""
	save_template_popup.popup()
	graph.set_selected(graph.selected_node)
func _on_TemplateDialog_confirmed(): graph.save_template(save_template_name.text, save_template_group.text)
func _on_refresh_templates():
	var popup:PopupMenu = template_button.get_popup()
	popup.clear()
	var submenus := {}
	for ut in graph.user_templates:
		if ut["group"] == "":
			popup.add_item(ut["name"])
		else:
			if submenus.has(ut["group"]):
				submenus[ut["group"]].add_item(ut["name"])
			else:
				var submenu := PopupMenu.new()
				submenu.set_name(ut["group"])
				submenu.add_item(ut["name"])
				submenus[ut["group"]] = submenu
	for k in submenus.keys():
		popup.add_submenu_item(k, k)
		popup.add_child(submenus[k])
		submenus[k].connect("index_pressed", self, "_on_add_new_node_from_template_group", [submenus[k]])
func _on_add_new_node_from_template_group(idx:int, submenu:PopupMenu):
	_on_add_new_node_from_template(submenu.get_item_text(idx))
func _on_add_new_node_from_template(type:String):
	var template_dict:Dictionary = {}
	for d in graph.user_templates:
		if d["name"] == type:
			template_dict = d["template"]
			break
	if !template_dict.has("node_name"): return
	graph.restore_bnode_from_dictionary(template_dict, true)
func load_templates():
	var f := File.new()
	var opened := f.open("res://branch_templates.json", File.READ)
	if opened != OK: return
	var tmps := f.get_as_text()
	f.close()
	graph.user_templates = parse_json(tmps)
	_on_refresh_templates() 

func _on_view_source(func_info:Dictionary, is_bool:bool):
	if active_branch.not_in_scene:
		source_error.text = "To view the source of a function, this Branch JSON file must be attached to a BranchController node. Please select a BranchController node from the Scene Tab and edit this Branch JSON file from there."
		source_popup.popup_centered()
	else: emit_signal("view_source", func_info, is_bool)
func display_view_source_error(msg:String):
	source_error.text = msg
	source_popup.popup_centered()
