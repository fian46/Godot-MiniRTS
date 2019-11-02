extends Node2D

var mark_delete = false
var frame = 0

var target_ref:WeakRef
var speed = 260
var direction = Vector2()

func get_type():
	return 2

func get_snapshot():
	var b = StreamPeerBuffer.new()
	b.put_u8(get_type())
	b.put_u16(int(name))
	b.put_float(position.x)
	b.put_float(position.y)
	b.put_float(direction.x)
	b.put_float(direction.y)
	return b.data_array

func set_snapshot(snap):
	var b = StreamPeerBuffer.new()
	b.data_array = snap
	b.get_u8()
	name = str(b.get_u16())
	position = readv(b).rotated(PI)
	direction = readv(b).rotated(PI)
	$Sprite.rotation = direction.angle()
	return

func readv(b):
	return Vector2(b.get_float(), b.get_float())

func set_target(target):
	if  target:
		target_ref = weakref(target)
		direction = target.position - position
		$Sprite.rotation = direction.angle()
	return

var client_traveled = 0

func _physics_process(delta):
	if  not global.host:
		$Sprite.visible = client_traveled <= direction.length()
		var ds = direction.normalized() * speed
		$Sprite.rotation = direction.angle()
		var dp = ds * delta
		dp = dp.clamped(direction.length())
		position = position + dp
		client_traveled += dp.length()
		return
	if  mark_delete:
		return
	if  not target_ref:
		mark_delete = true
		return
	var target = target_ref.get_ref()
	if  not target:
		mark_delete = true
		return
	direction = target.position - position
	var ds = direction.normalized() * speed
	$Sprite.rotation = direction.angle()
	var dp = ds * delta
	dp = dp.clamped(direction.length())
	position = position + dp
	if  position.distance_to(target.position) < 0.1:
		mark_delete = true
		target.health -= 12
		if  target.health <= 0:
			target.mark_delete = true
	return