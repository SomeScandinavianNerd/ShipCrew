extends Node
##Risk of a system failing to run, if it misfires
var sysFail_failRisk:Array = [10, 75]
##Risk of a system getting deactivated on a misfire
var sysFail_shutdownRisk:Array = [30, 23]
##Risk of a system taking damage on a misfire
var sysFail_dmgRisk:Array = [40, 1]
##Risk of a system getting completely destroyes on a misfire
var sysFail_destroyRisk:Array = [20, 1]

var blowBackMax:float = 0.1
