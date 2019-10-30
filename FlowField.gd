tool
extends Node2D

export(float, 0, 360, 10) var red_direction = 0.0 setget set_red_direction
export(float, 0, 360, 10) var blue_direction = 0.0 setget set_blue_direction
export(int, 0, 10) var level = 0
export(bool) var invert_color = false
var field_blue = Vector2()
var field_red = Vector2()
var last_global_rotation = 0

func _ready():
	if (!Engine.editor_hint):
		$RED.visible = false
		$BLUE.visible = false
	return

func compute_field():
	field_blue = vi($BLUE.global_rotation)
	field_red = vi($RED.global_rotation)
	return

func vi(value):
	return Vector2(cos(value), sin(value));

func set_red_direction(value):
	red_direction = value
	$RED.rotation = deg2rad(value)
	return

func set_blue_direction(value):
	blue_direction = value
	$BLUE.rotation = deg2rad(value)
	return

func is_flow_input(obj):
	return obj.has_method("add_force_field") and obj.has_method("remove_force_field")

func _on_Area2D_body_entered(body):
	if  not is_flow_input(body):
		return
	if  not invert_color:
		body.add_force_field(name, field_blue, field_red, level)
	else:
		body.add_force_field(name, field_red, field_blue, level)
	return

func _on_Area2D_body_exited(body):
	if  not is_flow_input(body):
		return
	body.remove_force_field(name)
	return