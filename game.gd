extends Node3D

var playerRole:String

func _ready():
	# Preconfigure game.

	Networker.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game():
	pass
	# All peers are ready to receive RPCs in this scene.
