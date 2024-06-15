//Script for launching Falcon Heavy and landing the core booster. Run this at launch.

clearscreen.
set ship:control:pilotmainthrottle to 0.

set target to "boat".
set radarOffset to 35.
parameter landingsite is latlng(target:latitude,target:longitude).
lock trueRadar to alt:radar - radarOffset.					
lock g to constant:g * body:mass / body:radius^2.			
lock maxDecel to (ship:availablethrust / ship:mass) - g.	
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.					
lock impactTime to trueRadar / abs(ship:verticalspeed).	
lock aoa to 30. 
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
    lock throttle to 1.
    stage.
    toggle ag1.
    lock steering to up + R(0,0,90).
    wait until altitude >=750.
    lock pitch to 88.963 - 1.03287 * alt:radar^0.409511.
 set tdirection to 90.
 lock steering to heading(tdirection,pitch) + R(0,0,180).
    wait until altitude >= 12500. 
    wait until altitude >=16000.
    lock throttle to .5.
    doStage1().
}

function doStage1 {
    print "working".
    lock pitch to 88.963 - 1.03287 * alt:radar^0.409511.
 set tdirection to 90.
 lock steering to heading(tdirection,pitch) + R(0,0,180).
    lock throttle to .25.
    wait until missionTime >= 100.
    toggle ag2.
    stage.
    lock throttle to .75.
    wait until missionTime >= 136.
    lock throttle to 0.
    stage.   
    wait 10.
    dodescent().
}

function dodescent {
    clearScreen.
    "descent started".
    rcs on.
    set target to "boat".
    lock steering to heading (90,180).
    wait until vAng(ship:facing:vector, heading(90,180):vector) <=25.
 lock throttle to 1.
 print "Boostback".
 wait 11.7.
 lock throttle to 0.
 print "Boostback Complete".
 lock steering to srfretrograde.
 doentry().
}

function doentry {
    print "entry started".
    wait until altitude <=30000.
 lock throttle to 1.
 toggle ag3.
 toggle ag4.
 wait until ship:velocity:surface:mag <=700.
 lock throttle to 0.
 toggle brakes.
 rcs off.
 lock steering to getSteering().
 lock aoa to 30.
 wait until altitude <= 20000.
 doland().
}

function doland {
    print "landing started".
    lock steering to getSteering().
  lock aoa to 30.
  when alt:radar < 12000 then{
 lock aoa to 20.
  }
  when alt:radar < 7000 then {
 lock aoa to 15.
  }
    toggle ag4.
    when impactTime < 3.5 then {gear on.} 
    when  trueRadar < stopDist then {
     lock throttle to idealThrottle.
	 print "Performing hoverslam".
     
     lock aoa to 15.	
     lock steering to getSteering().
     when alt:radar <= 800 then { lock aoa to -10. }
    when alt:radar <= 150 then { lock aoa to -3. }
 when alt:radar <=70 then { 
 lock steering to up.
 }
 WAIT UNTIL ship:status = "landed".
 doshutdown().
}
}

function doshutdown {
 rcs on.
 lock steering to up.
 lock throttle to 0.
 wait until ship:velocity:surface:mag <=.3.
    print "The Falcon has landed".
	set ship:control:pilotmainthrottle to 0.
shutdown.
}

Print "Beginning launch sequence...".
toggle ag1.
wait 1.
print "5.".
wait 1.
print "4.".
wait 1.
print "3.".
wait 1.
print "2.".
wait 1.
print "1.".
wait 1.

dolaunch().

