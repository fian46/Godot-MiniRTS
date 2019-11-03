extends Node

var kdtree = load("res://Alg/KDTree.gd")
const rect:float = 30.0

var blue_elixir := 0
var red_elixir := 0

var skel = load("res://Character/Skeleton/Skeleton.tscn")
var arch = load("res://Character/Archer/Archer.tscn")
var nav:Navigation2D = null

var red_deck = [0, 1, 0, 1, 0, 1, 0, 1]
var blue_deck = [0, 1, 0, 1, 0, 1, 0, 1]

var card_map = {
	0 : [skel, 3, 10, 200, "Skeleton"],
	1 : [arch, 2, 90, 80, "Archer"]
}

var blue_card = -1
var red_card = -1

#debug information
var red = 0
var blue = 0

#menu information
var host = true

#name creation
var counter = 0
func ngen():
	counter += 1
	return str(counter)

func _ready():
	return

var map_blue = {}
var map_red = {}

var blue_tree = null
var red_tree = null

func clear_map():
	map_blue.clear()
	map_red.clear()
	blue_tree = null
	red_tree = null
	return

func build_tree():
	blue_tree = kdtree.create(build_points(map_blue))
	red_tree = kdtree.create(build_points(map_red))
	return

func build_points(map):
	var points = []
	for i in map.keys():
		var arr = map[i]
		var avg = Vector2()
		for i in arr:
			avg += i.position
		avg /= arr.size()
		points.append([avg.x, avg.y, arr])
	return points

func ikey(value):
	return int(round(fkey(value)))

func fkey(value:float):
	var hrect = rect * 0.5
	var absx = abs(value) + hrect
	var auxx = fmod(absx, rect)
	return ((absx - auxx) / rect) * sign(value)

func index_blue(id:Node2D):
	var k = key(id.position)
	if  not map_blue.has(k):
		var arr = []
		map_blue[k] = arr
		arr.append(id)
	else:
		map_blue[k].append(id)
	return

func key(pos):
	var x = ikey(pos.x)
	var y = ikey(pos.y)
	var k = str(x,",",y)
	return k

func index_red(id:Node2D):
	var k = key(id.position)
	if  not map_red.has(k):
		var arr = []
		map_red[k] = arr
		arr.append(id)
	else:
		map_red[k].append(id)
	return

func get_nearest_blue(pos):
	var near = kdtree.nearest(blue_tree, [pos.x, pos.y]) 
	if  near:
		return near.median[2]
	else:
		return []

func get_nearest_red(pos):
	var near = kdtree.nearest(red_tree, [pos.x, pos.y])
	if  near:
		return near.median[2]
	else:
		return []