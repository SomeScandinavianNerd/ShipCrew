extends CharacterBody2D

var active:bool = true

func _ready():
	Rutebil.plrRole.connect(setActive.bind())

func setActive(role):
	if role == "bridge":
		active = true

func _physics_process(delta):
	if Input.is_anything_pressed():
		if  active == false:
			return
		if Input.is_action_pressed("forward"):
			velocity = velocity + transform.basis_xform(Vector2(0, -PlrShip.f_speed))
		if Input.is_action_pressed("backward"):
			velocity = velocity + transform.basis_xform(Vector2(0, PlrShip.b_speed))
		if Input.is_action_pressed("turn_r"):
			self.rotate(PlrShip.turn_speed)
		if Input.is_action_pressed("turn_l"):
			self.rotate(-PlrShip.turn_speed)
		if Input.is_action_pressed("strafe_l"):
			self.move_local_x(-PlrShip.s_speed)
		if Input.is_action_pressed("strafe_r"):
			self.move_local_x(PlrShip.s_speed)
		
	move_and_slide()
