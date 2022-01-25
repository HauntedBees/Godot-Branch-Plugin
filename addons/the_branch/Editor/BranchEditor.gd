tool
class_name BranchEditor
extends Control
signal open_file_dialog

onready var graph:BGraphEdit = $MainView/GraphEdit
onready var save_button := $MainView/Buttons/InnerContainer/SaveButton
onready var save_template_button := $MainView/Buttons/SaveTemplateButton
onready var save_template_popup := $MainView/TemplateDialog
onready var save_template_name := $MainView/TemplateDialog/VBoxContainer/NameGroup/TemplateName
onready var save_template_group := $MainView/TemplateDialog/VBoxContainer/GroupGroup/GroupName
onready var template_button := $MainView/Buttons/InnerContainer/Template
var active_branch:BranchController

func _ready():
	if true:
		var dtn := BranchController.new()
		dtn.file_path = "res://debug.json"
		_set_up_branch(dtn)
	else: _set_up_branch(null)
	load_templates()

func _on_CreateNewButton_pressed(): emit_signal("open_file_dialog")
func got_file_path(path:String):
	active_branch.file_path = path
	_set_up_branch(active_branch)
	_on_save()

func _set_up_branch(branch:BranchController):
	graph.clear()
	var has_loaded_data := false
	if branch == null:
		$NoNodeMessage.visible = true
		$AddNewMessage.visible = false
		$MainView.visible = false
	else:
		$NoNodeMessage.visible = false
		if branch.file_path == "":
			$AddNewMessage.visible = true
			$MainView.visible = false
		else:
			$AddNewMessage.visible = false
			$MainView.visible = true
			has_loaded_data = _open_file(branch.file_path)
	active_branch = branch
	if !has_loaded_data:
		for c in get_children():
			if c is BaseBNode: graph.remove_child(c)
		var sn:BStartNode = preload("res://addons/the_branch/Nodes/BStartNode.gd").instance()
		graph.add_child(sn)
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
	if !template_dict.has("name"): return
	graph.restore_bnode_from_dictionary(template_dict, true)
func load_templates():
	var f := File.new()
	var opened := f.open("res://addons/the_branch/templates.json", File.READ)
	if opened != OK: return
	var tmps := f.get_as_text()
	f.close()
	graph.user_templates = parse_json(tmps)
	_on_refresh_templates() 
