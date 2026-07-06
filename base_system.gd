##A base class for the creation of any ship systems
@abstract class_name base_system 
##The integrity (Hitpoints of a given component)
var hp:int
##The The upper lmit for the system's hitpoints
var maxHP:int
##Determines whether the system is enabled or not. 
var enabled = true
##Contains the variables used in heat generation
var heat:Dictionary = {
		"generation" = 0,
		"continous" = true
}
##Contains the variables used in power draw
var power:Dictionary = {
		"generation" = 0,
		"continous" = true
}

func attemptMisfire():
	##The hitpoints of the system, in percentage. 
	var integrity:float = hp/maxHP
	var percentRoll:float = randf_range(0.01, 1)
	if percentRoll > integrity:
		## A normalized version of the system's integrity value
		var normInteg:float = (integrity-0.01) / (0.99-0.01)
		#Sets up the variables used for determining the type of system failure.
		var jamRisk = Gamerules.sysFail_failRisk[0]+((Gamerules.sysFail_failRisk[1] - Gamerules.sysFail_failRisk[0]) / normInteg)
		var shutRisk = jamRisk+Gamerules.sysFail_shutdownRisk[1]+((Gamerules.sysFail_shutdownRisk[0] - Gamerules.sysFail_shutdownRisk[1]) / 1-normInteg)
		var blowbackRisk = shutRisk+Gamerules.sysFail_dmgRisk[1]+((Gamerules.sysFail_dmgRisk[0] - Gamerules.sysFail_dmgRisk[1]) / 1-normInteg)
		var destroyRisk = blowbackRisk+Gamerules.sysFail_destroyRisk[1]+((Gamerules.sysFail_destroyRisk[0] - Gamerules.sysFail_destroyRisk[1]) / 1-normInteg)
		##A roll to determine what kind of failure happens
		var failureRoll:float = randf_range(0, 1)
		
		if failureRoll <= jamRisk:
			pass
		elif failureRoll <= shutRisk:
			enabled = false
		elif failureRoll <= blowbackRisk:
			var bbDamage = round(maxHP*randf_range(0.01, Gamerules.blowBackMax))
			damage(bbDamage)
		else:
			damage(hp)
		
		return true

func damage(amount:int):
	hp -= amount
	if hp <= 0:
		hp = 0
		enabled = false

##An abstract for the creation of any internal systens (i.e. inside the ship)
@abstract class sys_internal extends base_system:
	var section:int

##The core systems of the ships, such as the engine and the reactor
@abstract class core extends sys_internal:
	pass

##Various storage systems, such as cargo bays and drone hubs
@abstract class storage extends sys_internal:
	var capacity:int

##Catch-all group for all manner of subsystems and arbitrary gadgets.
@abstract class utility extends sys_internal:
	var connection = null

##An abstract used for the creation of external systems (i.e. on the outside of the hull)
@abstract class sys_external extends base_system:
	var location:String

##An abstract used for the creation of any weapon platforms.
@abstract class base_weapon extends sys_external:
	var range:int
	var burst:int
	var reload:float
	var energy: bool

##An abstract used for the creation of any external sensors
@abstract class base_sensor extends sys_external:
	var range:int

##An abstract used for the creation of any external defensive systems
@abstract class defense extends sys_external:
	pass
