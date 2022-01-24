tool
class_name BChoice
extends PanelContainer

enum { ALWAYS_SHOW, FUNCTION_CALL, VARIABLE_COMPARISON }

var text_node:BDeleteInput
var options_node:OptionButton

var text := "" setget set_text
var display_type := ALWAYS_SHOW setget set_display_type

func _ready():
	text_node = BDeleteInput.new()
	text_node.text = text
	text_node.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(text_node)
	
	options_node = OptionButton.new()
	options_node.add_item("Always Show")
	options_node.add_item("Function Call")
	options_node.add_item("Variable Comparison")
	options_node.select(display_type)
	options_node.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(options_node)
	
	

func set_text(s:String):
	text = s
	if text_node != null: text_node.text = s
func set_display_type(i:int):
	display_type = i
	if options_node != null: options_node.select(i)
