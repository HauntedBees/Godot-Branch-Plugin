tool
class_name BTypedInput
extends HBoxContainer

signal change_made

enum {STRING, INT, FLOAT, BOOL, VAR}

var type_selector:OptionButton
var text_edit:LineEdit
var num_edit:SpinBox
var bool_edit:CheckBox

var type := STRING setget set_type
var value setget set_value, get_value

func _ready():
	text_edit = LineEdit.new()
	text_edit.placeholder_text = "Value"
	text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	text_edit.connect("text_changed", self, "_on_change")
	add_child(text_edit)
	
	num_edit = SpinBox.new()
	num_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	num_edit.allow_lesser = true
	num_edit.allow_greater = true
	num_edit.connect("value_changed", self, "_on_change")
	add_child(num_edit)
	
	bool_edit = CheckBox.new()
	bool_edit.text = "Value"
	bool_edit.connect("toggled", self, "_on_change")
	add_child(bool_edit)
	
	type_selector = OptionButton.new()
	type_selector.hint_tooltip = "The type of the variable. If \"var\" is selected, then this value is treated as the name of a property on the Parent Node."
	type_selector.add_item("String")
	type_selector.add_item("int")
	type_selector.add_item("float")
	type_selector.add_item("bool")
	type_selector.add_item("var")
	type_selector.connect("item_selected", self, "_on_type_selected")
	add_child(type_selector)
	
	set_type(type)

func _on_type_selected(t:int):
	set_type(t)
	emit_signal("change_made")
func _on_change(_v): emit_signal("change_made")

func set_type(t:int):
	type = t
	text_edit.visible = false
	num_edit.visible = false
	bool_edit.visible = false
	type_selector.select(t)
	match type:
		STRING, VAR: text_edit.visible = true
		INT:
			num_edit.visible = true
			num_edit.step = 1
		FLOAT:
			num_edit.visible = true
			num_edit.step = 0
		BOOL: bool_edit.visible = true
func set_value(v):
	match type:
		STRING, VAR: text_edit.text = v
		INT, FLOAT: num_edit.value = v
		BOOL: bool_edit.pressed = v
func get_value():
	match type:
		STRING, VAR: return text_edit.text
		INT: return int(num_edit.value)
		FLOAT: return num_edit.value
		BOOL: return bool_edit.pressed
