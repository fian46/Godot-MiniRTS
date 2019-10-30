extends "res://Agent.gd"

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
	return

func readv(b:StreamPeerBuffer):
	return Vector2(b.get_float(), b.get_float())

var state = FORWARD
const FORWARD = 0
const AGRO = 1
const ATTACK = 2
const DEAL_DAMAGE = 3

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

func agro():
	cont()
	var ne = get_nearest()
	if  not ne:
		return FORWARD
	if  ne.position.distance_to(position) <= 40:
		return ATTACK
	var field = ne.position - position
	var speed = field.normalized() * max_speed
	move(speed)
	return AGRO

var atk_timer = 0
func attack():
	halt()
	move(Vector2.ZERO)
	var ne = get_nearest()
	if  not ne:
		return FORWARD
	if  ne.health <= 0:
		return FORWARD
	if  ne.mark_delete:
		return FORWARD
	if  ne.position.distance_to(position) >= 2 * get_base_radius() + 40:
		return FORWARD
	atk_timer += 1
	if  atk_timer >= 20:
		atk_timer = 0
		return DEAL_DAMAGE
	return ATTACK

func deal_damage():
	var ne = get_nearest()
	if  ne:
		ne.health -= 10
		if  ne.health <= 0:
			ne.mark_delete = true
	return ATTACK

func forward():
	cont()
	nearest_target()
	
	var ne = get_nearest()
	if  ne:
		var distance_to_ne = ne.position.distance_to(position)
		if  distance_to_ne < 70 and (distance_to_ne - distance_to_closest_wall(ne.position)) < 40:
			return AGRO
		elif distance_to_ne < 40 + 2 * get_base_radius():
			return ATTACK
	
	var field = flow_field()
	var max_speed = 20
	var speed = field.normalized() * max_speed
	move(speed)
	return FORWARD