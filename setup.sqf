// the setup.sqf gets called by the laptop's addAction
// It spawns the UI defined in the description.ext and gives it the functionality

// toggles the cargo type and the corresponding sliders on the UI when you press the button (see description.ext)
f_toggleCargo =
{
	if (g_typeNow == "B_supplyCrate_F")
	then {g_typeNow = "B_Slingload_01_Cargo_F"; sliderSetRange [10016, 1000, 12000]; sliderSetSpeed [10016, 1, 100];}
	else {g_typeNow = "B_supplyCrate_F"; sliderSetRange [10016, 100, 4000]; sliderSetSpeed [10016, 1, 100];};
};

// deletes the current cargo and spawns a new one at the base when you press the button (see description.ext)
f_resetCargo =
{
	_type = typeOf g_cargo;
	deleteVehicle g_cargo;
	g_cargo = _type call f_getCrate;
};

// a function to smoothly change the weather, the skip interval depends on the new time, since one might change the time and weather
f_changeWeather =
{
	private ["_skipInterval", "_newOvercast", "_newFog", "_this"];
	_skipInterval = _this select 0;
	_newOvercast = _this select 1;
	_newFog = _this select 2;
	
	(_skipInterval *60 *60) setOvercast _newOvercast;
	(_skipInterval *60 *60) setFog _newFog;
	skipTime (_skipInterval);
};

// apply the changes and close the dialog when you press the button (see description.ext)
f_apply =
{
	private ["_newOvercast", "_newTime", "_newFog"];
	_newOvercast =  (sliderPosition 10010);
	_newTime = (sliderPosition 10012);
	_newFog = (sliderPosition 10014);
	_newWeight = (sliderPosition 10016);
	
	skipTime -24;
	if(_newTime != g_time) then
	{
		_skipTime = (_newTime - g_time) + 24;
		[_skipTime, _newOvercast, _newFog] call f_changeWeather;
	}
	else
	{
		[24, _newOvercast, _newFog] call f_changeWeather;
	};
	if(typeOf g_cargo != g_typeNow) then
	{
		deleteVehicle g_cargo;
		g_cargo = g_typeNow call f_getCrate;
		g_cargo enableSimulation false;
		g_cargo setPosATL (getPosATL s_base);
		g_cargo enableSimulation true;
	};
	
	g_overcast = _newOvercast;
	g_fog = _newFog;
	g_time = _newTime;
	g_weight = _newWeight;
	g_weight call f_updateMarkers;
	g_cargo setMass g_weight;
	
	closeDialog 2;
};

// this functions changes the current location with another random mission when you press the button (see description.ext)
f_changeTask = 
{
	g_locationMarkers pushBack m_task;
	g_locationMarkers call f_shuffleArray;
	m_task = g_locationMarkers call BIS_fnc_arrayPop;
	_pos = getMarkerPos m_task;
	g_taskObject setSimpleTaskDestination getMarkerPos m_task;
	[s_composition, m_task] call f_moveComp;
	_gui_map = (missionNamespace getVariable "mapControl");
	_gui_map ctrlMapAnimAdd [0, 0.15, _pos];
	ctrlMapAnimCommit _gui_map;
};

// do all the necessary set up for the UI
g_cargo setMass g_weight;
g_typeNow = typeOf g_cargo;
disableSerialization;
createDialog "Setup";
waitUntil {dialog};

// get some of the dialog controls
_display = findDisplay 10000;
_cargoToggle = _display displayCtrl 10000;
_overcastSlider = _display displayCtrl 10010;
_overcastText = _display displayCtrl 10011;

// set the weather slider
sliderSetRange [10010, 0, 1];
sliderSetSpeed [10010, .05, .1];
sliderSetPosition [10010, g_overcast];

// set the time slider
sliderSetRange [10012, 0, 24];
sliderSetSpeed [10012, .333, .1667];
sliderSetPosition [10012, g_time];

// set the fog slider
sliderSetRange [10014, 0, 1];
sliderSetSpeed [10014, .05, .1];
sliderSetPosition [10014, g_fog];

// set the cargo slider
if(g_typeNow == "B_supplyCrate_F")
then {sliderSetRange [10016, 100, 4000];sliderSetSpeed [10016, 1, 100];}
else {sliderSetRange [10016, 1000, 12000];sliderSetSpeed [10016, 1, 100];};
sliderSetPosition [10016, g_weight];

// set up the map to display the current destination and add a mapControl to the mission namespace so we can reference it in other functions
_gui_map = _display displayCtrl 10020;
missionNamespace setVariable ["mapControl", _gui_map];
_gui_map ctrlMapAnimAdd [0, 0.15, getMarkerPos m_task];
ctrlMapAnimCommit _gui_map;

// update all text elements while the UI is displaying
while {dialog} do
{
	_hours = floor(sliderPosition 10012);
	_hoursString = if(_hours == 24) then {"00"} else {format["%1", _hours]};
	_minutes = round(60 * ((sliderPosition 10012) % 1));
	_minutesString = if(_minutes > 9) then {format["%1", _minutes]} else {format["0%1", _minutes]};
	_timeString = "Time: " + _hoursString + ":" + _minutesString;
	
	ctrlsetText [10011, format["Overcast: %1", round(sliderPosition 10010 * 100)] + " %"];
	ctrlsetText [10013, _timeString];
	ctrlsetText [10015, format["Fog: %1", round(sliderPosition 10014 * 100)] + " %"];
	ctrlsetText [10017, format["Weight: %1", round(sliderPosition 10016)] + " kg"];
	ctrlsetText [10019, format["%1 - %2 km - %3 Task%4 left - %5 kg delivered",m_task, round((getMarkerPos m_task distance getPosATL s_base) / 1000), count g_locationMarkers, if(count g_locationMarkers == 1) then {""} else {"s"}, rating player]];
	
	if (g_typeNow == "B_supplyCrate_F")
	then {ctrlsetText [10018, "Normal"];}
	else {ctrlsetText [10018, "Heavy"];};
};
// wait until the dialog gets closed (not used here...)
waitUntil {!dialog};