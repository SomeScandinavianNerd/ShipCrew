extends CharacterBody2D

signal moving(directions:Array, glob_velocity:Vector2, momentum:Vector2)

var active:bool = false
var maxSensorRange:int = 200
var dampening:bool = true

@onready
var shape:Polygon2D = $ShipShape
@onready
var collider:CollisionPolygon2D = $ShipCollider
@onready
var sensors:sensorArray = $SensorArray

##The length of the ship
var length:float = 5
##The width of the ship
var width:float = 2

func _ready():
	Rutebil.plrRole.connect(setActive.bind())
	var shapePoints:PackedVector2Array
	shapePoints.append(Vector2(width/2, length/-2))
	shapePoints.append(Vector2(width/2, length/2))
	shapePoints.append(Vector2(width/-2, length/2))
	shapePoints.append(Vector2(width/-2, length/-2))
	shape.polygon = shapePoints
	collider.polygon = shapePoints
	sensors.sensorRange = maxSensorRange
	#Connects the result of the sensors to the variables reporting back to the players.
	#This has to be done here, as doing it in the sensorarray itself, would make it harder to work with for NPCs.
	sensors.trackList.connect(reportTracking.bind())
	sensors.searchList.connect(reportSweep.bind())
	print(self)
	
	Rutebil.toggle.connect(toggles.bind())
	
	if "--freeControl" in OS.get_cmdline_args():
		active = true

func setActive(role):
	if role == "bridge":
		active = true

func _physics_process(delta):
	##An array of directions that are currently undergoing accelleration
	var accel:Array
	##A vector of the ship's acceleration on this frame (separate from the velocity)
	var acceleration:Vector2
	##A localized version of the object's velocity.
	var speed:Vector2 = transform.basis_xform_inv(velocity)
	if Input.is_anything_pressed():
		if  active == false:
			return
		if Input.is_action_pressed("forward"):
			acceleration.y = -PlrShip.f_speed
			accel.append("forward")
		if Input.is_action_pressed("backward"):
			acceleration.y = PlrShip.b_speed
			accel.append("backward")
		if Input.is_action_pressed("turn_r"):
			self.rotate(PlrShip.turn_speed)
		if Input.is_action_pressed("turn_l"):
			self.rotate(-PlrShip.turn_speed)
		if Input.is_action_pressed("strafe_l"):
			acceleration.x = -PlrShip.s_speed
			accel.append("left")
		if Input.is_action_pressed("strafe_r"):
			acceleration.x = PlrShip.s_speed
			accel.append("right")
	
	#Dampening is only applied, if it's actually supposed to be active.
	if dampening == true:
		if not ("forward" in accel or "backward" in accel):
			#If the ship isn't actively moving forward or backwards, dampens the y-axis
			if speed.y > 0 and speed.y > PlrShip.f_speed:
				acceleration.y -= PlrShip.f_speed
			elif speed.y < 0 and speed.y < -PlrShip.b_speed:
				acceleration.y += PlrShip.b_speed
			elif speed.y != 0:
				acceleration.y -= speed.y
		if not ("left" in accel or "right" in accel):
			#If the ship isn't actively strafing, apply the dampeners to the x-axis.
			if speed.x > 0 and speed.x > PlrShip.s_speed:
				acceleration.x -= PlrShip.s_speed
			elif speed.x < 0 and speed.x < -PlrShip.s_speed:
				acceleration.x += PlrShip.s_speed
			elif speed.x != 0:
				acceleration.x -= speed.x

	#Adds the acceleration to the ship velocity
	velocity = velocity + transform.basis_xform(acceleration)
	move_and_slide()


func reportTracking(contents:Array):
	Rutebil.detections.emit(contents, "tracking")

func reportSweep(contents:Array):
	Rutebil.detections.emit(contents, "searching")

func toggles(condition:String, state):
	if condition == "dampening":
		print("toggling dampener")
		if dampening == true:
			dampening = false
		else:
			dampening = true
