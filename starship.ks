//kOS Script to perform SN15 Test Automatically by SniperJF.
//To run: place in your KSP Directory's Ships\Scripts then place SN15 in the launchpad
//and open the KAL 9000 and type:
//SWITCH TO 0.
//RUN starship.ks.

//SCRIPT BEGINS HERE:

//Variable Declarations (Raptors, Flaps, Radar, Thrust, Steering)
SET Raptor TO LIST(SHIP:PARTSDUBBED("Raptor1")[0], SHIP:PARTSDUBBED("Raptor2")[0], SHIP:PARTSDUBBED("Raptor3")[0]).
SET VacRaptor TO LIST(SHIP:PARTSDUBBED("VacuumRaptor1")[0], SHIP:PARTSDUBBED("VacuumRaptor2")[0], 
					  SHIP:PARTSDUBBED("VacuumRaptor3")[0]).
SET Flaps TO LIST(SHIP:PARTSDUBBED("FrontFlapLeft")[0], SHIP:PARTSDUBBED("FrontFlapRight")[0],
				  SHIP:PARTSDUBBED("RearFlapLeft")[0], SHIP:PARTSDUBBED("RearFlapRight")[0]).
SET RadarCalibrate TO ALT:RADAR. //Calibrate Ship
SET currSteering TO HEADING(90,90).
SET currThrottle TO 0.0.
SET RearFlapAngle TO 105.0.
SET FrontFlapAngle TO 105.0.
SET northPole TO latlng(90,0).


//Functions
function clearLine { 
	DECLARE PARAMETER P1 is 8.
	PRINT "                                                " AT (0,P1).
}.

function printTelemetry {
	DECLARE PARAMETER P1.
	DECLARE PARAMETER P2.
	DECLARE PARAMETER P3.
	PRINT "Telemetry:" AT (0,20).
	PRINT "ALTITUDE    " + ROUND(ALT:RADAR-P1,0) + " meters." AT (0,21).
	PRINT "VEL ORBITAL " + ROUND(SHIP:VELOCITY:ORBIT:X,2) AT (0,22).
	PRINT ROUND(SHIP:VELOCITY:ORBIT:Y,2) AT (21,22).
	PRINT ROUND(SHIP:VELOCITY:ORBIT:Z,2) AT (30,22).
	PRINT "VEL SURFACE " + ROUND(SHIP:VELOCITY:SURFACE:X,2) AT (0,23).
	PRINT ROUND(SHIP:VELOCITY:SURFACE:Y,2) AT (21,23).
	PRINT ROUND(SHIP:VELOCITY:SURFACE:Z,2) AT (30,23).
	PRINT "VERT SPEED  " + ROUND(SHIP:VERTICALSPEED,3) AT (0,24).
	PRINT "FFLAP Angle " + ROUND(Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):GETFIELD("current angle"),3) AT (0,25).
	PRINT P2 AT (24,25).
	PRINT "RFLAP Angle " + ROUND(Flaps[2]:GETMODULE("ModuleRoboticServoHinge"):GETFIELD("current angle"),3) AT (0,26).	
	PRINT P3 AT (24,26).
	PRINT "PITCH       " + ROUND((90.0 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR)),3) AT (0,27).
	PRINT "ANGULAR MOM " + ROUND(SHIP:ANGULARMOMENTUM:X,2) AT (0,28).
	PRINT ROUND(SHIP:ANGULARMOMENTUM:Y,2) AT (21,28).
	PRINT ROUND(SHIP:ANGULARMOMENTUM:Z,2) AT (30,28).	
	PRINT "LATITUDE    " + ROUND(SHIP:LATITUDE,4) AT (0,29). // SHIP:GEOPOSITION
	PRINT "LONGITUDE   " + ROUND(SHIP:LONGITUDE,4) AT (0,30).
	PRINT "Current TWR " + ROUND((SHIP:AVAILABLETHRUST/(SHIP:MASS*BODY:MU/(ALT:RADAR-P1+BODY:RADIUS)^2)),3) AT (0,31).
	PRINT "Thrust: " + ROUND(SHIP:AVAILABLETHRUST,1) AT (20,31).
}.

//Mini Functions/Macros
LOCK currPitch TO (90.0 - vectorangle(UP:FOREVECTOR, FACING:FOREVECTOR)). //0-90 up, -90 to 0 down
				  
//Initial Printing
CLEARSCREEN.
PRINT "kOS Operating System" AT (0,0).
PRINT "KerboScript v1.3.2.0" AT (0,1).
//PRINT "Skynet Defense Systems are now Activated..." AT (0,2).
SET Skynet TO LIST("S","k","y","n","e","t"," ","D","e","f","e","n","s","e"," ",
				   "S","y","s","t","e","m"," ","i","s"," ","n","o","w",
				   " ","A","c","t","i","v","a","t","e","d",".",".",".").
SET i TO 0.
FOR var in Skynet {
	PRINT var AT (i,2).
	SET i TO i+1.
	WAIT 0.03.
}.
PRINT "Executing Starship SN15 Launch Script" AT (0,4).
PRINT "Console Output:" AT (0,6).

//Starting Commands

//Flap Setup. 
//NOTE: For this flap stuff to work we need to have the Hinge windows open. That is not just us but apparently and
//Issue with KSP and kOS in general. This is only for reading angle data, not for setting it. So maybe we can get
//away with this issue if we just don't ever read the data.
PRINT "Folding Flaps to Launch Position of 105 Degrees." AT (0,8).
SET RearFlapAngle TO 0.0.
SET FrontFlapAngle TO 0.0.
FOR flap in Flaps {
	flap:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).
}.
UNTIL Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):GETFIELD("current angle") < 1 {
	PRINT "Current Angle: " + Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):GETFIELD("current angle") AT (0,9).
}.
WAIT 0.5.
PRINT "Current Angle: " + Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):GETFIELD("current angle") AT (0,9).
//Note: Use PRINT PARTVARIABLE:MODULES to see available modules, then use GETMODULE with the name of the one we want
WAIT 1.5.

clearLine(9).
PRINT "Performing Static Fire of Sea Raptor Engines.   " AT (0,8).
LOCK THROTTLE TO currThrottle.
STAGE.
FOR engine in Raptor {engine:ACTIVATE.}.
FOR engine in VacRaptor {engine:ACTIVATE.}.
set currThrottle TO 1.0.
WAIT 0.2.
set currThrottle TO 0.0.
FOR engine in VacRaptor {engine:SHUTDOWN.}.
WAIT 2.0.

PRINT "Test Successful. Starship is in Startup Mode." AT (0,8).
PRINT "Enabling RCS. Locking Steering." AT (0,9).
SAS OFF.
RCS ON.
LOCK STEERING TO currSteering.
WAIT 2.0.

clearLine(8).
clearLine(9).
PRINT "Initating Final Count." AT (0,8).
PRINT "10, " AT (5,9).
SET i TO 9.
set j TO 9.
UNTIL i < 0 {
	WAIT 0.3.
	PRINT i + ", " AT (j,9).
	SET j TO j+3.
	SET i TO i-1.
}.
PRINT "WE HAVE LIFTOFF!!" AT (0,10). //Raptor Jesus Please Keep US Safe.
SET currSteering TO HEADING(0,90).
set currThrottle TO 1.0.

WAIT 0.5.
clearLine(8).
clearLine(9).
WAIT 0.6.
clearLine(10).
PRINT "All Telemetry is nominal...." AT (0,8).
UNTIL ALT:RADAR-RadarCalibrate > 5000 {
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET currSteering TO HEADING(0,90).
}.

PRINT "Shutting down one Raptor, Leaving two on." AT (0,8).
Raptor[0]:SHUTDOWN.
UNTIL ALT:RADAR-RadarCalibrate > 7500 {
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET currSteering TO HEADING(0,90).
	IF ALT:RADAR > 6000 { //Tiny correction so we pull back a little bit
		SET currSteering TO HEADING(0,97).
	}
}.

PRINT "Shutting down second Raptor, Leaving one on." AT (0,8).
Raptor[1]:SHUTDOWN.
UNTIL ALT:RADAR-RadarCalibrate > 9999 {
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET currSteering TO HEADING(0,97).
	IF ALT:RADAR-RadarCalibrate > 9900 {
		SET currSteering TO HEADING(0,90).
	}
}.

PRINT "Shutting down last Raptor." AT (0,8).
Raptor[2]:SHUTDOWN.
WAIT 0.25.
SET currSteering TO HEADING(0,0).
//Initial Flap Deploy
SET FrontFlapAngle TO 43.0.
SET RearFlapAngle TO 80.0.
Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
Flaps[1]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
Flaps[2]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).
Flaps[3]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).

PRINT "Beginning belly flop maneuver. Extending Flaps." AT (0,9).

SET prevPitch TO currPitch. 
UNTIL ALT:RADAR-RadarCalibrate < 2150 {
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET currSteering TO HEADING(0,0).
	WAIT 0.1.

	IF ALT:RADAR < 10000 { //autopilot :D (active under 10.0km)
		clearLine(9).
		PRINT "Flap Autopilot is now active. Coasting.....      " AT (0,8).
		//We are going to keep the nose as folded as possible and focus mostly on the aft flaps
		//So the ratio is 1:4 movement of the front. We'll see how she handles.
		//We need to have a way of detecting if we are correcting pitch so we stop moving
		//so we check previous pitch and if we are going in the right direction then we just 
		//keep everything the same and see if it fixes itself.
	
		//currPitch < prevPitch: if nose is lower than before we really need to pull up
		IF currPitch < -1 AND currPitch < prevPitch { //1 degree we can handle
			//nose is getting too low so raise it (raise nose, lower tail)
			IF FrontFlapAngle < 50 { //Safety limit
				SET FrontFlapAngle TO FrontFlapAngle + 0.25.
			}
			IF RearFlapAngle > 10 { //Safety limit
				SET RearFlapAngle TO RearFlapAngle - 1.
			}
			PRINT "Pitching Up...  " AT (0,9).
			
		}//currPitch > prevPitch: if nose is higher than before we really need to lower it
		ELSE IF currPitch > 1 AND currPitch > prevPitch { //basically just let it be if its between -1 and 1 
			//tail is getting too low so raise it (lower nose, raise tail)
			IF FrontFlapAngle > 35 { //Safety limit
				SET FrontFlapAngle TO FrontFlapAngle - 0.25.
			}
			IF RearFlapAngle < 102 { //Safety limit
				SET RearFlapAngle TO RearFlapAngle + 1.
			}
			PRINT "Pitching Down..." AT (0,9).
		}
			SET prevPitch TO currPitch. 
			Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
			Flaps[1]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
			Flaps[2]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).
			Flaps[3]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).	
	}  
}.

clearLine(8).
clearLine(9).
PRINT "Landing Engine Startup" AT (0,8). //Turn on All Raptors.
Raptor[1]:ACTIVATE.
SET currSteering TO  SRFRETROGRADE.
WAIT 0.3.
printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
//Full Deploy Fore Flaps and Fold Aft Flaps for flip
SET FrontFlapAngle TO 105.0. 
Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
Flaps[1]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
SET RearFlapAngle TO 0.0.
Flaps[2]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).
Flaps[3]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", RearFlapAngle).
WAIT 0.3.
Raptor[2]:ACTIVATE.
WAIT 0.3.
Raptor[0]:ACTIVATE.
SET flapFolded TO false.
UNTIL SHIP:VERTICALSPEED > -32{

	IF not flapFolded AND currPitch < 75 { //Flip Success!
		SET FrontFlapAngle TO 0.0. //Fold Fore flaps
		Flaps[0]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
		Flaps[1]:GETMODULE("ModuleRoboticServoHinge"):SETFIELD("target angle", FrontFlapAngle).
		clearLine(8).
		SET folded TO true.
	}
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET currSteering TO SRFRETROGRADE.
}.
clearLine(8).
//Raptor[0]:SHUTDOWN.

PRINT "Final Landing Autopilot Active." AT (0,8). //Final Landing Computations
SET g To 9.81. //Acceleration due to gravity. 
//See https://www.reddit.com/r/Kos/comments/3yz3pf/throttling_to_maintain_a_twr/
SET goalTWR TO 4.0.
LOCK THROTTLE TO goalTWR * SHIP:MASS * g / SHIP:AVAILABLETHRUST.
UNTIL ALT:RADAR-RadarCalibrate < 10 { // So until we about to touch down
	IF ALT:RADAR-RadarCalibrate < 25 {
		IF SHIP:VERTICALSPEED > -2
			SET goalTWR TO 0.9.
		ELSE IF SHIP:VERTICALSPEED > -5
			SET goalTWR TO 1.0.
		ELSE{
			SET goalTWR TO 1.1.
		}
	}
	ELSE IF ALT:RADAR-RadarCalibrate < 130 AND SHIP:VERTICALSPEED < -10{
		SET goalTWR TO 1.6.
	}
	ELSE {
		SET goalTWR TO 1.0.
	}
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	IF ALT:RADAR-RadarCalibrate > 200 {
		SET currSteering TO SRFRETROGRADE.
	}
	ELSE {
		SET steerHeading TO HEADING(0,90).
	}
}.
LOCK THROTTLE TO 1.0.
Raptor[1]:SHUTDOWN.
Raptor[2]:SHUTDOWN.
UNTIL ALT:RADAR-RadarCalibrate < 2 {
	printTelemetry(RadarCalibrate, FrontFlapAngle, RearFlapAngle). //Prints Telemetry
	SET steerHeading TO HEADING(0,90).
}.
WAIT 0.1.
Raptor[0]:SHUTDOWN.
WAIT 1.0.
clearLine(8).
PRINT "GG ez" AT (0,8).
WAIT 3.0.

//Shutdown All Engines
FOR engine in Raptor {engine:SHUTDOWN.}.
FOR engine in VacRaptor {engine:SHUTDOWN.}.
RCS OFF.
PRINT "Script Terminated" AT (0,35).




