extends Node2D

export(Array, PackedScene) var Levels

var LevelButtonsParent: Control

func _ready():
	LevelButtonsParent = $Menu/LevelsSelection/ScrollContainer/CenterContainer/GridContainer
	var buttons = LevelButtonsParent.get_children()
	for i in range(buttons.size()):
		buttons[i].connect("pressed", self, "_on_Level_pressed", [i])

func _on_Level_pressed(arg):
	if arg < Levels.size():
		get_tree().change_scene_to(Levels[arg])
