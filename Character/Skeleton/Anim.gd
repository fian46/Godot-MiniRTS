extends Sprite

func speed(speed:Vector2):
	speed = speed.normalized()
	var dir = Vector2(speed.x, -speed.y)
	$AnimationPlayer/AnimationTree.set("parameters/blend_position", dir)
	return