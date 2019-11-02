extends Camera2D

var size = Vector2()

func _ready():
	get_tree().connect("screen_resized", self, "screen_size")
	screen_size()
	set_network_master(1, false)
	return

func screen_size():
	size = get_viewport().size
	var h = size.y
	var gh = 420 + 30
	var sy = gh / h
	zoom = Vector2(sy, sy)
	return

func _unhandled_input(event):
	if  not get_tree().network_peer:
		return
	else:
		if  not(event is InputEventMouseButton and not event.is_pressed()):
			return
		if  not(event.button_index == 1):
			return
		if  get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			var pos = event.position
			var half = size / 2
			pos = pos - half
			pos = (pos * zoom) + get_camera_position()
			var det = get_world_2d().direct_space_state.intersect_point(pos, 1, [], 4)
			if  det:
				return
			if  get_tree().is_network_server():
				if  valid_card(global.blue_card):
					rpc("server_drop", global.blue_card, pos, true)
				else:
					error("No card selected !")
			else:
				if  valid_card(global.red_card):
					rpc("server_drop", global.red_card, pos.rotated(PI), false)
				else:
					error("No card selected !")
	return

func valid_card(card:int):
	return card >=0 and card <=3

master func server_drop(card, pos, blue):
	var scard = null
	if  blue:
		scard = global.blue_deck[card]
		global.blue_deck.remove(card)
		global.blue_deck.append(scard)
		clear_deck_selection()
		update_deck(global.blue_deck)
	else:
		scard = global.red_deck[card]
		global.red_deck.remove(card)
		global.red_deck.append(scard)
		rpc("clear_deck_selection")
		rpc("update_deck", global.red_deck)
	
	var unit = get_parent().get_node("Choke/TileMap/Unit")
	unit.unit_deploy(scard, pos, blue)
	return

func init_deck():
	clear_deck_selection()
	update_deck(global.blue_deck)
	rpc("clear_deck_selection")
	rpc("update_deck", global.red_deck)
	return

puppet func clear_deck_selection():
	var deck = get_parent().get_node("Choke/Center/Deck")
	deck.clear_selection()
	return

puppet func update_deck(param):
	var deck = get_parent().get_node("Choke/Center/Deck")
	deck.update_card(param)
	return

func error(msg):
	var error:Label = get_parent().get_node("Choke/Error")
	error.text = msg
	yield(get_tree().create_timer(3), "timeout")
	error.text = ""
	return