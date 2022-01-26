extends Node2D
export(float) var player_speed := 200.0
onready var player := $Player
onready var dialog_box := $Dialog
onready var dialog_speaker := $Dialog/Panel/Speaker
onready var dialog_text := $Dialog/Text
onready var dialog_choices := $Dialog/Choices

var player_right := true
var player_moving := false
var player_touching:NPC = null
var player_in_dialog := false
var player_in_dog_yard := false

var son_found_state := 0
var has_dog := false

func _input(event:InputEvent):
	if !(event is InputEventKey): return
	if !event.is_action_pressed("ui_accept"): return
	if player_touching == null: return
	player_touching.talk()

func _physics_process(delta:float):
	var player_move := Vector2.ZERO
	if !player_in_dialog:
		if Input.is_action_pressed("ui_up"): player_move.y -= 1
		elif Input.is_action_pressed("ui_down"): player_move.y += 1
		if Input.is_action_pressed("ui_left"): player_move.x -= 1
		elif Input.is_action_pressed("ui_right"): player_move.x += 1
	player_moving = player_move.length() > 0
	if player_moving:
		if player_right && player_move.x < 0:
			player.scale.x *= -1
			player_right = false
		elif !player_right && player_move.x > 0:
			player.scale.x *= -1
			player_right = true
		player.transform.origin += player_move.normalized() * delta * player_speed

func _on_PlayerArea_entered(area:Area2D):
	if area.name == "DogRange": return
	player_touching = area.get_parent()
func _on_PlayerArea_exited(area:Area2D):
	if area.name == "DogRange": return
	if player_in_dog_yard && area.get_parent().name == "Dog": return
	player_touching = null

func _on_DogRange_entered(area):
	if area.name != "PlayerArea": return
	player_in_dog_yard = true
func _on_DogRange_area_exited(area):
	if area.name != "PlayerArea": return
	player_in_dog_yard = false

func _on_talk(dialog_info:Dictionary):
	if dialog_info.has("end"):
		player_in_dialog = false
		dialog_box.visible = false
		return
	player_in_dialog = true
	for c in dialog_choices.get_children(): dialog_choices.remove_child(c)
	dialog_speaker.text = dialog_info["speaker"]
	dialog_text.text = dialog_info["text"]
	dialog_box.visible = true
	for i in dialog_info["choices"].size():
		var c:String = dialog_info["choices"][i]
		var b := Button.new()
		b.text = c
		b.connect("pressed", self, "_on_dialog_choice", [i])
		dialog_choices.add_child(b)
func _on_dialog_choice(idx:int):
	if player_touching == null: return
	player_touching.make_dialog_choice(idx)
