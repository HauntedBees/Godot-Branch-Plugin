tool
class_name BParameterEdit
extends WindowDialog

signal save
var name_edit:LineEdit
var type_edit:OptionButton
var param_name:String setget set_param_name
var param_type:int setget set_param_type

func _ready():
	window_title = "Parameter Settings"
	rect_size = Vector2(200, 100)
	
	var vbox := VBoxContainer.new()
	vbox.margin_top = 10
	vbox.margin_left = 15
	vbox.rect_size = Vector2(170, 90)
	add_child(vbox)
	
	var hbox_name := HBoxContainer.new()
	hbox_name.rect_size = Vector2(150, 50)
	vbox.add_child(hbox_name)
	var label_name := Label.new()
	label_name.text = "Name:"
	hbox_name.add_child(label_name)
	name_edit = LineEdit.new()
	name_edit.text = param_name
	name_edit.rect_min_size = Vector2(120, 24)
	name_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	name_edit.connect("text_changed", self, "_on_name_change")
	hbox_name.add_child(name_edit)
	
	var hbox_type := HBoxContainer.new()
	hbox_type.rect_size = Vector2(150, 50)
	hbox_type.margin_top = 5
	hbox_type.margin_bottom = 5
	vbox.add_child(hbox_type)
	var label_type := Label.new()
	label_type.text = "Type"
	hbox_type.add_child(label_type)
	type_edit = OptionButton.new()
	type_edit.hint_tooltip = "The type of the parameter. If \"var\" is selected, then this value is treated as the name of a property on the Parent Node."
	type_edit.add_item("String")
	type_edit.add_item("int")
	type_edit.add_item("float")
	type_edit.add_item("bool")
	type_edit.add_item("var")
	type_edit.select(param_type)
	type_edit.rect_min_size = Vector2(120, 24)
	type_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	type_edit.connect("item_selected", self, "_on_type_change")
	hbox_type.add_child(type_edit)
	
	var save_button := Button.new()
	save_button.text = "Save Changes"
	save_button.size_flags_horizontal = SIZE_EXPAND_FILL
	save_button.connect("pressed", self, "_on_save")
	vbox.add_child(save_button)

func set_param_name(s:String):
	param_name = s
	if name_edit != null: name_edit.text = s
func set_param_type(i:int):
	param_type = i
	if type_edit != null: type_edit.select(i)

func _on_name_change(t:String): param_name = t
func _on_type_change(i:int): param_type = i

func _on_save(): emit_signal("save")
