tool
class_name BDeleteInput
extends HBoxContainer

signal change_made(s)
signal delete

var text_edit:LineEdit
var text := "" setget set_text
var placeholder := "Value"

func _ready():
	var delete_button := Button.new()
	delete_button.icon = preload("res://addons/the_branch/Icons/Remove.svg")
	delete_button.hint_tooltip = "Delete this value."
	delete_button.connect("pressed", self, "_on_delete")
	add_child(delete_button)
	
	text_edit = LineEdit.new()
	text_edit.placeholder_text = placeholder
	text_edit.text = text
	text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	text_edit.connect("text_changed", self, "_on_edit_value")
	add_child(text_edit)

func set_text(s:String):
	text = s
	if text_edit != null: text_edit.text = s

func _on_delete(): emit_signal("delete")
func _on_edit_value(s:String):
	text = s
	emit_signal("change_made", s)
