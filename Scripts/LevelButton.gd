extends Button

export(Resource) var level_data
export(bool) var locked: bool = false

onready var _LevelName = $ButtonContainer/LevelName
onready var _TimeContainer = $ButtonContainer/TimeContainer
onready var _LastTime = $ButtonContainer/TimeContainer/LastTime
onready var _BestTime = $ButtonContainer/TimeContainer/BestTime

func _ready() -> void:
	_TimeContainer.hide()
	
	if locked:
		disabled = true
		_LevelName.modulate = Color.gray
		
	if level_data:
		_LevelName.text = level_data.level_name
		
		if level_data.level_last_time > 0 and level_data.level_best_time > 0:
			var parsed_last_time: = LevelData.parse_time(level_data.level_last_time)
			var parsed_best_time: = LevelData.parse_time(level_data.level_best_time)
			_LastTime.text = _LastTime.text.format(parsed_last_time)
			_BestTime.text = _BestTime.text.format(parsed_best_time)
			
			_TimeContainer.show()
