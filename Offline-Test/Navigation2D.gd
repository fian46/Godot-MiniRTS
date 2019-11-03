extends Navigation2D

func _ready():
	var np = NavigationPolygon.new()
	np.add_outline($Polygon2D.polygon)
	np.make_polygons_from_outlines()
	navpoly_add(np, Transform2D(0, Vector2.ZERO))
	$Polygon2D.visible = false
	global.nav = self
	pass