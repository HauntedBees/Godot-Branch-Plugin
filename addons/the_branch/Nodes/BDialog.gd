tool
class_name BDialog
extends BaseBNode

func display_name() -> String: return "Dialog"
func hint() -> String: return "This node is for entering text that will be displayed to the player."

var speaker_node:LineEdit
var body_node:TextEdit

var speaker := "" setget set_speaker
var value := "" setget set_value
var param_info:BParamHandler

func set_speaker(s:String):
	speaker = s
	if speaker_node != null: speaker_node.text = s
func _on_speaker_change(s:String):
	speaker = s
	emit_signal("change_made")
func set_value(s:String):
	value = s
	if body_node != null: body_node.text = s
func _on_value_change(t:TextEdit):
	value = t.text
	emit_signal("change_made")

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BDialog"
	d["text"] = value
	d["speaker"] = speaker
	d["params"] = param_info.get_params_dict_array()
	return d
func addtl_restore(d:Dictionary):
	set_value(d["text"])
	set_speaker(d["speaker"])
	param_info.restore_params_from_dict_array(d["params"], param_container, self)

func _ready():
	speaker_node = LineEdit.new()
	speaker_node.placeholder_text = "Speaker (optional)"
	speaker_node.hint_tooltip = "Specify a speaker name for the dialog."
	speaker_node.size_flags_horizontal = SIZE_EXPAND_FILL
	speaker_node.text = speaker
	speaker_node.connect("text_changed", self, "_on_speaker_change")
	add_child(speaker_node)
	add_child(separator())
	
	body_node = TextEdit.new()
	body_node.hint_tooltip = "This node is for entering text that will be displayed to the player."
	body_node.size_flags_horizontal = SIZE_EXPAND_FILL
	body_node.size_flags_vertical = SIZE_EXPAND_FILL
	body_node.text = value
	body_node.rect_min_size = Vector2(0, 60)
	body_node.connect("text_changed", self, "_on_value_change", [body_node])
	add_child(body_node)
	add_child(separator())
	
	var param_container := VBoxContainer.new()

	param_info = BParamHandler.new()
	add_child(param_info.get_params_button(param_container, self, "Add Additional Parameter", "Add some optional metadata to this dialog node."))
	add_child(separator())
	
	param_container.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(param_container)
	
	set_slot(0, true, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
