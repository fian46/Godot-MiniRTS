extends Node2D

func _ready():
	$Control/Info.text = str("Waiting client at IP : ", IP.get_local_addresses()[1])
	return

func _on_Button_button_up():
	get_tree().paused = false
	get_tree().change_scene("res://Menu.tscn")
	return