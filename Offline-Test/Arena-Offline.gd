extends Node2D

func _ready():
	var blue_field = $Choke/TileMap/blue_field
	var red_field = $Choke/TileMap/red_field
	compute_field(blue_field)
	compute_field(red_field)
	return

func compute_field(par:Node):
	for i in par.get_children():
		i.compute_field()
	return
