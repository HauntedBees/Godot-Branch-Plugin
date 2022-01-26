tool
class_name BBoolFunction
extends BaseBNode

func display_name() -> String: return "Boolean Function"
func hint() -> String: return "Evaluates a bool function on the parent node and then advances based on the result."

var function:BInnerFunction

func addtl_save(d:Dictionary) -> Dictionary:
	d["type"] = "BBoolFunction"
	d["func"] = function.get_as_dictionary()
	return d
func addtl_restore(d:Dictionary):
	function.restore_from_dictionary(d["func"])

func _ready():
	function = BInnerFunction.new()
	function.allow_delete = false
	function.connect("view_source", self, "_on_view_source", [true])
	add_child(function)
	set_slot(0, true, 0, SLOT_COLOR, false, 0, SLOT_COLOR)
	add_child(separator())
	
	var true_label := Label.new()
	true_label.align = Label.ALIGN_RIGHT
	true_label.text = "true"
	add_child(true_label)
	set_slot(2, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	add_child(separator())
	
	var false_label := Label.new()
	false_label.align = Label.ALIGN_RIGHT
	false_label.text = "false"
	add_child(false_label)
	set_slot(4, false, 0, SLOT_COLOR, true, 0, SLOT_COLOR)
	add_child(separator())
