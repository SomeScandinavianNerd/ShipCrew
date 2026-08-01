extends Node

signal createLobby

signal updtPlrs

signal plrRole(role:String)

signal detections(pings:Array, type:String)

##'Condition' is the thing to be toggled. 'State' is optional, in the sense that not all functions use it. It's solely so you have the option of passing along a specific bool, if the need arises.
signal toggle(condition:String, state)
