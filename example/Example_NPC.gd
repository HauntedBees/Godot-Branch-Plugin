class_name NPC
extends AnimatedSprite
signal talk(dialog_info)
export(float) var move_time := 1.0
export(bool) var talks_with_move_tree := false
onready var tween := $Tween
onready var home_position := transform.origin
onready var parent = get_parent()
var move_tree:BranchController = null
var talk_tree:BranchController = null

func _ready():
	for c in get_children():
		if c is BranchController:
			if c.name == "Move":
				move_tree = c
				move_tree.reset(false)
			elif c.name == "Talk":
				talk_tree = c
				talk_tree.reset(false)

func _process(_delta):
	if tween.is_active(): return
	if move_tree != null:
		if talks_with_move_tree && parent.player_in_dialog: return
		move_tree.step()
		var potential_dialog:Dictionary = move_tree.get_dialog_info()
		if !potential_dialog.has("error"):
			emit_signal("talk", potential_dialog)

func talk():
	var talker = move_tree if talks_with_move_tree else talk_tree
	if talker == null: return
	if talker.is_complete(): talker.reset(false)
	emit_signal("talk", talker.get_next_dialog(true))
func make_dialog_choice(idx:int):
	var talker = move_tree if talks_with_move_tree else talk_tree
	if talker == null: return
	emit_signal("talk", talker.make_dialog_choice(idx, true))

func in_dog_range() -> bool: return parent.player_in_dog_yard

func walk_dir(x:float, y:float):
	tween.interpolate_property(self, "position", transform.origin, transform.origin + Vector2(x, y), move_time)
	tween.start()

func sleep(ms:int):
	tween.interpolate_property(self, "position", transform.origin, transform.origin, ms / 1000.0)
	tween.start()

func go_home():
	tween.interpolate_property(self, "position", transform.origin, home_position, move_time * 3.0)
	tween.start()

func dog_attack(): parent.player_touching = self

func change_animation(anim:String): animation = anim

func player_back_away():
	tween.interpolate_property(parent.player, "position", parent.player.transform.origin, Vector2(370, 310), 1.0)
	tween.start()

func move_to_player():
	tween.interpolate_property(self, "position", transform.origin, parent.player.transform.origin, move_time)
	tween.start()
