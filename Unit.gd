extends YSort

export(NodePath) var client
var current_fr

var agent_class = load("res://Agent.gd")

var new_unit = []

var skel = load("res://Character/Skeleton/Skeleton.tscn")
var arch = load("res://Character/Archer/Archer.tscn")
var arro = load("res://Character/Arrow/Arrow.tscn")

func _ready():
	set_network_master(1, false)
	if  not global.host:
		multiplayer.connect("network_peer_packet", self, "packet")
	return

var t = 0

func exec_thread():
	if  not get_tree().is_network_server():
		return
	global.clear_map()
	for i in get_children():
		if i is agent_class:
			if  i.is_blue:
				global.index_blue(i)
			else:
				global.index_red(i)
	global.build_tree()
	return

func _exit_tree():
	global.clear_map()
	if  not global.host:
		multiplayer.disconnect("network_peer_packet", self, "packet")
	return

var client_read_frame = 0

func packet(id, data):
	var b = StreamPeerBuffer.new()
	b.data_array = data
	var type = b.get_8()
	if  type == 1:
		var size = b.get_32()
		var fr = b.get_32()
		if  client_read_frame < fr:
			client_read_frame = fr
		else:
			return 
		while b.get_available_bytes() > 0:
			var ds = b.get_32()
			var pb_array = b.get_data(ds)[1]
			var cb = StreamPeerBuffer.new()
			cb.data_array = pb_array
			var type0 = cb.get_8()
			var iname = cb.get_u16()
			var sname = str(iname)
			if  has_node(sname):
				var child = get_node(sname)
				child.set_snapshot(pb_array)
				child.frame = fr
			else:
				var child = null
				match(type0):
					0:
						child = skel.instance()
					1:
						child = arch.instance()
					2:
						child = arro.instance()
				child.set_snapshot(pb_array)
				child.name = sname
				if  child.get("sync_position"):
					child.position = child.sync_position
				child.frame = fr
				add_child(child)
		
		for i in get_children():
			if  i.get("frame"):
				if  i.frame != fr:
					remove_child(i)
					i.free()
	return

func unit_deploy(card, pos, blue):
	new_unit.append([card, pos, blue])
	return

var skip_frame = 0
func _physics_process(delta):
	if  not get_tree().network_peer:
		return
	skip_frame += 1
	if  skip_frame % 3 == 0:
		server_deploy_unit()
		server_sync_client()
		exec_thread()
		run_state_machine()
		update_info()
	return

func deliver_retarget_event():
	for i in get_children():
		if  i is agent_class:
			i.on_deploy_retarget()
	return

func run_state_machine():
	if  not get_tree().is_network_server():
		return
	for i in get_children():
		if  i is agent_class:
			i.state_machine()
	return

func server_sync_client():
	if  not get_tree().is_network_server():
		return
	if  skip_frame % 6 != 0:
		return
	if  get_child_count() > 0:
		var temp_buf = StreamPeerBuffer.new()
		for i in get_children():
			if  i.has_method("get_snapshot"):
				if  not i.mark_delete:
					var sel:PoolByteArray = i.get_snapshot()
					var size = sel.size()
					temp_buf.put_32(size)
					temp_buf.put_data(sel)
				else:
					remove_child(i)
					i.free()
		
		var sync_buf = StreamPeerBuffer.new()
		sync_buf.put_8(1)
		sync_buf.put_32(temp_buf.data_array.size())
		sync_buf.put_32(skip_frame)
		sync_buf.put_data(temp_buf.data_array)
		multiplayer.send_bytes(sync_buf.data_array, 0, NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
	return

func create_skel(name, position, blue):
	var child:Node2D = skel.instance()
	child.name = name
	child.position = position
	child.is_blue = blue
	return child

func create_arch(name, position, blue):
	var child:Node2D = arch.instance()
	child.name = name
	child.position = position
	child.is_blue = blue
	return child

func server_deploy_unit():
	if  not get_tree().is_network_server():
		return
	
	for i in new_unit:
		var offset = Vector2(2, 0)
		if  i[0] == 0:
			for j in range(15):
				offset = offset.rotated(deg2rad(17)) * 1.1
				var child = create_skel(global.ngen(), i[1] + offset, i[2])
				child.sync_position = i[1] + offset
				add_child(child)
		elif i[0] == 1:
			var child = create_arch(global.ngen(), i[1] + Vector2(-4, 0), i[2])
			child.sync_position = child.position
			add_child(child)
			child = create_arch(global.ngen(), i[1] + Vector2(4, 0), i[2])
			child.sync_position = child.position
			add_child(child)
		
	if  not new_unit.empty():
		new_unit.clear()
		deliver_retarget_event()
		return
	
	new_unit.clear()
	return

func update_info():
	global.red = 0
	global.blue = 0
	for i in get_children():
		if  i is agent_class:
			if i.is_blue:
				global.blue += 1
			else:
				global.red += 1
	return