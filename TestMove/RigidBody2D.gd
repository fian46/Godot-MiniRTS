extends RigidBody2D

const acc = 900
const dec = 900
const max_speed = 150
var dir = Vector2()

func _integrate_forces(state:Physics2DDirectBodyState):
	var dv = dir * max_speed
	var delv = dv - state.linear_velocity
	var is_acc = dv.length() > 0
	if  is_acc:
		delv = delv.normalized() * acc * state.step
	else:
		delv = delv.normalized() * dec * state.step
	var diff = max_speed - state.linear_velocity.length()
	var dsign = sign(diff)
	if (diff < delv.length()) and is_acc:
		delv = delv.clamped(max_speed - state.linear_velocity.length()) * dsign
	if  state.linear_velocity.length() < delv.length() and not is_acc:
		delv = delv.clamped(state.linear_velocity.length())
	print(state.linear_velocity, "  ", delv)
	state.linear_velocity += delv
	return

func _physics_process(delta):
	var imp = Vector2()
	if  Input.is_key_pressed(KEY_A):
		imp.x -= 1
	if  Input.is_key_pressed(KEY_D):
		imp.x += 1
	if  Input.is_key_pressed(KEY_W):
		imp.y -= 1
	if  Input.is_key_pressed(KEY_S):
		imp.y += 1
	dir = imp.normalized()
	return