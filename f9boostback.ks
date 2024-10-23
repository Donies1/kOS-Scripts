clearscreen.
wait until altitude >=23500.
wait 5.
set radarOffset to 33.
parameter landingsite is latlng(-0.185385927557945,-74.4728393554688).
set lz1 to latlng(-0.185385927557945,-74.4728393554688).
lock aoa to 20.
lock trueRadar to alt:radar - radarOffset.				
lock g to constant:g * body:mass / body:radius^2.			
lock maxDecel to (ship:availablethrust / ship:mass) - g.	
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.					
lock impactTime to trueRadar / abs(ship:verticalspeed).	
lock errorScaling to 1.                                              
function getImpact {
    set landingsite to latlng(-0.185385927557945,-74.4728393554688).
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
    set radarOffset to 33.
    lock trueRadar to alt:radar - radarOffset.				
    lock g to constant:g * body:mass / body:radius^2.			
    lock maxDecel to (ship:availablethrust / ship:mass) - g.	
    lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
    lock idealThrottle to stopDist / trueRadar.					
    lock impactTime to trueRadar / abs(ship:verticalspeed).	
    lock errorScaling to 1.                                             
    set landingsite to latlng(-0.185385927557945,-74.4728393554688).
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
    set difference to (impact:lat - lz1:lat). 
         if difference > 0 {
        lock steering to heading(0,180).
        wait until vAng(ship:facing:vector, heading (0,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - lz1:lat) <= 0.000000001 then {
            lock throttle to 0.
         }
     } else if difference < 0 {
        lock steering to heading(180,180).
        wait until vAng(ship:facing:vector, heading (180,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - lz1:lat) >= 0.0000000001 then {
            lock throttle to 0.
         }
     }
}

function docorrection{
    dosteering().
    toggle brakes.
    print "correcting".
    print (impact:lat - lz1:lat).
    wait until throttle = 0.
    print (impact:lat - lz1:lat).
    lock throttle to 0.
    print "correction complete".
    doentry().
}

function dodescent {
    set lz1 to latlng(-0.185385927557945,-74.4728393554688).
    clearScreen.
    lock impact to addons:tr:impactpos.
    addons:tr:SETTARGET(lz1).
    wait 3.
    "descent started".
    toggle ag1.
    rcs on.
    lock throttle to .5.
    lock steering to heading (180,180).
    wait 2.
    lock steering to heading (90,180).
    wait until vAng(ship:facing:vector, heading(90,180):vector) <=20. {
        print "boostback".
        lock throttle to 1.
        wait 10.
    }
    wait until (impact:lng - lz1:lng) <= .1. 
    wait until (lz1:lng - impact:lng) >= .3. 
 lock throttle to 0.
  print "Boostback Complete".
 docorrection().
}

function doentry {
    print "entry started".
    lock steering to srfretrograde + R(0,3,0).
    print (lz1:lng - impact:lng).
    wait until altitude <=30000.
 lock throttle to 1.
 toggle ag3.
 wait until (lz1:lng - impact:lng) <= .2.
 print (lz1:lng - impact:lng).
 lock throttle to 0.
 lock steering to srfRetrograde.
 lock aoa to 20.
 wait until altitude <= 20000.
 doland().
}

function doland {
    toggle ag1.
    lock steering to getSteering().
  lock aoa to 20.
  wait until alt:radar < 12000.
 lock aoa to 20.
  
  when alt:radar < 7000 then {
    rcs off.
    lock aoa to 10.
  }

    wait until  alt:radar < 4000. 
    toggle ag3.
    lock aoa to 7.

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
 WAIT UNTIL alt:radar <=31.
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
