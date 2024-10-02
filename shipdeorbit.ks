//set action group 4 to deploy all 4 flaps
//set action group 3 to shut down Raptor Vacuum engines
//set action group 2 to activate LOX vent
//THIS IS UNFINISHED feel free to edit some values
clearscreen.

set radarOffset to 24.
lock trueRadar to alt:radar - radarOffset.
lock g to constant:g * body:mass / body:radius^2.			
lock maxDecel to (ship:availablethrust / ship:mass) - g.	
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.					
lock impactTime to trueRadar / abs(ship:verticalspeed).	
lock aoa to -7. 
lock errorScaling to 1.
function getImpact {
    if addons:tr:hasimpact { return addons:tr:impactpos. }      
        return ship:geoposition.
}


print "Initiating de-orbit burn.".
rcs on.
sas off.
lock steering to retrograde.
wait 15.
lock throttle to 1.
doburn().

function doburn {
    print "burning".
    wait until addons:tr:hasimpact.
    wait 20.
    lock throttle to 0.
    doreentry().
}

function doreentry{
    wait 2.
    lock steering to srfprograde + R(0,90,0).
    SHIP:CONTROL:ROLL.
    toggle ag4.
    toggle ag3.
    toggle ag2.
    wait until ship:oxidizer <= (2549).
    toggle ag2.
    wait until alt:radar <=10000.
    doland().
}

function doland {
    WAIT UNTIL trueRadar < stopDist + 1500.
	SHIP:CONTROL:ROLL.
    lock throttle to idealThrottle.
	print "landing".
    lock steering to srfRetrograde.
	wait until alt:radar <=00. {
	print "steering up".
	lock steering to up.
	toggle gear.
	wait until alt:radar <=30.
	wait until ship:status = "landed".
	print "landed".
	doshutdown().
}
}
function doshutdown {
	print "shutdown".
    rcs on.
	lock throttle to 0.
	lock steering to up.
	wait 20.
	toggle ag2.
	shutdown.
}
