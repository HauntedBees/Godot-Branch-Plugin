tool
class_name BGraphEdit
extends GraphEdit

signal change_made
signal bnode_selected
signal bnode_unselected
signal refresh_templates
signal view_source(func_info, is_bool)

const NODE_TYPES := {
	"Function Call": preload("res://addons/the_branch/Nodes/BFunctionCall.gd"),
	"Function Sequence": preload("res://addons/the_branch/Nodes/BFunctionSequence.gd"),
	"Variable Assignment": preload("res://addons/the_branch/Nodes/BVarAssignment.gd"),
	"Boolean Function": preload("res://addons/the_branch/Nodes/BBoolFunction.gd"),
	"Boolean Sequence": preload("res://addons/the_branch/Nodes/BBoolSequence.gd"),
	"Random Condition": preload("res://addons/the_branch/Nodes/BRandom.gd"),
	"Variable Comparison": preload("res://addons/the_branch/Nodes/BVarComparison.gd"),
	"Dialog": preload("res://addons/the_branch/Nodes/BDialog.gd"),
	"Dialog Choice": preload("res://addons/the_branch/Nodes/BDialogChoice.gd"),
	"Restart": preload("res://addons/the_branch/Nodes/BRepeatNode.gd"),
	"End": preload("res://addons/the_branch/Nodes/BEndNode.gd"),
	"Comment": preload("res://addons/the_branch/Nodes/BCommentNode.gd")
}

var selected_node:BaseBNode
var user_templates := []
var copied_nodes := []

func get_save_data() -> Array:
	var res := []
	for c in get_children():
		if !(c is BaseBNode): continue
		res.append(c.save())
	res.append({
		"is_connection_list": true,
		"connections": get_connection_list()
	})
	return res
func clear():
	clear_connections()
	for g in get_children():
		if g is BaseBNode: remove_child(g)
func connect_dictionary(cn:Dictionary):
	connect_node(cn["from"], cn["from_port"], cn["to"], cn["to_port"])

# Adding Nodes
func add_new_node(type:String):
	if !NODE_TYPES.has(type): return
	add_node(NODE_TYPES[type].new(), true)
func add_node(b:BaseBNode, is_new:bool = false):
	b.connect("delete_slot", self, "_handle_slot_deletion")
	b.connect("insert_slot", self, "_handle_slot_insertion")
	b.connect("delete_node", self, "_handle_bnode_deletion")
	b.connect("change_made", self, "_on_change_made")
	b.connect("view_source", self, "_on_view_source")
	if is_new:
		b.offset = scroll_offset + (rect_size - b.rect_size) / 2.0
		emit_signal("change_made")
	add_child(b, true)
func restore_bnode_from_dictionary(c:Dictionary, is_new:bool = false) -> BaseBNode:
	if is_new: c["name"] = ""
	var loaded_node:BaseBNode = load("res://addons/the_branch/Nodes/%s.gd" % c["type"]).new()
	add_node(loaded_node, is_new)
	loaded_node.restore(c, !is_new)
	return loaded_node

# Node Signals
func _on_change_made(): emit_signal("change_made")
func _on_view_source(func_info, is_bool:bool): emit_signal("view_source", func_info, is_bool)

# Graph Signals
func _on_connection_request(from:String, from_port:int, to:String, to_port:int):
	if from == to: return
	var connections:Array = get_connection_list()
	for c in connections: # one from_port can't connect to two to_ports
		if c["from"] == from && c["from_port"] == from_port:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
	connect_node(from, from_port, to, to_port)
	_on_change_made()
func _on_disconnection_request(from:String, from_port:int, to:String, to_port:int):
	disconnect_node(from, from_port, to, to_port)
	_on_change_made()
func _on_node_selected(node:GraphNode):
	if !(node is BaseBNode) || node == selected_node: return
	if node is BStartNode || node is BEndNode || node is BRepeatNode: return
	selected_node = node
	emit_signal("bnode_selected")
func _on_node_unselected(node:GraphNode):
	if selected_node == node:
		emit_signal("bnode_unselected")
		selected_node = null
func _on_copy_nodes_request():
	var node_name_list := []
	copied_nodes = []
	for g in get_children():
		if g is BaseBNode && g.selected:
			var n:Dictionary = g.save()
			n["name"] = ""
			copied_nodes.append(n)
			node_name_list.append(g.name)
func _on_paste_nodes_request():
	var init_offset:Vector2 = scroll_offset + rect_size / 2.0
	var real_offset := Vector2.ZERO
	var offset_set := false
	for g in get_children():
		if g is BaseBNode && g.selected:
			g.selected = false
	for c in copied_nodes:
		var n := restore_bnode_from_dictionary(c)
		n.selected = true
		if !offset_set:
			real_offset = init_offset - n.offset
			n.offset = init_offset
			offset_set = true
		else:
			n.offset += real_offset
	_on_change_made()
func _on_delete_nodes_request():
	for g in get_children():
		if g is BaseBNode && g.selected:
			_handle_bnode_deletion(g.name)
			g.queue_free()
	_on_change_made()

# Slot Signals
## Called AFTER BNode is created
func _handle_slot_insertion(from:String, from_port:int):
	var connections:Array = get_connection_list()
	var relevant_connections := []
	for c in connections:
		if c["from"] == from && c["from_port"] >= from_port:
			disconnect_node(from, c["from_port"], c["to"], c["to_port"])
			relevant_connections.append(c)
	for c in relevant_connections:
		connect_node(from, c["from_port"] + 1, c["to"], c["to_port"])
## Called BEFORE BNode is removed
func _handle_slot_deletion(from:String, from_port:int):
	var connections:Array = get_connection_list()
	var relevant_connections := []
	for c in connections:
		if c["from"] == from && c["from_port"] >= from_port:
			disconnect_node(from, c["from_port"], c["to"], c["to_port"])
			if c["from_port"] > from_port: relevant_connections.append(c)
	for c in relevant_connections:
		connect_node(from, c["from_port"] - 1, c["to"], c["to_port"])
## Called whenever
func _handle_bnode_deletion(to:String):
	var connections:Array = get_connection_list()
	for c in connections:
		if c["to"] == to || c["from"] == to:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])

# Templates
func save_template(name:String, group:String):
	if selected_node == null: return
	if name == "": name = "Unnamed Template %s" % user_templates.size()
	var same_name := false
	for v in user_templates:
		if v["name"] == name:
			same_name = true
			break
	if same_name: name = "%s 2" % name
	user_templates.append({
		"name": name,
		"group": group,
		"template": selected_node.save()
	})
	var f := File.new()
	var opened := f.open("res://branch_templates.json", File.WRITE)
	if opened != OK:
		print("Couldn't save template!")
		return
	f.store_string(to_json(user_templates))
	f.close()
	emit_signal("refresh_templates")
