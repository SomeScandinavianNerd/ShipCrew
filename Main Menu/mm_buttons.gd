extends VBoxContainer

var host:Button
var join:Button
var options:Button
var exit:Button
var jMenu:Panel

func _ready():
	host = $"host game"
	join = $"join Game"
	options = $Options
	exit = $Exit
	jMenu = get_parent().find_child("JoinMenu")
	
	exit.pressed.connect(closeGame)
	host.pressed.connect(setupGame)
	join.pressed.connect(joinGame)

func setupGame():
	Rutebil.createLobby.emit()

func joinGame():
	jMenu.visible = true

func closeGame():
	get_tree().quit()
