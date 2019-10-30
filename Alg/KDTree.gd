extends Node

class node:
	var rule:int
	var dist:float
	var median:Array
	var left:node
	var right:node

static func create(points):
	return kdtree(points, 0)

static func nearest(tree:node, query:Array):
	return knn(tree, query, tree)

static func knn(tree:node, query:Array, best:node):
	if  not tree:
		return best
	
	tree.dist = distance(tree.median, query)
	
	if  not best:
		best = tree
	else:
		if  best.dist > tree.dist:
			best = tree
	
	var good:node = null
	var bad :node = null
	
	if  query[tree.rule] < tree.median[tree.rule]:
		good = tree.left
		bad = tree.right
	else:
		good = tree.right
		bad = tree.left
	
	if  good:
		var best_good:node = knn(good, query, best)
		if  best.dist > best_good.dist:
			best = best_good
	if  bad:
		if  best.dist > pow(tree.median[tree.rule] - query[tree.rule], 2):
			var best_bad:node = knn(bad, query, best)
			if  best.dist > best_bad.dist:
				best = best_bad
	return best

static func distance(a:Array, b:Array):
	return pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2)

static func kdtree(points:Array, level:int) -> node:
	if  points.size() == 0:
		return null
	
	var n = node.new()
	
	if  level % 2 == 0:
		points.sort_custom(csort, "sort_x")
		n.rule = 0
	else:
		points.sort_custom(csort, "sort_y")
		n.rule = 1
	
	var med = int(points.size() / 2)
	var left = []
	for i in range(0, med):
		left.append(points[i])
	var right = []
	for i in range(med + 1, points.size()):
		right.append(points[i])
	
	n.median = points[med]
	n.left = kdtree(left, level + 1)
	n.right = kdtree(right, level + 1)
	return n

class csort:
	static func sort_x(a, b):
		return a[0] < b[0]
	static func sort_y(a, b):
		return a[1] < b[1]