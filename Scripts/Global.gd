extends Node2D

export(Array, String, FILE) var Levels
export(int, 0, 20) var max_unlocked_level: int = 0

var current_scene = null
var play_time: float
var level: int

var Animator: AnimationPlayer
var LevelLabel: Label
var CameramanBilly: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	play_time = 0.0
	level = 0
	
	Animator = $UI/AnimationPlayer
	LevelLabel = $UI/TransitionText/Label
	CameramanBilly = $Camera
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func _process(delta):
	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func change_scene(path):
	# From Godot docs, Singleton scene switcher
	current_scene.queue_free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)

func next_scene(level_num: int):
	if level_num == -1:
		level_num = level
	if level_num < Levels.size():
		Animator.connect("animation_finished", self, "_finish_next_scene", [level_num])
		LevelLabel.text = ("Level "+str(level_num))
		Animator.play("next_level_hide")
	else:
		goto_menu()

func _finish_next_scene(anim_name, level_num: int):
	change_scene(Levels[level_num])
	level = level_num
	if level_num > max_unlocked_level:
		max_unlocked_level = level_num
	Animator.play("next_level_reveal")
	Animator.disconnect("animation_finished", self, "_finish_next_scene")
	
func goto_menu():
	Animator.connect("animation_finished", self, "_finish_goto_menu")
	LevelLabel.text = "Bounce!"
	Animator.play("next_level_hide")

func _finish_goto_menu(anim_name):
	change_scene("res://Scenes/Main.tscn")
	Animator.play("next_level_reveal")
	Animator.disconnect("animation_finished", self, "_finish_goto_menu")

