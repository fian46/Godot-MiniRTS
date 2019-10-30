extends Node2D

func _ready():
	set_network_master(1, false)
	get_tree().multiplayer_poll = true
	get_tree().set_network_peer(null)
	get_tree().paused = true
	var blue_field = $Choke/TileMap/blue_field
	var red_field = $Choke/TileMap/red_field
	if  global.host:
		$HostScreen.visible = true
		$JointScreen.visible = false
		compute_field(blue_field)
		compute_field(red_field)
		spin_server()
	else :
		$HostScreen.visible = false
		$JointScreen.visible = true
		red_field.queue_free()
		blue_field.queue_free()
	return

func compute_field(par:Node):
	for i in par.get_children():
		i.compute_field()
	return

func _exit_tree():
	get_tree().set_network_peer(null)
	get_tree().paused = false
	return

func spin_server():
	var net = NetworkedMultiplayerENet.new()
	net.create_server(9999, 1)
	get_tree().set_network_peer(net)
	
	if  get_tree().is_connected("network_peer_connected", self, "network_peer_connected"):
		get_tree().disconnect("network_peer_connected", self, "network_peer_connected")
		get_tree().disconnect("network_peer_disconnected", self, "network_peer_disconnected")
	
	get_tree().connect("network_peer_connected", self, "network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
	return

func spin_client(ip):
	var net = NetworkedMultiplayerENet.new()
	var error = net.create_client(ip, 9999)
	get_tree().set_network_peer(net)
	if  error:
		$JointScreen/Control/input2/FailedInfo.show()
	if  get_tree().is_connected("connection_failed", self, "connection_failed"):
		get_tree().disconnect("connection_failed", self, "connection_failed")
		get_tree().disconnect("connected_to_server", self, "connected_to_server")
		get_tree().disconnect("server_disconnected", self, "server_disconnected")
	
	get_tree().connect("connection_failed", self, "connection_failed")
	get_tree().connect("connected_to_server", self, "connected_to_server")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	return

master func client_ready():
	print("client ready")
	rpc("server_start")
	get_tree().multiplayer.refuse_new_network_connections = true
	return

remotesync func server_start():
	$JointScreen.visible = false
	$HostScreen.visible = false
	get_tree().paused = false
	return

func server_disconnected():
	print("Server disconnected")
	get_tree().change_scene("res://Menu.tscn")
	return

func connected_to_server():
	rpc("client_ready")
	return

func connection_failed():
	print("Connection failed ...")
	$JointScreen/Control/input2/FailedInfo.show()
	return

func network_peer_connected(id):
	print(id, " Joined Server")
	return

func network_peer_disconnected(id):
	print(id, " Leave Server")
	get_tree().change_scene("res://Menu.tscn")
	return