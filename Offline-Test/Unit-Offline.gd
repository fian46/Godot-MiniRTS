extends YSort

export(NodePath) var client
var current_fr

var agent_class = load("res://Agent.gd")

var new_unit = []
var skel = load("res://Character/Archer/Archer.tscn")
var retarget_event = false

func exec_thread():
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
	return

func unit_deploy(card, pos, blue):
	new_unit.append([card, pos, blue])
	return

var skip_frame = 0
func _physics_process(delta):
	skip_frame += 1
	if  skip_frame % 3 == 0:
		server_deploy_unit()
		exec_thread()
		
		if  retarget_event:
			retarget_event = false
			deliver_retarget_event()
		
		run_state_machine()
		for i in get_children():
			if  i.get("mark_delete"):
				if  i.mark_delete:
					remove_child(i)
					i.free()
		update_info()
	return

func deliver_retarget_event():
	for i in get_children():
		if  i is agent_class:
			i.on_deploy_retarget()
	return

func run_state_machine():
	for i in get_children():
		if  i is agent_class:
			i.state_machine()
	return

func create_skel(name, position, blue):
	var child:Node2D = skel.instance()
	child.name = name
	child.position = position
	child.is_blue = blue
	child.set_network_master(1)
	return child

func server_deploy_unit():
	for i in new_unit:
		var offset = Vector2(2, 0)
		for j in range(1):
			offset = offset.rotated(deg2rad(17)) * 1.1
			var child = create_skel(global.ngen(), i[1] + offset, i[2])
			child.sync_position = i[1] + offset
			add_child(child)
	
	if  not new_unit.empty():
		new_unit.clear()
		retarget_event = true
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