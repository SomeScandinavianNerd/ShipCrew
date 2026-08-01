extends MeshInstance3D

@onready
var shipPoint:MeshInstance3D = $Playerblock

##The blips that are being actively tracked on the scanner
var trackedBlips:Dictionary = {}
##The 'stationary' blips on the scanner
var searchedBlips:Array = []

const trackBlip = preload("res://Departments/Bridge/Blippers/dynamicBlip.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Rutebil.detections.connect(populate_blips.bind())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate_blips(objects:Array, type:String):
	if type == "tracking":
		var keyList:Array = []
		for item:Dictionary in objects:
			##The name (collider) of the object being tracked.
			var objectName = item["collider"]
			#If a given item is already tracked, and appears on the scanner.
			##A 3D vector indicating the global 'up'. Used as a rotation axis, to avoid enlarging the already freakishly large lines of code in that segment.
			var up = Vector3(0, 1, 0)
			if objectName in trackedBlips.keys():
				var blip:MeshInstance3D = trackedBlips[objectName]
				#The Relative position we recieve is a Vector2, so it gets modified to line up with the central ship.
				blip.position = $Playerblock.position + Vector3(item["relPoint"].x*0.7, $Playerblock.position.y, item["relPoint"].y*0.7).rotated(up, deg_to_rad(90))
			else:
				trackedBlips[objectName] = trackBlip.instantiate()
				trackedBlips[objectName].position = $Playerblock.position + Vector3(item["relPoint"].x*0.7, $Playerblock.position.y, item["relPoint"].y*0.7).rotated(up, deg_to_rad(90))
				add_child(trackedBlips[objectName])
			
			keyList.append(objectName)
		for item in trackedBlips.keys():
			if item not in keyList:
				trackedBlips[item].queue_free()
				trackedBlips.erase(item)
	elif type == "searching":
		pass
