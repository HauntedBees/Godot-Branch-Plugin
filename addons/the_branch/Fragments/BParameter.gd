tool
class_name BParameter
extends HBoxContainer

signal change_made
signal delete_param

enum {STRING, INT, FLOAT, BOOL, VAR}

var field_label:Label
var text_edit:LineEdit
var num_edit:SpinBox
var bool_edit:CheckBox
var edit_popup:BParameterEdit

var field_name:String = "Parameter"
var field_type:int = STRING

func _ready():
	var delete_button := Button.new()
	delete_button.icon = preload("res://addons/the_branch/Icons/Remove.svg")
	delete_button.hint_tooltip = "Delete this parameter."
	delete_button.connect("pressed", self, "_on_delete_param")
	add_child(delete_button)
	
	var edit_button := Button.new()
	edit_button.icon = preload("res://addons/the_branch/Icons/Edit.svg")
	edit_button.hint_tooltip = "Edit this parameter's metadata."
	edit_button.connect("pressed", self, "_edit_metadata")
	add_child(edit_button)
	
	field_label = Label.new()
	add_child(field_label)
	
	text_edit = LineEdit.new()
	text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	text_edit.connect("text_changed", self, "_on_edit_value")
	add_child(text_edit)
	
	num_edit = SpinBox.new()
	num_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	num_edit.allow_greater = true
	num_edit.allow_lesser = true
	num_edit.connect("value_changed", self, "_on_edit_value")
	add_child(num_edit)
	
	bool_edit = CheckBox.new()
	bool_edit.connect("toggled", self, "_on_edit_value")
	add_child(bool_edit)
	
	edit_popup = BParameterEdit.new()
	edit_popup.connect("save", self, "_on_metadata_save")
	add_child(edit_popup)
	
	_toggle_field_display()

func _toggle_field_display():
	field_label.text = "%s:" % field_name
	field_label.visible = !(field_type == STRING || field_type == VAR)
	
	text_edit.placeholder_text = field_name
	text_edit.visible = field_type == STRING || field_type == VAR
	
	num_edit.step = 1 if field_type == INT else 0
	num_edit.visible = field_type == INT || field_type == FLOAT
	
	bool_edit.visible = field_type == BOOL
	
	edit_popup.param_name = field_name
	edit_popup.param_type = field_type

func get_as_dict() -> Dictionary:
	return {
		"name": field_name,
		"type": field_type,
		"value": get_value()
	}

func get_value():
	match field_type:
		STRING, VAR: return text_edit.text
		INT: return int(num_edit.value)
		FLOAT: return num_edit.value
		BOOL: return bool_edit.pressed
func set_value(i):
	match field_type:
		STRING, VAR: text_edit.text = i
		INT, FLOAT: num_edit.value = i
		BOOL: bool_edit.pressed = i
	_toggle_field_display()

func _on_edit_value(_v): emit_signal("change_made")
func _on_delete_param(): emit_signal("delete_param")

func _edit_metadata(): edit_popup.popup_centered()
func _on_metadata_save():
	field_name = edit_popup.param_name
	field_type = edit_popup.param_type
	_toggle_field_display()
	edit_popup.visible = false
	emit_signal("change_made")
