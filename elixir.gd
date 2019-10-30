extends Line2D

func _ready():
	if  not global.host:
		$elixir_timer.queue_free()
	return

func _on_elixir_timer_timeout():
	if  get_tree().network_peer:
		if  get_tree().is_network_server():
			global.blue_elixir += 1
			if (global.blue_elixir > 10):
				global.blue_elixir = 10
			global.red_elixir += 1
			if (global.red_elixir > 10):
				global.red_elixir = 10
	return

remote func update_elixir(blue, red):
	global.red_elixir = red
	global.blue_elixir = blue
	return

var old = 0

func _process(delta):
	if  get_tree().network_peer:
		if get_tree().is_network_server():
			if  old != global.red_elixir + global.blue_elixir:
				old = global.red_elixir + global.blue_elixir
				rpc_unreliable("update_elixir", global.blue_elixir, global.red_elixir)
	
	if  get_tree().network_peer:
		if  get_tree().is_network_server():
			points[0] = Vector2(range_lerp(global.blue_elixir, 0, 10, 25, 255), -3)
		else:
			points[0] = Vector2(range_lerp(global.red_elixir, 0, 10, 25, 255), -3)
	return