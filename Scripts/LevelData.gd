extends Resource
class_name LevelData

export(String) var level_name: String = ""
export(String, FILE, "*.tscn") var level_scene: String

export(float) var level_last_time: int = 0
export(float) var level_best_time: int = 0

func to_dict()->Dictionary:
	return {
		"level_name": level_name,
		"level_scene": level_scene,
		"level_last_time": level_last_time,
		"level_best_time": level_best_time
	}

func from_dict(dict: Dictionary):
	for key in dict:
		set(key, dict.get(key))

static func parse_time(time: int)->Array:
	var parsed: = []
	for divisor in [60000, 1000, 10]:
		parsed.append(str(time / divisor).pad_zeros(2))
		time %= divisor
	return parsed
