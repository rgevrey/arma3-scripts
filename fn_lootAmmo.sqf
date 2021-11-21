// Trying to pick up the ammo from dead guys!!!!!

_bodies = allDeadMen;
_to = MyBox;
_remove = true;
{ 
	_from = _x;
	_content = vestItems _from;
	{
		hint _x;
		_ToAddToCargo = [_x, 1];
		_to addItemCargoGlobal _ToAddToCargo;
		
		if (_remove == true) then {
			removeVest _from;
		};
		
	} forEach _content;

	
} forEach _bodies;