clearscreen.
set ship:control:pilotmainthrottle to 0.
wait 5.
set target to "FullStack Base".
set tower to latlng(target:latitude,target:longitude).
set radarOffset to 60.
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

function doland{
     print "landing started".
    lock steering to getSteering().
  lock aoa to 30.
  wait until alt:radar < 12000.
 lock aoa to 30.
  
  when alt:radar < 7000 then {
    rcs off.
    lock aoa to 15.
  }
 when impactTime < 3.5 then {gear on.} 
 wait until  trueRadar < stopDist. {
 lock throttle to idealThrottle.
	 print "Performing hoverslam".
     lock aoa to 15.	
     lock steering to getSteering().
     when alt:radar <= 1600 then { lock aoa to -10. }
     when alt:radar <= 1300 then { lock aoa to -3. }
 when alt:radar <=800 then { 
 lock steering to up + R(0,0,270).
 }
 WAIT UNTIL altitude <= 85.
 doshutdown().
}
}

function dosteering{
    lock impact to addons:tr:impactpos.
    set difference to (impact:lat - tower:lat). 
         if difference > 0 {
        lock steering to heading(0,180).
        wait until vAng(ship:facing:vector, heading (0,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - tower:lat) <= 0.000000001 then {
            lock throttle to 0.
         }
     } else if difference < 0 {
        lock steering to heading(180,180).
        wait until vAng(ship:facing:vector, heading (180,180):vector) <=2.
        lock throttle to 1.
         when (impact:lat - tower:lat) >= 0.0000000001 then {
            lock throttle to 0.
         }
     }
}

function doboostback {
    lock impact to addons:tr:impactpos.
    set target to "FullStack Base".
    set tower to latlng(target:latitude,target:longitude).
    addons:tr:SETTARGET(tower).
    wait 3.
    "descent started".
    toggle ag1.
    wait .1.
    toggle ag1.
    rcs on.
    lock throttle to .5.
    lock steering to heading (90,180).
    wait until vAng(ship:facing:vector, heading(90,180):vector) <=20. {
        print "boostback".
        lock throttle to 1.
        wait 10.
    }
    wait until (impact:lng - tower:lng) <= .1. 
    wait until (tower:lng - impact:lng) >= .2. 
 lock throttle to 0.
 docorrection().
 print "Boostback Complete".
 lock aoa to 30.
}

function docorrection{
    dosteering().
    print "correcting".
    print (impact:lat - tower:lat).
    wait until throttle = 0.
    print (impact:lat - tower:lat).
    lock throttle to 0.
    print "correction complete".
    lock steering to srfRetrograde.
    wait until altitude <= 33000.
    stage.
    wait 2.
    stage.
    wait until altitude <= 20000.
    toggle ag2.
    doland().
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

wait until altitude >=21500.
doboostback().
set target to "FullStack Base".