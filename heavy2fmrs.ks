//Controls right booster on falcon heavy
//Run this when using FMRS mod
//Run this when you have just decoupled from core, with the booster as the selected craft
//Must have trajectories mod to work
clearscreen.
set ship:control:pilotmainthrottle to 0.

set radarOffset to 25.
parameter landingsite is latlng(-0.150009542703629,-74.5591583251953).//YOUR LANDING POSITION HERE
set lz2 to latlng(-0.150009542703629,-74.5591583251953).
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



function dosteering{
    lock impact to addons:tr:impactpos.
    set difference to (impact:lat - lz2:lat). 
         if difference > 0 {
        lock steering to heading(0,180).
        wait until vAng(ship:facing:vector, heading (0,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - lz2:lat) <= 0.000000001 then {
            lock throttle to 0.
         }
     } else if difference < 0 {
        lock steering to heading(180,180).
        wait until vAng(ship:facing:vector, heading (180,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - lz2:lat) >= 0.0000000001 then {
            lock throttle to 0.
         }
     }
}

function docorrection{
    dosteering().
    print "correcting".
    print (impact:lat - lz2:lat).
    wait until throttle = 0.
    print (impact:lat - lz2:lat).
    lock throttle to 0.
    print "correction complete".
    doentry().
}

function dodescent {
    clearScreen.
    lock impact to addons:tr:impactpos.
    addons:tr:SETTARGET(lz2).
    "descent started".
    toggle ag7.
    toggle ag5.
    rcs on.
    lock throttle to .5.
    lock steering to heading (0,180).
    wait 2.
    lock steering to heading (90,180).
    wait until vAng(ship:facing:vector, heading(90,180):vector) <=20. {
        print "boostback".
        lock throttle to 1.
        wait 10.
    }
    wait until (impact:lng - lz2:lng) <= .1. 
    wait until (lz2:lng - impact:lng) >= .5. 
 lock throttle to 0.
 docorrection().
 print "Boostback Complete".
}

function doentry {
    print "entry started".
    lock steering to srfretrograde + R(0,3,0).
    print (lz2:lng - impact:lng).
    wait until altitude <=30000.
 lock throttle to 1.
 toggle ag6.
 wait until (lz2:lng - impact:lng) <= .2.
 print (lz2:lng - impact:lng).
 lock throttle to 0.
 toggle brakes.
 lock steering to srfRetrograde.
 lock aoa to 20.
 wait until altitude <= 20000.
 doland().
}

function doland {
    print "landing started".
    lock steering to getSteering().
  lock aoa to 20.
  wait until alt:radar < 12000.
 lock aoa to 20.
  
  when alt:radar < 7000 then {
    rcs off.
    lock aoa to 15.
  }

  
 toggle ag5.
 when impactTime < 3.5 then {gear on.} 
 wait until  trueRadar < stopDist. {
 lock throttle to idealThrottle.
	 print "Performing hoverslam".
     lock aoa to 15.	
     lock steering to getSteering().
     when alt:radar <= 1300 then { lock aoa to -10. }
     when alt:radar <= 800 then { lock aoa to -3. }
 when alt:radar <=100 then { 
 lock steering to up.
 }
 WAIT UNTIL ship:status = "Landed".
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

dodescent().
