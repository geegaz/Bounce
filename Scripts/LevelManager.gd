extends Node

export(Array, Resource) var levels: = []

var current_level: int = -1
var last_unlocked_level: int = 0

func start_level(level_id: int)->void:
	if level_id > last_unlocked_level:
		last_unlocked_level = level_id
	current_level = level_id
	get_tree().change_scene(levels[level_id].level_scene)

func start_next_level()->void:
	start_level(current_level + 1)
