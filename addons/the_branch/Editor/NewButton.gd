tool
extends MenuButton
signal action(type)
var popup:PopupMenu = null
func _ready():
	popup = get_popup()
	popup.connect("index_pressed", self, "_on_item_pressed")
func _on_item_pressed(idx:int): emit_signal("action", popup.get_item_text(idx))
