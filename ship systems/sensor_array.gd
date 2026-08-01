extends ShapeCast2D

class_name sensorArray

##The largest distance of any sensor detection. The radius of the overall shapecast
@export 
var sensorRange:int = 100
##The width of the cone used by the tracking sensors.
var trackerAngle:int = 20
##The amount of rotations performed by the 'line' of the search sensor each second.
var rotPerSec:float = 1

signal searchList(list:Array)
signal trackList(list:Array)
signal passives(list:Array)

##This scene is only ever supposed to exist as a child of a ship.
@onready
var parent:CharacterBody2D = self.get_parent()
##The Area2D used to determine what objects are currently being directly hit by the 'line' of the search sensor
@onready
var sweep:Area2D = $Sweeper
##The area (conical/triangular) used to determine whether a given object is within range of the active tracking sensors.
@onready
var tracker:Area2D = $Tracker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Here, a shape is assigned to the overall sensor array, using the max range.
	var ownShape:CircleShape2D = CircleShape2D.new()
	ownShape.radius = sensorRange
	shape = ownShape
	#The range of the active search is manually set to equate to the sensor radius
	var sweepLine:SegmentShape2D = SegmentShape2D.new()
	sweepLine.a = Vector2(0,0)
	sweepLine.b = Vector2(0, sensorRange)
	$Sweeper/Ray.shape = sweepLine
	
	#Here I set up the cone used for the active tracking. 
	var trackCone:PackedVector2Array = $Tracker/TrackerCone.polygon.duplicate()
	trackCone.clear()
	trackCone.append(Vector2(0,0))
	#Mein Gott. I have found the real world use for trigonometry. Math teachers around the world rejoice
	var width:int = round(tan(trackerAngle/2)*sensorRange)
	trackCone.append(Vector2(-width, -sensorRange))
	trackCone.append(Vector2(width, -sensorRange))
	$Tracker/TrackerCone.polygon = trackCone


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#For performance reasons, these calculations are only run when there is an object within sensor range.
	if collision_result != []:
		##All objects detected by the searching sensors
		var searched:Array = []
		##All objects currently in range of the tracking sensors
		var tracked:Array = []
		##All objects that are only showing up on the passive sensors.
		var other:Array = []
		for entity:Dictionary in collision_result:
			#Order of operations: first, check if an entity is actively being tracked.
			if entity["collider"] in tracker.get_overlapping_bodies():
				#This adds the position of the entity, relative to the ship
				var relPoint:Vector2 = parent.position - entity["point"]
				#This converts that position to a 'percentage' of sorts, that can be used in various sensor displays
				relPoint = relPoint / sensorRange
				#And this ensures that said position is going to be localized
				entity["relPoint"] = relPoint.rotated(parent.rotation*-1)
				tracked.append(entity)
			#Failing that, check if it shows up on the search radar.
			elif entity["collider"] in sweep.get_overlapping_bodies():
				var relPoint:Vector2 = parent.position - entity["point"]
				relPoint = relPoint / sensorRange
				entity["relPoint"] = relPoint.rotated(parent.rotation*-1)
				searched.append(entity)
			#TODO: Ensure that an entity can be detected via passive sensors. 
		searchList.emit(searched)
		trackList.emit(tracked)
	else:
		searchList.emit([])
		trackList.emit([])
