extends GridContainer

var selected = -1

func on_card_selecting(sel, index):
	if  sel:
		selected = index
		for i in range(4):
			if  i != index:
				get_child(i).pressed = false
	else:
		selected = -1
	if  global.host:
		global.blue_card = selected
	else:
		global.red_card = selected
	return

func clear_selection():
	for i in get_children():
		i.pressed = false
	selected = -1
	if  global.host:
		global.blue_card = -1
	else:
		global.red_card = -1
	return

func update_card(cards):
	for i in range(4):
		get_child(i).set_card(cards[i])
	return

onready var drop = get_parent().get_parent().get_node("TileMap/DropArea")

func _process(delta):
	drop.visible = selected != -1
	return