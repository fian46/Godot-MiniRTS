extends Label

func show():
	visible = true
	$Timer.stop()
	$Timer.start(5)
	return

func _on_Timer_timeout():
	visible = false
	return
