extends Node2D

func _on_Button_button_up():
	print("connect : ", $Control/input/TextEdit.text)
	get_parent().spin_client($Control/input/TextEdit.text)
	return

func _on_CancelJoint_button_up():
	get_tree().change_scene("res://Menu.tscn")
	get_tree().paused = false
	return
