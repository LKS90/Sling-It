// This will set up the destination markers and returns the array it created
private ["_array"];
_array = [];
{
	private "_a";
	_a = toArray _x;
	_a resize 16;
	if (toString _a == "s_targetMarrker_") then
	{
		_array pushBack (format["%1",_x]);
	}
} forEach allMapMarkers;

s_setup addAction [	"Setup",		// title
					"setup.sqf",	// script
					""				// arguments
				 ];

_array