extends Node2D

const SAVE_FILE = "user://bounce-save.json"
# Data to save:
# - max_unlocked_level
# - sfx_volume
# - music_volume
# - use_controller_rumble

export(Array, String, FILE) var Levels
export(int, 0, 20) var max_unlocked_level = 0
export(float, -80.0, 6.0) var sfx_volume = 0.0
export(float, -80.0, 6.0) var music_volume = 0.0
export(bool) var use_controller_rumble = true

var current_scene = null
var level: int

var Animator: AnimationPlayer
var LevelLabel: Label
var CameramanBilly: Camera2D
var Music: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()
	level = -1
	
	AudioServer.set_bus_volume_db(1, sfx_volume)
	AudioServer.set_bus_volume_db(2, music_volume)
	
	Animator = $UI/AnimationPlayer
	LevelLabel = $UI/TransitionText/Label
	CameramanBilly = $Camera
	Music = $Music
	
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
		
		if !Music.playing:
			Music.play()
	else:
		goto_menu()

func _finish_next_scene(anim_name, level_num: int):
	change_scene(Levels[level_num])
	level = level_num
	if level_num > max_unlocked_level:
		max_unlocked_level = level_num
	Animator.play("next_level_reveal")
	Animator.disconnect("animation_finished", self, "_finish_next_scene")
	
	save_game()
	
func goto_menu():
	Animator.connect("animation_finished", self, "_finish_goto_menu")
	LevelLabel.text = "Bounce!"
	Animator.play("next_level_hide")

func _finish_goto_menu(anim_name):
	level = -1
	change_scene("res://Scenes/Main.tscn")
	Animator.play("next_level_reveal")
	Animator.disconnect("animation_finished", self, "_finish_goto_menu")
	
	if Music.playing:
		Music.stop()

func save_game():
	var data = {
		"max_unlocked_level": max_unlocked_level,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"use_controller_rumble": use_controller_rumble
	}
	var f = File.new()
	f.open(SAVE_FILE, File.WRITE)
	f.store_line(to_json(data))
	f.close()

func load_game():
	var f = File.new()
	if f.file_exists(SAVE_FILE):
		f.open(SAVE_FILE, File.READ)
		var data = parse_json(f.get_as_text())
		f.close()
		if typeof(data) == TYPE_DICTIONARY:
			if data["max_unlocked_level"] > max_unlocked_level:
				max_unlocked_level = data["max_unlocked_level"]
			sfx_volume = data["sfx_volume"]
			music_volume = data["music_volume"] 
			use_controller_rumble = data["use_controller_rumble"]
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

func reset():
	max_unlocked_level = 0
	sfx_volume = 0.0
	music_volume = 0.0
	use_controller_rumble = true
	
	save_game()
	goto_menu()

