extends Node3D
##What object is currently being focused on by the camera
var focus:String = "null"
##Whether or not the camera is currently moving in a specific direction
var moving:bool = false
##Whether or not the holographic map is enabled.
var mapEnabled:bool = false

@onready
var camPath:PathFollow3D = $CamPath/PathFollow3D

@export
var mapScene:String

@onready
var fullMap:Node2D = load(mapScene).instantiate()

func _ready() -> void:
	$SubViewport.add_child(fullMap)
	$SubViewport.CLEAR_MODE_ONCE
	var mapView = $SubViewport.get_texture()
	var killMe:Material = StandardMaterial3D.new()
	killMe.albedo_texture = mapView
	$WorldMap.material_override = killMe

func _physics_process(delta: float) -> void:
	if moving == true:
		if focus == "null":
			camPath.progress_ratio = camPath.progress_ratio - 0.05
			if camPath.progress_ratio == 0:
				moving = false
		elif focus == "sensors":
			camPath.progress_ratio = camPath.progress_ratio + 0.05
			if camPath.progress_ratio == 1:
				moving = false

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action_pressed("focus"):
		if focus == "null":
			if mapEnabled == true:
				mapToggle()
			focus = "sensors"
			moving = true
		elif focus == "sensors":
			focus = "null"
			moving = true
	elif event.is_action_pressed("map"):
		mapToggle()

func mapToggle():
	focus = "null"
	if camPath.progress_ratio != 0:
		moving = true
	if mapEnabled == true:
		mapEnabled = false
		$WorldMap.visible = false
	else:
		$WorldMap.visible = true
		mapEnabled = true
