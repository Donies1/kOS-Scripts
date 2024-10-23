clearscreen.
wait until altitude >=28000.
wait 8.
set target to "(ocisly".
toggle brakes.
parameter landingsite is latlng(target:latitude,target:longitude).
set radarOffset to 37.
lock trueRadar to alt:radar - radarOffset.//this is all the suicide burn calculation					
lock g to constant:g * body:mass / body:radius^2.			
lock maxDecel to (ship:availablethrust / ship:mass) - g.	
lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		
lock idealThrottle to stopDist / trueRadar.					
lock impactTime to trueRadar / abs(ship:verticalspeed).	
lock aoa to 30. //the mazimum angle you want your ship to angle itself at to move the impact position towards the landingsite.
lock errorScaling to 1.                                               //all the functions are here
function getImpact {
    if addons:tr:hasimpact { return addons:tr:impactpos. }       //looks for the impact position given by Trajectories      
        return ship:geoposition.
}
function lngError {                                    //giving the lat and lng error values a vector so the ship can correct it for this.
    return getImpact():lng - landingsite:lng.
}
function latError {
    return getImpact():lat - landingsite:lat.
}

function errorVector {
    return getImpact():position - landingSite:position.
}

function getSteering {            //the function for steering is here, the functions and vectors are calculated here and used elsewhere.
    
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
RCS on.
lock steering to srfretrograde.
set boat to latlng(target:latitude,target:longitude).
addons:tr:SETTARGET(boat).
lock impact to addons:tr:impactpos.
lock dif to (boat:lng-ship:longitude).
wait until dif <=.75.
lock steering to srfretrograde + R(0,3,0).
lock throttle to 1.
print "Stage 1 Entry burn startup".
toggle ag1.
toggle ag2.
wait until (impact:lng - boat:lng) <= .1.
lock throttle to 0.
print "Stage 1 Entry burn shutdown".
lock steering to getSteering().
lock aoa to 20.
print "Performing glide maneuver".

wait until  alt:radar < 10000.
lock aoa to 15.

wait until  alt:radar < 7000. 
toggle ag1.
rcs off.
lock aoa to 10.

when  alt:radar < 4000 then { 
lock aoa to 7.
}

when impactTime < 3.5 then {gear on.} 

WAIT UNTIL trueRadar < stopDist.
    lock throttle to idealThrottle.
	print "Performing hoverslam".
    lock aoa to 7. 
    lock steering to getSteering().
     when alt:radar <= 1200 then { lock aoa to -10. }
    when alt:radar <= 400 then { lock aoa to -3. }
 when alt:radar <=90 then { 
 lock steering to up.
 }
   
WAIT UNTIL ship:status = "landed".
    print "The Falcon has landed".
	set ship:control:pilotmainthrottle to 0.