//set all coordinates to your landing site
//Action group 1 activates flaps
clearscreen.

parameter landingsite is latlng(-0.205731332302094, -74.4730758666992).
set lz to latlng(-0.205731332302094, -74.4730758666992).
set radarOffset to 26.
lock trueRadar to alt:radar - radarOffset.
lock g to constant:g * body:mass / body:radius^2.			
lock maxDecel to (ship:availablethrust / ship:mass) - g.	
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.					
lock impactTime to trueRadar / abs(ship:verticalspeed).	
lock aoa to 0. 
lock errorScaling to 1.
function getImpact {
    if addons:tr:hasimpact { return addons:tr:impactpos. }      
        return ship:geoposition.
}
function lngError {                                    
    return getImpact():lng - landingsite:lng.
}
function latError {
    return getImpact():lat - landingsite:lat.
}

function errorVector {
    return getImpact():position - landingSite:position.
}


function getSteering {     
	set dir to latlng(-0.205731332302094, -74.4730758666992):altitudeposition(alt:radar).         
    local errorVector is errorVector().
        local velVector is -ship:velocity:surface.
        local result is velVector + errorVector*errorScaling.
        if vang(result, velVector) > aoa
        {
            set result to velVector:normalized
                          + tan(aoa)*errorVector:normalized.
        }

        return lookdirup(result, facing:topvector).
    }

function dolaunch {
	stage.
	lock steering to up + R(0,0,180).
	lock throttle to 1.
	print "launch".
	wait until apoapsis >= 10000.
	lock throttle to 0.
	wait until eta:apoapsis <=5.
	doflip().
}

function doflip {
	print "flipping".
	set dir to latlng(-0.205731332302094, -74.4730758666992):altitudeposition(alt:radar).
	lock steering to lookDirUp(dir,up:vector).
	toggle rcs.
	toggle ag1.
	toggle ag2.
	wait until vAng(ship:facing:vector, dir) <=10.
	print "facing".
	lock steering to dir.
	print "flipped".
	wait 3.
	doflop().
}


function doPID {
	print "pid".
	local targetdifference is 0.01.
	lock impact to addons:tr:impactpos.
	addons:tr:SETTARGET(landingsite).
	set pitchPID to pidLoop(10000,0,1000,-200,400).
	set pitchPID:setpoint to targetdifference.
	set wantedpitch to 0.
	set dir to latlng(-0.205731332302094, -74.4730758666992):altitudeposition(alt:radar+wantedpitch).
	lock steering to lookDirUp(dir,up:vector).
	toggle ag2.
	
	UNTIL trueRadar < stopDist + 300 {
		set lnderror to (impact:lat-lz:lat).
		set wantedpitch to pitchPID:update(time:seconds,lnderror).
		print lnderror.
		set dir to latlng(-0.205731332302094, -74.4730758666992):altitudeposition(alt:radar+wantedpitch).
		lock steering to lookDirUp(dir,up:vector).
	}
}

function doflop {
	lock impact to addons:tr:impactpos.
	addons:tr:SETTARGET(landingsite).
	print "falling".
	lock steering to lookDirUp(dir,up:vector).
	dopid().

	wait until altitude <= 2900.
	WAIT UNTIL trueRadar < stopDist + 300.
	SHIP:CONTROL:ROLL.
    lock throttle to idealThrottle.
	print "throttle".
	doland().
}


function doland {
	print "landing".
	lock steering to getSteering().
	lock aoa to -7.
	wait until alt:radar <=100. {
	toggle rcs.
	print "steering up".
	lock steering to up.
	toggle gear.
	wait until altitude <=30.
	wait until ship:status = "landed".
	print "landed".
	doshutdown().
}
}

function doshutdown {
	print "shutdown".
	lock throttle to 0.
	lock steering to up.
	wait 5.
	toggle ag2.
	shutdown.
}

dolaunch().

