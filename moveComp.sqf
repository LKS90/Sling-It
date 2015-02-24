// expects 2 variables as input: a game logic which is the reference for the composition and the destination to move the composition to.
private ["_comp", "_destPos", "_refPos", "_objects", "_destX", "_destY"];
_comp = _this select 0;
_dest = _this select 1;
_destPos = getMarkerPos _dest;
_destX = _destPos select 0;
_destY = _destPos select 1;

_refPos = getPosATL _comp;
_refX = _refPos select 0;
_refY = _refPos select 1;
_objects = nearestObjects [_refPos, [], 50];

_comp setVariable ["objects", _objects];

{
	private ["_x", "_relPos", "_newPos", "_posX", "_posY"];
	_posX = ((getPosATL _x) select 0);
	_posY = ((getPosATL _x) select 1);
	
	_relPos = [_refX - _posX, _refY - _posY, 0];
	_newPos = [_destX + (_relPos select 0), _destY + (_relPos select 1), 0];
	_x setPosATL _newPos;
	_x setDamage 0;
} forEach (_comp getVariable "objects");