extends Label

export(NodePath) var path_paused 

func _process(delta):
	var mode = "join"
	if  global.host:
		mode = "host"
	text = str(Performance.get_monitor(Performance.TIME_FPS), " | " , global.red, " | ", global.blue, " | ", global.red + global.blue, " mode ", mode)
	return
