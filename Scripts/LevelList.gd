extends ScrollContainer

export(PackedScene) var level_button: PackedScene

var buttons: = []

onready var _Grid = $GridContainer

func _ready() -> void:
	for level_id in Global.levels.size():
		var button = level_button.instance()
		button.text = "Level {0}".format([level_id])
		button.connect("pressed", Global, "goto_level", [level_id])
		
		buttons.append(button)
		_Grid.add_child(button)
	
	for i in buttons.size():
		if i <= Global.max_unlocked_level:
			if i < Global.max_unlocked_level:
				buttons[i].set_focus_neighbour(MARGIN_RIGHT, buttons[i+1].get_path())
			elif i == Global.max_unlocked_level:
				buttons[i].set_focus_neighbour(MARGIN_RIGHT, buttons[i].get_path())
			if i > 0:
				buttons[i].set_focus_neighbour(MARGIN_LEFT, buttons[i-1].get_path())
		else:
			buttons[i].disabled = true
			buttons[i].set_focus_mode(Control.FOCUS_NONE)
	
	if buttons.size() > 0:
		buttons[0].grab_focus()
