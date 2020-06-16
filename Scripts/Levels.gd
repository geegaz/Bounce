extends Node2D

export var nextScene: PackedScene
var playing: bool
var win: bool

var Ball: KinematicBody2D
var UI: CanvasLayer
var StartPosition: Position2D

var BallScene = preload("res://Scenes/Ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	UI = $LevelUI
	Ball = $Ball
	if Ball != null:
		Ball.connect("entered_hazard", self, "_on_Ball_entered_hazard")
		Ball.connect("touched_flag", self, "_on_Ball_touched_flag")
	
	playing = true
	win = false
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
			get_tree().change_scene("res://Scenes/Main.tscn")
	if not playing and Input.is_action_just_pressed("ui_accept"):
		if win:
			if nextScene != null:
				get_tree().change_scene_to(nextScene)
			else:
				get_tree().change_scene("res://Scenes/Main.tscn")
		else:
			get_tree().reload_current_scene()
		
		
func loose():
	if playing:
		playing = false
		UI.show_loose()
		$Camera.shake(1.0, 0.2)

func win():
	if playing:
		playing = false
		win = true
		UI.show_win()

func _on_Ball_entered_hazard():
	loose()

func _on_Ball_touched_flag():
	win()
