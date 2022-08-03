extends Node2D

var Buttons: Array
var is_popup_opened: bool

enum {OPEN, CLOSE}

func _ready():
	is_popup_opened = false
	
	if OS.has_feature("HTML5"):
		$MainUI/Menu/QuitButton.hide()
	
#	var grid_columns = LevelButtonsContainer.columns
#	var levels_number = Global.Levels.size()
#
#	for i in range(levels_number):
#		var new_button = Button.new()
#		new_button.rect_min_size = Vector2(80, 40)
#		new_button.text = "Level "+str(i)
#		new_button.connect("pressed", self, "_on_Level_pressed", [i])
#		LevelButtonsContainer.add_child(new_button)
#		Buttons.append(new_button)
#
#	for i in range(Buttons.size()):
#		if i <= Global.max_unlocked_level:
#			if i < Global.max_unlocked_level:
#				Buttons[i].set_focus_neighbour(MARGIN_RIGHT, Buttons[i+1].get_path())
#			elif i == Global.max_unlocked_level:
#				Buttons[i].set_focus_neighbour(MARGIN_RIGHT, Buttons[i].get_path())
#
#			if i > 0:
#				Buttons[i].set_focus_neighbour(MARGIN_LEFT, Buttons[i-1].get_path())
#		else:
#			Buttons[i].disabled = true
#			Buttons[i].set_focus_mode(Control.FOCUS_NONE)
#	if Buttons[0] != null and not Buttons[0].disabled:
#		Buttons[0].grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not OS.has_feature("HTML5"):
		get_tree().quit()

func _on_Reset_pressed():
	Global.reset()

func _on_QuitButton_pressed():
	get_tree().quit()
