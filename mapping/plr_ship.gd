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
	if Input.is_anything_pressed():
		if  active == false:
			return
		if Input.is_action_pressed("forward"):
			velocity = velocity + transform.basis_xform(Vector2(0, -PlrShip.f_speed))
			accel.append("forward")
		if Input.is_action_pressed("backward"):
			velocity = velocity + transform.basis_xform(Vector2(0, PlrShip.b_speed))
			accel.append("backward")
		if Input.is_action_pressed("turn_r"):
			self.rotate(PlrShip.turn_speed)
		if Input.is_action_pressed("turn_l"):
			self.rotate(-PlrShip.turn_speed)
		if Input.is_action_pressed("strafe_l"):
			velocity = velocity + transform.basis_xform(Vector2(-PlrShip.s_speed, 0))
			accel.append("left")
		if Input.is_action_pressed("strafe_r"):
			velocity = velocity + transform.basis_xform(Vector2(PlrShip.s_speed, 0))
			accel.append("right")
	if dampening == true:
		dampen(accel)
	move_and_slide()

func dampen(directions:Array):
	##I cannot be arsed to type out this whole thing every time I need a momentum reading
	var momentum:Vector2 = transform.basis_xform(velocity)
	#These four are honestly just a whole lot of the same. 
	var boosters:Array
	if "forward" not in directions:
		#The "backward not in directions"-part is important, to avoid doubling up on speed-boosts
		if momentum.y < 0 && "backward" not in directions:
			boosters.append("boosting back")
			if momentum.y > -PlrShip.b_speed:
				velocity = transform.basis_xform(Vector2(momentum.x, 0))
			else:
				velocity = velocity + transform.basis_xform(Vector2(0, PlrShip.b_speed))
	if "backward" not in directions:
		if momentum.y > 0 && "forward" not in directions:
			boosters.append("boosting forward")
			if momentum.y < PlrShip.f_speed:
				velocity = transform.basis_xform(Vector2(momentum.x, 0))
			else:
				velocity = velocity + transform.basis_xform(Vector2(0, -PlrShip.f_speed))
	if "left" not in directions:
		if momentum.x < 0 && "right" not in directions:
			boosters.append("boosting right")
			if momentum.x > -PlrShip.s_speed:
				velocity = transform.basis_xform(Vector2(0, momentum.y))
			else:
				velocity = velocity + transform.basis_xform(Vector2(PlrShip.s_speed, 0))
	if "right" not in directions:
		if momentum.x > 0 && "left" not in directions:
			boosters.append("boosting left")
			if momentum.x < PlrShip.s_speed:
				velocity = transform.basis_xform(Vector2(0, momentum.y))
			else:
				velocity = velocity + transform.basis_xform(Vector2(-PlrShip.s_speed, 0))
	moving.emit(boosters, velocity, momentum)


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
