extends Node2D

signal load_scene

const SAVE_FILE = "user://bounce-save.json"
# Data to save:
# - max_unlocked_level
# - sfx_volume
# - music_volume
# - use_controller_rumble

export(Array, String, FILE, "*.tscn") var levels
export(String, FILE, "*.tscn") var menu_scene = "res://Scenes/Main.tscn"

export(int, 0, 20) var max_unlocked_level = 0
export(float, -80.0, 6.0) var sfx_volume = 0.0
export(float, -80.0, 6.0) var music_volume = 0.0
export(bool) var use_controller_rumble = true

var level: int

var _Anim: AnimationPlayer
var _LevelLabel: Label
var _Camera: Camera2D
var _Music: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()
	level = -1
	
	AudioServer.set_bus_volume_db(1, sfx_volume)
	AudioServer.set_bus_volume_db(2, music_volume)
	
	_Anim = $UI/AnimationPlayer
	_LevelLabel = $UI/TransitionText/Label
	_Camera = $Camera
	_Music = $Music

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func goto_level(level_id: int)->void:
	if level_id > -1 and level_id < levels.size():
		if level != level_id:
			_LevelLabel.text = "Level {0}".format([level_id])
			level = level_id
			max_unlocked_level = max(level_id, max_unlocked_level)
			change_scene(levels[level], 1.2)
		else:
			_LevelLabel.text = ""
			change_scene(levels[level])
		
		# Start music if it's not already started
		if not _Music.playing:
			_Music.play()
	else:
		goto_menu()

func goto_menu()->void:
	level = -1
	_Music.stop()
	_LevelLabel.text = "Bounce!"
	
	change_scene(menu_scene, 0.5)

func change_scene(path: String, delay: float = 0)->void:
	_Anim.play("transition")
	
	yield(self,"load_scene")
	_Anim.stop(false)
	yield(get_tree().create_timer(delay), "timeout")
	get_tree().change_scene(path)
	_Anim.play()

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

