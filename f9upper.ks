clearscreen.
set ship:control:pilotmainthrottle to 0.

Print "Beginning launch sequence...".
stage.
wait 5.
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



lock throttle to 1.
wait .3.
stage.
wait until altitude >= 200.
lock pitch to 90 - .8 * alt:radar^0.409511.
 set tdirection to 90.
 lock steering to heading(tdirection,pitch) + R(0,0,270).	

wait until altitude >= 23000.
lock throttle to 0.
wait 1.
stage.
wait 1.
stage.
wait 1.
lock throttle to .25.
wait 3.
lock throttle to .5.
wait 3.
lock throttle to 1.


when altitude >= 45000 then {
	stage.
	
}

wait until apoapsis >=100000.
lock throttle to 0.


wait until altitude >=60000.
stage.
rcs on.

wait until eta:apoapsis <=15.
lock steering to heading(90,0).
lock throttle to 1.
wait until periapsis >= (apoapsis - 5000).
lock throttle to 0.
set ship:control:pilotmainthrottle to 0.

