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
	health = 16
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

var path:Curve2D = Curve2D.new()

func agro():
	cont()
	var ne = get_nearest()
	if  not ne:
		return FORWARD
	if  ne.position.distance_to(position) <= 60:
		return ATTACK
	
	var arr = global.nav.get_simple_path(position, ne.position, true)
	path.clear_points()
	
	for v in arr:
		path.add_point(v)
	
	var coffset = path.get_closest_offset(position)
	var fixed_delta = 1.0 / 30.0
	coffset += fixed_delta * max_speed
	var next_point = path.interpolate_baked(coffset)
	var field = next_point - position
	field = field.normalized()
	move(field * max_speed)
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
		if  ne.pending_damage > health:
			var selected = null
			for i in nearest_group():
				if  i.pending_damage > health:
					continue
				if  selected == null:
					selected = i
				elif  selected.position.distance_to(position) > i.position.distance_to(position):
					selected = i
			if  selected:
				ne = selected
			else:
				return FORWARD
		ne.pending_damage += 12
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
		if  distance_to_ne < 60:
			return ATTACK
		elif distance_to_ne < 70:
			return AGRO
	
	var field = flow_field()
	var speed = field.normalized() * max_speed
	move(speed)
	return FORWARD