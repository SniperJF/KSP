//START OF SCRIPT:
//Script to Launch our Columbia Space Shuttle to Orbit!
//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.
PRINT "RUNNING SCRIPT COMRADE CAPTAIN!".

set m1 to SHIP:PARTSDUBBED("merlin1")[0].
set m2 to SHIP:PARTSDUBBED("merlin2")[0].
set m3 to SHIP:PARTSDUBBED("merlin3")[0].
set m4 to SHIP:PARTSDUBBED("merlin4")[0].
set m5 to SHIP:PARTSDUBBED("merlin5")[0].
set m6 to SHIP:PARTSDUBBED("merlin6")[0].
set m7 to SHIP:PARTSDUBBED("merlin7")[0].


PRINT "Radar:" AT (0,9). //for intel
PRINT ROUND(ALT:RADAR,0) AT (0,10). // prints altitude intel.
set groundRadarHeight to ALT:RADAR. 

//Create throttle variable and lock  to a 100% for launch.
set currThrottle TO 1.0.
RCS ON.
LOCK THROTTLE TO currThrottle.   // 1.0 is the max, 0.0 is idle.

//This is our countdown loop, which cycles from 10 to 0
PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown + " " AT (0,3).
    WAIT 1. // pauses the script here for 1 second.
}

STAGE. //LIFT OFF
PRINT "LIFTOFF!" AT (0,3).
SET steerHeading TO HEADING(90,90).
LOCK STEERING TO steerHeading.

UNTIL APOAPSIS > 90000 {
    PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16). // prints new number, rounded to the nearest integer.
    //We use the PRINT AT() command here to keep from printing the same thing over and
    //over on a new line every time the loop iterates. Instead, this will always print
    //the apoapsis at the same point on the screen.
	
    //For the initial ascent, we want our steering to be straight
    //up and rolled due east
    IF SHIP:VELOCITY:SURFACE:MAG >150 AND SHIP:VELOCITY:SURFACE:MAG < 250 {
        //This sets our steering 80 degrees up and yawed to the compass
        //heading of 90 degrees (east)
        SET steerHeading TO HEADING(90,80).

    //Once we pass 100m/s, we want to pitch down ten degrees
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 250 AND SHIP:VELOCITY:SURFACE:MAG < 350 {
        SET steerHeading TO HEADING(90,70).
        PRINT "Pitching to 70 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }.
}.	


PRINT "Staging" AT(0,15).
set currThrottle TO 0.0.
STAGE. //separate and then go horizontal to prepare for boostback.
WAIT 4.0. //Wait for rotation to start.
SET steerHeading TO HEADING(90,180).
WAIT 18.0.
set currThrottle TO 1.0. //Begin boostback burn
WAIT 10.0.
set currThrottle TO 0.0. //finish boostback burn
brakes on. //turn on aerobrakes
SET steerHeading TO HEADING(90,70).
WAIT 120.0.
SET steerHeading TO  SRFRETROGRADE.

PRINT "Altitude:" AT (0,17). // prints altitude intel.

//might want to switch this to radar so that would be groundRadarHeight+1890-110?
UNTIL ALT:RADAR < groundRadarHeight+1885-110{
//UNTIL SHIP:ALTITUDE < 1885{
	SET steerHeading TO  SRFRETROGRADE.
	PRINT ROUND(SHIP:ALTITUDE,0) AT (0,18). // prints altitude intel.
	//keep waiting
}.

UNTIL SHIP:VELOCITY:SURFACE:MAG < 10{
	set currThrottle TO 1.0. //Begin landing burn
	PRINT ROUND(SHIP:ALTITUDE,0) AT (0,18). // prints altitude intel.
	SET steerHeading TO  SRFRETROGRADE.
}.

m1:shutdown.
m2:shutdown.
m3:shutdown.
m4:shutdown.
m5:shutdown.
m6:shutdown.
PRINT "Engine Shutdowns" AT (0,14). // prints altitude intel.

UNTIL ALT:RADAR < groundRadarHeight+3 {
//UNTIL SHIP:ALTITUDE < 115{
	PRINT ROUND(SHIP:ALTITUDE,0) AT (0,18). // prints altitude intel.
	SET steerHeading TO HEADING(90,90).
}.

set currThrottle TO 0.0. //Shutdown

//secure vehicle
brakes off. //turn on aerobrakes
RCS OFF.
m7:shutdown.
WAIT 10.0.

PRINT "Script Terminated".

//END OF SCRIPT
