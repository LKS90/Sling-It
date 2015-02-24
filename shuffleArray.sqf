// this function shuffles an array randomly (modern Fisher-Yates), it expects an array as input and returns nothing, it operates on the array directly

private ["_n", "_this"];
	_n = (count _this);
	for "_i" from 0 to (_n - 1) do
	{
		private ["_j", "_temp"];
		_j = (floor random (_n - _i)) + _i;
		_temp = _this select _j;
		_this set [_j, (_this select _i)];
		_this set [_i, _temp];
	};