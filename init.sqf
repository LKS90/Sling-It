// Author:	Lukas Schneider
// Date:	14.2.2015

// Set up the variables for functions defined in external files
f_moveComp = compile preprocessFile "moveComp.sqf";
f_shuffleArray = compile preprocessFile "shuffleArray.sqf";
f_init = compile preprocessFile "initMission.sqf";

// Do some initialization of global variables
g_overcast = overcast;
g_time = daytime;
g_fog = fog;
g_cargoType = ["B_supplyCrate_F", "B_Slingload_01_Cargo_F"];
g_heliMarkers = ["s_m900Marker", "s_orcaMarker", "s_wildcatMarker", "s_ghosthawkMarker", "s_mohawkMarker", "s_taruMarker", "s_huronMarker"];

// Change the marker transparency in the mission
"s_repairMarker" setMarkerAlpha 0.6;
{_x setMarkerAlpha 0.5} forEach g_heliMarkers;

// the getCrate function: expects a 'vehicle' type and spawns it at the "s_base" marker placed in the editor, intended for crates - hence the name
f_getCrate = 
{
	_cargo = createVehicle [_this, getPosATL s_base, [], 0, "NONE"];
	_cargo
};

// the updateMarkers function: expects a number, the current weight, updates the markers to indicate whether they can carry the cargo
f_updateMarkers =
{
	{
		switch (_x)
		do
		{
			case "s_m900Marker";
			case "s_orcaMarker": {if (_this < 500) then {_x setMarkerColor "ColorGreen"} else {_x setMarkerColor "ColorRed"};};
			case "s_wildcatMarker": {if (_this < 2000) then {_x setMarkerColor "ColorGreen"} else {_x setMarkerColor "ColorRed"};};
			case "s_ghosthawkMarker";
			case "s_mohawkMarker": {if (_this < 4000) then {_x setMarkerColor "ColorGreen"} else {_x setMarkerColor "ColorRed"};};
			case "s_huronMarker": {if (_this < 10000) then {_x setMarkerColor "ColorGreen"} else {_x setMarkerColor "ColorRed"};};
			case "s_taruMarker": {if (_this < 12000) then {_x setMarkerColor "ColorGreen"} else {_x setMarkerColor "ColorRed"};};
		};
	}forEach g_heliMarkers;
};
// the rtb task: return to base after delivering the cargo, if there is another destination left, start the next task, if not end mission when player arrives at base.
f_rtbTask =
{
	sleep 10;
	saveGame;
	if(count g_locationMarkers == 0)
	then
	{
		waitUntil {player distance s_base <= 2};
		["TaskSucceeded",["","Return to Base"]] call BIS_fnc_showNotification;
		g_rtbTaskObject setTaskState "Succeeded";
		"End1" call BIS_fnc_endMission;
	}
	else
	{
		private ["_limit", "_base"];
		waitUntil {player distance s_base <= 700};
		["TaskSucceeded",["","Return to Base"]] call BIS_fnc_showNotification;
		g_rtbTaskObject setTaskState "Succeeded";
		player removeSimpleTask g_rtbTaskObject; 
		g_taskObject setTaskState "Assigned";
		player setCurrentTask g_taskObject;
		
		m_task = g_locationMarkers call BIS_fnc_arrayPop;
		
		g_cargo setDamage 0;
		g_cargo setPosATL (getPosATL s_base);
		
		_limit = 0;
		_base = 0;
		
		switch (typeOf vehicle player) do
		{
			case "C_Heli_Light_01_civil_F";
			case "O_Heli_Light_02_unarmed_F": {_limit = 500};
			case "I_Heli_light_03_unarmed_F": {_limit = 2000};
			case "B_Heli_Transport_01_camo_F";
			case "I_Heli_Transport_02_F": {_limit = 4000};
			case "B_Heli_Transport_03_unarmed_F": {_limit = 10000};
			case "O_Heli_Transport_04_F": {_limit = 12000};
			default {_limit = 400};
		};
		
		if (g_typeNow == "B_supplyCrate_F")	then {_base = 30} else {_base = 1000};
		g_weight = (ceil(random (_limit-_base)) + _base);
		g_weight call f_updateMarkers;
		g_cargo setMass g_weight;
		g_taskObject setSimpleTaskDestination getMarkerPos m_task;
		call f_cargoTask;
	};
};

// The cargo task: move the composition to the destination, wait until the player drops the cargo at the destination and start the rtb task
f_cargoTask =
{
	[s_composition, m_task] call f_moveComp;
	waitUntil {(g_cargo distance (getMarkerPos m_task) <= 8)};
	["TaskSucceeded",["","Deliver Cargo"]] call BIS_fnc_showNotification;
	g_taskObject setTaskState "Succeeded";
	player addRating g_weight;
	
	g_rtbTaskObject = player createSimpleTask ["Return to Base"];
	g_rtbTaskObject setSimpleTaskDescription ["Return to your base.", "Return to Base", "RTB"];
	g_rtbTaskObject setSimpleTaskDestination getPosATL s_base;
	g_rtbTaskObject setTaskState "Assigned";
	player setCurrentTask g_rtbTaskObject;
	
	call f_rtbTask;
};
// The amount of task destinations placed in the editor
private ["_locationCount"];
_locationCount = 82;

// set up the rest of the global variables needed in the mission
g_locationMarkers = call f_init;
g_locationMarkers call f_shuffleArray;
g_cargo = (g_cargoType select 0) call f_getCrate;
g_typeNow = typeOf g_cargo;
g_weight = 250;
g_weight call f_updateMarkers;
g_cargo setMass g_weight;
m_task = g_locationMarkers call BIS_fnc_arrayPop;

// Set up the first task in the briefing
g_taskObject = player createSimpleTask ["Deliver Cargo"];
g_taskObject setSimpleTaskDescription ["Deliver the cargo to the designated Destination.", "Deliver Cargo", "Destination"];
g_taskObject setSimpleTaskDestination getMarkerPos m_task;
g_taskObject setTaskState "Assigned";
player setCurrentTask g_taskObject;

// wait until the player has started the mission
waitUntil {isNull findDisplay 53};

//Start the first mission, it will loop as seen in the code above
call f_cargoTask;
