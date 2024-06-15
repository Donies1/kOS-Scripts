//Script for controlling the Falcon Heavy upper stage. Pushes payload to orbit at 100000 meters. Run this at launch

clearScreen.

function doStage2 {
    print "stage 2".
    lock steering to srfPrograde.
    stage.
    lock throttle to .25.
    wait 2.
    lock throttle to 1.
    wait until altitude >=36000.
    lock steering to prograde.
    wait until  ship:apoapsis >=100000.
    lock throttle to 0.
    wait until altitude >= 60000.
    stage.
    rcs on.
}

function doCircularize {
    wait until eta:apoapsis <=15.
    lock steering to prograde.
    lock throttle to 1.
    wait until periapsis >= (apoapsis - 5000).
}

wait until missionTime >= 138.
doStage2().

doCircularize().
