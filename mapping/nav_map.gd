extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var setPoint:Vector2 = Vector2(0,300)
	##A temporary array, used for constructing the circle
	var tempArray:PackedVector2Array = polygon.duplicate()
	for i in range (0, 8):
		tempArray.append(Vector2(setPoint.x, setPoint.y))
		setPoint = setPoint.rotated(deg_to_rad(45))
	polygon = tempArray
	print(polygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
