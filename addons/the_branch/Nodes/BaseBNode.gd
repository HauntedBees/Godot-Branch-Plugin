tool
class_name BaseBNode
extends GraphNode

var separator_theme:Theme = preload("res://addons/the_branch/Editor/separator.tres")

signal change_made
signal delete_node(name)
signal insert_slot
signal delete_slot
signal view_source

const SLOT_COLOR := Color("#BD8F8F")

func allow_selection() -> bool: return true
func display_name() -> String: return ""
func hint() -> String: return ""

func _ready():
	title = display_name()
	hint_tooltip = hint()
	show_close = true
	resizable = true
	connect("close_request", self, "_on_close_request")
	connect("resize_request", self, "_on_resize_request")
	connect("dragged", self, "_on_drag_request")

func _on_view_source(func_info:Dictionary, is_bool:bool): emit_signal("view_source", func_info, is_bool)
func _on_change(): emit_signal("change_made")
func _on_change_arg(_v): emit_signal("change_made")
func _on_close_request():
	emit_signal("change_made")
	emit_signal("delete_node", name)
	queue_free()
func _on_resize_request(new_minsize:Vector2):
	rect_size = new_minsize
	emit_signal("change_made")
func _on_drag_request(from:Vector2, to:Vector2):
	emit_signal("change_made")

func save() -> Dictionary:
	var save_dict := {
		"node_name": name,
		"type": "BaseBNode",
		"pos_x": offset.x,
		"pos_y": offset.y,
		"rect_x": rect_size.x,
		"rect_y": rect_size.y
	}
	return addtl_save(save_dict)
func addtl_save(dict:Dictionary) -> Dictionary: return dict

func restore(dict:Dictionary, set_position:bool = true):
	name = dict["node_name"]
	if set_position: offset = Vector2(dict["pos_x"], dict["pos_y"])
	rect_size = Vector2(dict["rect_x"], dict["rect_y"])
	addtl_restore(dict)
func addtl_restore(dict:Dictionary): return

func separator() -> HSeparator:
	var h := HSeparator.new()
	h.theme = separator_theme
	return h
