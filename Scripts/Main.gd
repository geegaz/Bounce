extends Node2D

var Buttons: Array
var is_popup_opened: bool

var QuitPopup: AcceptDialog

enum {OPEN, CLOSE}

func _ready():
	is_popup_opened = false
	QuitPopup = $MainUI/QuitPopup
	
	var LevelButtonsParent = $MainUI/Menu/LevelsSelection/ScrollContainer/CenterContainer/GridContainer
	var grid_columns = LevelButtonsParent.columns
	var levels_number = Global.Levels.size()
	
	for i in range(levels_number):
		var new_button = Button.new()
		new_button.rect_min_size = Vector2(80, 40)
		new_button.text = "Level "+str(i)
		new_button.connect("pressed", self, "_on_Level_pressed", [i])
		LevelButtonsParent.add_child(new_button)
		Buttons.append(new_button)
	
	for i in range(Buttons.size()):
		if i <= Global.max_unlocked_level:
			if i < Global.max_unlocked_level:
				Buttons[i].set_focus_neighbour(MARGIN_RIGHT, Buttons[i+1].get_path())
			elif i == Global.max_unlocked_level:
				Buttons[i].set_focus_neighbour(MARGIN_RIGHT, Buttons[i].get_path())
			
			if i > 0:
				Buttons[i].set_focus_neighbour(MARGIN_LEFT, Buttons[i-1].get_path())
		else:
			Buttons[i].disabled = true
			Buttons[i].set_focus_mode(Control.FOCUS_NONE)
	if Buttons[0] != null and not Buttons[0].disabled:
		Buttons[0].grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if not is_popup_opened:
			popup(OPEN)
		else:
			popup(CLOSE)

func popup(operation):
	match operation:
		OPEN:
			QuitPopup.popup_centered()
			is_popup_opened = true
		CLOSE:
			QuitPopup.hide()
			is_popup_opened = false
			if Buttons[0] != null and not Buttons[0].disabled:
				Buttons[0].grab_focus()

func _on_Level_pressed(arg):
	if arg < Global.Levels.size():
		Global.next_scene(arg)

func _on_QuitButton_pressed():
	popup(OPEN)

func _on_QuitPopup_confirmed():
	get_tree().quit()
