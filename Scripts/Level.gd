extends Node2D

var playing: bool
var win: bool

var Ball: KinematicBody2D
var UI: CanvasLayer

var start_time: int = 0
var end_time: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Ball = $Ball
	
	playing = true
	win = false
	
	Ball.connect("entered_hazard", self, "_on_Ball_entered_hazard")
	Ball.connect("touched_flag", self, "_on_Ball_touched_flag")
	
	start_time = OS.get_ticks_msec()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Global.goto_menu()

func wait_for_next_scene(level_id: int, time: float):
	var timer = get_tree().create_timer(time)
	yield(timer,"timeout")
	Global.goto_level(level_id)

func _on_Ball_entered_hazard():
	if playing:
		playing = false
		Global._Camera.shake(2.0, 0.2)
		wait_for_next_scene(Global.level, 1.0)

func _on_Ball_touched_flag():
	if playing:
		playing = false
		win = true
		Global._Camera.shake(2.0, 0.2)
		wait_for_next_scene(Global.level+1, 0.5)
