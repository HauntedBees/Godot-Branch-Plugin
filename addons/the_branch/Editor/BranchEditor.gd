tool
class_name BranchEditor
extends Control
signal open_file_dialog

onready var graph:BGraphEdit = $MainView/GraphEdit
var active_branch:BranchController

func _ready():
	if true:
		var dtn := BranchController.new()
		dtn.file_path = "res://debug.json"
		_set_up_branch(dtn)
	else: _set_up_branch(null)
	# TODO: load templates

func _on_CreateNewButton_pressed(): emit_signal("open_file_dialog")
func got_file_path(path:String):
	active_branch.file_path = path
	_set_up_branch(active_branch)
	_save()

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
		pass # TODO: set up default stuff
	# TODO: set up save button
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
		else: _restore_bnode_from_dictionary(c)
	return true
func _restore_bnode_from_dictionary(c:Dictionary) -> BaseBNode:
	var loaded_node:BaseBNode = load(c["filename"]).instance()
	graph.add_node(loaded_node)
	loaded_node.restore(c)
	return loaded_node

func _on_change_made(): print("SAVED")# save_button.text = "Save (*)"

func _save():
	if active_branch == null || active_branch.file_path == "": return
	var res := graph.get_save_data()
	var f := File.new()
	f.open(active_branch.file_path, File.WRITE)
	f.store_string(to_json(res))
	f.close()
	# save_button.text = "Save"
