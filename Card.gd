extends TextureButton

func set_card(card_id):
	$Placement/V2/H/Cost.text = str(global.card_map[card_id][1])
	$Placement/V2/H2/DMG.text = str(global.card_map[card_id][2])
	$Placement/V2/H3/HP.text = str(global.card_map[card_id][3])
	$Placement/Name.text = str(global.card_map[card_id][4])
	return

func _process(delta):
	if  pressed:
		$Placement.rect_position.y = -20
	else:
		$Placement.rect_position.y = 0
	return
