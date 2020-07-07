extends Node2D

export var next_scene: int
var playing: bool
var win: bool

var Ball: KinematicBody2D
var UI: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Ball = $Ball
	
	playing = true
	win = false
	
	Ball.connect("entered_hazard", self, "_on_Ball_entered_hazard")
	Ball.connect("touched_flag", self, "_on_Ball_touched_flag")

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Global.goto_menu()

func wait_for_next_scene(level_id: int, time: float):
	var timer = Timer.new()
	add_child(timer)
	timer.set_one_shot(true)
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.set_wait_time(time)
	timer.connect("timeout", self, "_timer_callback", [level_id])
	timer.start()

func _timer_callback(level_id):
	Global.next_scene(level_id)

func _on_Ball_entered_hazard():
	if playing:
		playing = false
		Global.CameramanBilly.shake(2.0, 0.2)
		wait_for_next_scene(-1, 1.0)

func _on_Ball_touched_flag():
	if playing:
		playing = false
		win = true
		Global.CameramanBilly.shake(2.0, 0.2)
		wait_for_next_scene(next_scene, 0.5)
