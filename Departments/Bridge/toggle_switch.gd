extends MeshInstance3D

var dampen:bool = true

func toggleDampen():
	Rutebil.toggle.emit("dampening", null)
	if dampen == true:
		dampen = false
		$dampener.rotation_degrees.z = -5
	else:
		dampen = true
		$dampener.rotation_degrees.z = 12

func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		toggleDampen()
