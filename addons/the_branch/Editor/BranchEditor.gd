tool
class_name BranchEditor
extends Control
signal open_file_dialog

onready var graph := $MainView/GraphEdit
var active_branch:BranchController

func _ready():
	_set_up_branch(null)

func _on_CreateNewButton_pressed(): emit_signal("open_file_dialog")
func got_file_path(path:String):
	active_branch.file_path = path

func _set_up_branch(branch:BranchController):
	_clear_graph()
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

func _clear_graph():
	graph.clear_connections()
	for g in graph.get_children():
		if g is BaseBNode: graph.remove_child(g)

func _open_file(tree_path:String) -> bool:
	var f := File.new()
	var file_open := f.open(tree_path, File.READ)
	var json_string := f.get_as_text() if file_open == OK else ""
	f.close()
	if json_string == "": return false
	var json:Array = parse_json(json_string)
	if json.size() == 0: return false
	for c in graph.get_children():
		if c is BaseBNode: graph.remove_child(c)
	for c in json:
		if c.has("is_connection_list"):
			for cn in c["connections"]:
				graph.connect_node(cn["from"], cn["from_port"], cn["to"], cn["to_port"])
		else: _restore_bnode_from_dictionary(c)
	return true
func _restore_bnode_from_dictionary(c:Dictionary) -> BaseBNode:
	var loaded_node:BaseBNode = load(c["filename"]).instance()
	_connect_and_add_bnode(loaded_node)
	loaded_node.restore(c)
	return loaded_node
func _connect_and_add_bnode(b:BaseBNode):
	# TODO: signals
	graph.add_child(b, true)
