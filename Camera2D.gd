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
				rpc("server_drop", 1, pos, true)
			else:
				rpc("server_drop", 1, pos.rotated(PI), false)
	return

master func server_drop(card, pos, blue):
#	if  blue:
#		if  global.blue_elixir < 3:
#			return
#		global.blue_elixir -= 3
#	else:
#		if  global.red_elixir < 3:
#			return
#		global.red_elixir -= 3
	var unit = get_parent().get_node("Choke/TileMap/Unit")
	unit.unit_deploy(card, pos, blue)
	return
