extends CanvasLayer


func show_win():
	$Finished.visible = true

func show_loose():
	$GameOver.visible = true

func clear():
	$Finished.visible = false
	$GameOver.visible = false
