extends "res://Agent.gd"

const FORWARD = 0
const AGRO = 1
const ATTACK = 2
const ATTACK_ANIMATION = 3
const DEAL_DAMAGE = 4

var state = FORWARD

func get_type():
	return 0

func get_snapshot():
	var b = StreamPeerBuffer.new()
	b.put_u8(get_type())
	b.put_u16(int(name))
	b.put_float(position.x)
	b.put_float(position.y)
	b.put_float(move_vel.x)
	b.put_float(move_vel.y)
	if  is_blue:
		b.put_u8(1)
	else:
		b.put_u8(0)
	b.put_float(health)
	return b.data_array

func set_snapshot(snap):
	var b = StreamPeerBuffer.new()
	b.data_array = snap
	b.get_u8()
	name = str(b.get_u16())
	var v = Vector2(b.get_float(), b.get_float())
	sync_position = v.rotated(PI)
	v = Vector2(b.get_float(), b.get_float())
	move_vel = v.rotated(PI)
	if  b.get_u8():
		is_blue = true
	else:
		is_blue = false
	health = b.get_float()
	return

func _ready():
	area_radius = 70
	health = 10
	return

func state_machine():
	match (state):
		FORWARD :
			state = follow_field()
		AGRO :
			state = agro()
		ATTACK :
			state = attack()
		ATTACK_ANIMATION:
			state = attack_animation()
		DEAL_DAMAGE:
			state = deal_damage()
	return

func on_deploy_retarget():
	if  state != ATTACK:
		nearest_target()
	return

func attack():
	halt()
	move(Vector2.ZERO)
	if  not get_nearest():
		return FORWARD
	if  any_wall_toward_position(get_nearest().position):
		return FORWARD
	if  not in_attack_range():
		return FORWARD
	return ATTACK_ANIMATION

var begin_attack = false
var attack_animation_frame = 0
func attack_animation():
	halt()
	if  not begin_attack:
		begin_attack = true
		attack_animation_frame = 0
	
	if  not in_attack_range():
		begin_attack = false
		attack_animation_frame = 0
		return FORWARD
	
	if  begin_attack:
		attack_animation_frame += 1
		if  attack_animation_frame >= 10:
			begin_attack = false
			attack_animation_frame = 0
			return DEAL_DAMAGE
	return ATTACK_ANIMATION

func deal_damage():
	halt()
	var ne = get_nearest()
	if  not ne:
		return FORWARD
	if  any_wall_toward_position(ne.position):
		return FORWARD
	if  not in_attack_range():
		return FORWARD
	ne.health -= 2
	if  ne.health <= 0:
		ne.mark_delete = true
	return ATTACK

var path:Curve2D = Curve2D.new()

func agro():
	cont()
	var ne = get_nearest()
	if  !ne:
		return FORWARD
	if  in_attack_range():
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

func in_attack_range():
	var ne = get_nearest()
	if  not ne:
		return false
	return position.distance_to(ne.position) < 2 + (get_base_radius() + ne.get_base_radius())

func follow_field():
	cont()
	nearest_target()
	var field = flow_field().normalized()
	var ne = get_nearest()
	if  ne:
		return AGRO
	if  in_attack_range():
		return ATTACK
	var tspeed = field * max_speed
	move(tspeed)
	return FORWARD