extends GridContainer

var selected = 0

func on_card_selecting(sel, index):
	if  sel:
		selected = index
		for i in range(4):
			if  i != index - 1:
				get_child(i).pressed = false
	else:
		selected = 0
	print(selected)
	return
