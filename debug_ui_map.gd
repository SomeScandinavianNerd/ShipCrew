extends CanvasLayer

@onready
var dir_display:Label = $Directions

func _on_plr_ship_moving(directions: Array, vel:Vector2, momentum:Vector2) -> void:
	dir_display.text = (str(directions) + "\nVelocity: "+str(vel)+"\nMomentum: "+str(momentum))
	
