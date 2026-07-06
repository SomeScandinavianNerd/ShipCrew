extends Panel

var jButton:Button
var cButton:Button
var ip:LineEdit
var plrname:LineEdit


func _ready():
	jButton = $Cont/Buttons/Join
	cButton = $Cont/Buttons/Cancel
	plrname = $Cont/plrname
	ip = $Cont/IP_line
	cButton.pressed.connect(cancel)
	jButton.pressed.connect(join)

func cancel():
	ip.text = ""
	self.visible = false

func join():
	var adress = ip.text
	Networker.player_info["name"] = plrname.text
	Networker.join_game(adress)
