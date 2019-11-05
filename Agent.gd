extends RigidBody2D

export var is_blue = false
export var max_speed = 20
var field = {}
var radar = []
var nearest
var health = 10
var pending_damage = 0
var acc = 1
var base_rad = 0
var area_radius = 65

var mark_delete = false
var sync_position = Vector2()
var move_vel = Vector2()

var frame = 0

func on_deploy_retarget():
	nearest_target()
	return

func get_type():
	return 0

func get_snapshot():
	return

func set_snapshot(snap):
	return

func _integrate_forces(state:Physics2DDirectBodyState):
	if  sync_position:
		state.transform = Transform2D(0, sync_position)
		state.linear_velocity = move_vel
		sync_position = null
	else:
		var res_vel = state.linear_velocity
		state.linear_velocity = move_vel
		move_vel = res_vel
	return

func get_nearest():
	if  nearest == null:
		return null
	return nearest.get_ref()

func _ready():
	base_rad = $shape.shape.radius
	return

func add_force_field(id, forward, backward, level):
	if (is_blue):
		field[id] = [level, forward, backward]
	else:
		field[id] = [level, backward, forward]
	csign += 1
	return

func remove_force_field(id):
	field.erase(id)
	csign += 1
	return

func state_machine():
	return

func _enter_tree():
	if (is_blue):
		if  has_node("RED"):
			$RED.visible = false
	else:
		if  has_node("BLUE"):
			$BLUE.visible = false
	return

func nearest_target():
	var selected = null;
	var near = nearest_group()
	for i in near:
		if  selected == null:
			selected = i
		elif selected.position.distance_to(position) > i.position.distance_to(position):
			selected = i
	if  selected and selected.position.distance_to(position) < area_radius:
		nearest = weakref(selected)
	else:
		nearest = null
	return

func nearest_group():
	if  is_blue:
		return global.get_nearest_red(position)
	else:
		return global.get_nearest_blue(position)

var psign = 0
var csign = 0
var pre_flow = Vector2()

func pre_flow_field():
	if  psign != csign:
		psign = csign
		var combined = Vector2()
		var level = 4
		var tot = []
		var com = []
		
		for i in range(level):
			tot.append(0)
			com.append(Vector2())
		
		for i in field.keys():
			var t = field[i]
			com[t[0]] += t[1].normalized()
			tot[t[0]] = true
		
		for i in range(level - 1, -1, -1):
			if  tot[i]:
				combined = com[i].normalized()
				break
		pre_flow = combined.normalized()
		return combined
	return pre_flow

func flow_field():
	var combined = pre_flow_field()
	return combined.normalized()

func any_wall_toward_position(value:Vector2):
	var dstate = get_world_2d().direct_space_state
	var result = dstate.intersect_ray(position, value, [self], 4, true, false)
	if  result:
		return !result.empty()
	else:
		return false

func distance_to_closest_wall(value:Vector2):
	var dstate = get_world_2d().direct_space_state
	var result = dstate.intersect_ray(position, value, [self], 4, true, false)
	if  result:
		return value.distance_to(result["position"])
	else:
		return 0

func move(desired_velocity):
	move_vel = move_vel + 0.5 * (desired_velocity - move_vel)
	return

func halt():
	mass = 200
	return

func cont():
	mass = 1
	return

func get_base_radius():
	return base_rad