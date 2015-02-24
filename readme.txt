Author:	Lukas Schneider
Date:	14.2.2015

This are all files that make my Arma 3 mission 'Sling It' work.
I commented them a little so it's easier to split up the parts of the code.
A rough layout of the files:

-description.ext	Some generic mission info and all UI elements used by the dialog created with the setup.sqf
-init.sqf		The init.sqf arma executes before the briefing
 |_ initMission.sqf	A function to prepare editor markers before using them in all other files
 |_ moveComp.sqf	A function to move a 'composition' - a group of objects in their exact position as placed in the editor and
 |_ shuffleArray.sqf	A function to shuffle an array
-setup.sqf		The file that creates the UI element when called with the laptop in the mission and gives them their functionality