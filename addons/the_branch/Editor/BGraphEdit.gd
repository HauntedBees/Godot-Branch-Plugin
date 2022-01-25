class_name BGraphEdit
extends GraphEdit

signal change_made

const NODE_TYPES := {
	"Function Call": preload("res://addons/the_branch/Nodes/BFunctionCall.gd"),
	"Function Sequence": preload("res://addons/the_branch/Nodes/BFunctionSequence.gd"),
	"Boolean Function": preload("res://addons/the_branch/Nodes/BBoolFunction.gd"),
	"Boolean Sequence": preload("res://addons/the_branch/Nodes/BBoolSequence.gd"),
	"Dialog": preload("res://addons/the_branch/Nodes/BDialog.gd"),
	"Dialog Choice": preload("res://addons/the_branch/Nodes/BDialogChoice.gd")
}

var selected_node:BaseBNode

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
	# TODO: show save template stuff
	# TODO: hide if shitty node
	selected_node = node
func _on_node_unselected(node:GraphNode):
	#TODO: hide save template stuff
	if selected_node == node: selected_node = null

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
