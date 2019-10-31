extends "res://Agent.gd"

const attack_time = 8
var state = FORWARD
const FORWARD = 0
const AGRO = 1
const ATTACK = 2
const DEAL_DAMAGE = 3
var atk_timer = 0
var arrow_class = load("res://Character/Arrow/Arrow.tscn")

func _ready():
	$Arrow.set_as_toplevel(true)
	return

func get_type():
	return 1

func get_snapshot():
	var b = StreamPeerBuffer.new()
	b.put_u8(get_type()) # 1 byte
	b.put_u16(int(name)) # 2 byte
	b.put_float(position.x) # float is 4 byte
	b.put_float(position.y) # float is 4 byte
	
	b.put_float(move_vel.x) # float is 4 byte
	b.put_float(move_vel.y) # float is 4 byte
	if  is_blue:
		b.put_8(1)
	else:
		b.put_8(0)
	
	b.put_8(state)
	if  state == ATTACK:
		var ne = get_nearest()
		if  ne:
			b.put_16(int(ne.name))
		else:
			b.put_16(-1)
	return b.data_array

func set_snapshot(snap):
	var b = StreamPeerBuffer.new()
	b.data_array = snap
	b.get_u8()
	name = str(b.get_u16())
	sync_position = readv(b).rotated(PI)
	move_vel = readv(b).rotated(PI)
	if  b.get_8():
		is_blue = true
	else:
		is_blue = false
	state = b.get_8()
	if  state == ATTACK:
		var ns = str(b.get_16())
		var pa = get_parent()
		if  pa and pa.has_node(ns):
			var no = pa.get_node(ns)
			if  no:
				nearest = weakref(no)
	return

func readv(b:StreamPeerBuffer):
	return Vector2(b.get_float(), b.get_float())

func state_machine():
	match(state):
		FORWARD:
			state = forward()
		AGRO:
			state = agro()
		ATTACK:
			state = attack()
		DEAL_DAMAGE:
			state = deal_damage()
	return

#func _physics_process(delta):
#	if  state == ATTACK:
#		var ne = get_nearest()
#		if  not ne:
#			$Arrow.visible = false
#			return
#		if  not global.host:
#			atk_timer += 1
#		$Arrow.visible = atk_timer <= attack_time
#		var inter = float(atk_timer + 1) / attack_time
#		var dir:Vector2 = ne.position - position
#		dir *= inter
#		$Arrow.position = position + dir
#		$Arrow.rotation = dir.angle()
#	else:
#		if  not global.host:
#			atk_timer = 0
#		$Arrow.visible = false
#	return

func agro():
	cont()
	var ne = get_nearest()
	if  not ne:
		return FORWARD
	if  ne.position.distance_to(position) <= 60:
		return ATTACK
	var field = ne.position - position
	var speed = field.normalized() * max_speed
	move(speed)
	return AGRO

func attack():
	halt()
	move(Vector2.ZERO)
	var ne = get_nearest()
	if  not ne:
		atk_timer = 0
		return FORWARD
	if  ne.health <= 0:
		atk_timer = 0
		return FORWARD
	if  ne.mark_delete:
		atk_timer = 0
		return FORWARD
	if  ne.position.distance_to(position) >= 2 * get_base_radius() + 60:
		atk_timer = 0
		return FORWARD
	var attack_time = 8.0
	atk_timer += 1
	if  atk_timer >= attack_time:
		atk_timer = 0
		return DEAL_DAMAGE
	return ATTACK


func deal_damage():
	var ne = get_nearest()
	if  ne:
		var ar = arrow_class.instance()
		ar.position = position
		ar.set_target(ne)
		ar.name = global.ngen()
		get_parent().add_child(ar)
	return ATTACK

func forward():
	cont()
	nearest_target()
	
	var ne = get_nearest()
	if  ne:
		var distance_to_ne = ne.position.distance_to(position)
		if  distance_to_ne < 70 and (distance_to_ne - distance_to_closest_wall(ne.position)) < 60:
			return AGRO
		elif distance_to_ne < 60 + 2 * get_base_radius():
			return ATTACK
	
	var field = flow_field()
	var max_speed = 20
	var speed = field.normalized() * max_speed
	move(speed)
	return FORWARD