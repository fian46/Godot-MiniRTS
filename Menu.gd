extends Node2D

func _on_Host_button_up():
	get_tree().change_scene("res://Arena.tscn")
	global.host = true
	return

func _on_Joint_button_up():
	get_tree().change_scene("res://Arena.tscn")
	global.host = false
	return