tool
class_name BCommentNode
extends BaseBNode

func display_name() -> String: return "Comment"
func hint() -> String: return "Just a little comment. Does not affect anything. Just for notes."

var text_edit:TextEdit
var text := ""

func addtl_save(dict:Dictionary) -> Dictionary:
	dict["type"] = "BCommentNode"
	dict["text"] = text
	return dict
func addtl_restore(d:Dictionary):
	text = d["text"]
	text_edit.text = text

func _ready():
	text_edit = TextEdit.new()
	text_edit.text = text
	text_edit.wrap_enabled = true
	text_edit.connect("text_changed", self, "_on_text_change")
	text_edit.rect_min_size = Vector2(150, 100)
	text_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	text_edit.size_flags_vertical = SIZE_EXPAND_FILL
	comment = true
	add_child(text_edit)

func _on_text_change():
	text = text_edit.text
	emit_signal("change_made")
