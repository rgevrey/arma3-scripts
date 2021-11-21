// Last edited 15/07/2021
// This is the latest version of the script

[Soldier1, MyBox, true] spawn {

	params["_from","_to","_remove"]; 
		 
	_bodies = allDeadMen;
	_to = cursorTarget;
	_remove = true;

{
	_from = _x;
	
// Weapons - that works
	
	// Weapons in the inventory of the body
	_weaponsHeld = weaponsItems _from; 
	
	if (count _weaponsHeld > 0) then {  
	
		 // Checks if there's space in the box then adds the weapons held by the body
		{ if (_to canAdd [_x select 0,1]) then {
				_to addWeaponWithAttachmentsCargoGlobal [_x, 1];
			} else {hint "Container is full"; terminate _thisScript};
		} forEach _weaponsHeld; 
	
		// Removes the weapon if asked
		if (_remove == true) then {
			removeAllWeapons _from;
		};
	
	};

	
// Magazines 
	
	_mags = magazinesAmmo _from; 
	
	if (count _mags > 0) then {  
		{ if (_to canAdd [_x select 0,1]) then {
				_to addMagazineCargo [_x select 0,1];
				
			// Removes the item if asked
			if (_remove == true) then {
				_from removeMagazine [_x select 0,1];
			};
	
			} else {hint "Container is full"; terminate _thisScript};
		} forEach _mags; 
	};
	
// Helmets 
	
	_helmet = headgear _from; 
	
	if (count _helmet > 0) then {  
		if (_to canAdd _helmet) then {
				_to addItemCargoGlobal [_helmet, 1];
				
			// Removes the item if asked
			if (_remove == true) then {
				 removeHeadgear _from;
			};
	
			} else {hint "Container is full"; terminate _thisScript};
	};
	
// Vests 
	
	_vest = vest _from; 
	
	if (count _vest > 0) then {  
		if (_to canAdd _vest) then {
				_to addItemCargoGlobal [_vest,1];
				
			// Removes the item if asked
			if (_remove == true) then {
				 removeVest _from;
			};
			} else {hint "Container is full"; terminate _thisScript};
	};
	
// NVGs

	_nvg = hmd _from; 
	
	if (count _nvg > 0) then {  
		if (_to canAdd _nvg) then {
				_to addItemCargoGlobal [_nvg,1];
				
			// Removes the item if asked
			if (_remove == true) then {
				 _from unassignItem _nvg; 
				 _from removeItem _nvg;
			};
			} else {hint "Container is full"; terminate _thisScript};
	};
	
// Other assignedItems

	_items = assignedItems _from; 
	
	if (count _items > 0) then {  
		{ if (_to canAdd _x) then {
				_to addItemCargoGlobal [_x, 1];
				
			// Removes the item if asked
			if (_remove == true) then {
				removeAllAssignedItems _from;
			};
	
			} else {hint "Container is full"; terminate _thisScript};
		} forEach _items; 
	};
	
// Backpacks

	_backpack = backpack _from;
	
	if (count _backpack > 0) then {  
		if (_to canAdd _backpack) then {
				_to addBackpackCargo [_backpack,1];
				
			// Removes the item if asked
			if (_remove == true) then {
				 removeBackpack _from;
			};
			} else {hint "Container is full"; terminate _thisScript};
	};
	
	hint "All equipment picked-up";
	
} forEach _bodies;

// Weapons on the floor at 500m

	private _allStuff = [
		[], // Weapons
		[], // Magazines
		[], // Items
		[] // Backpacks
	];

	private ["_className", "_classNames", "_index", "_predicate", "_quantities", "_quantity", "_stuff", "_stuffOfType", "_stuffType", "_values", "_weaponHolder", "_weaponHolders"];

	_weaponHolders = (nearestObjects [player, ["WeaponHolder", "WeaponHolderSimulated"], 500]);

	{
		_weaponHolder = _x;
		
		{
			_classNames = _x select 0;

			_quantities = _x select 1;

			_stuffType = _forEachIndex;

			_stuffOfType = _allStuff select _stuffType;
			
			// Predicate
			_predicate = if (_stuffType == 1) then {
				{((_x select 0) == _className) and {(_x select 2) == _quantity}}
			} else {
				{(_x select 0) == _className}
			};
			
			{
				_values = if (_stuffType == 1) then {_x} else {[_x, _quantities select _forEachIndex]};

				_className = _values select 0;
				_quantity = _values select 1;

				_index = _stuffOfType findIf _predicate;

				if (_index >= 0) then {
					if (_stuffType == 1) then {_quantity = 1;};

					_stuff = _stuffOfType select _index;

					_stuff set [1, (_stuff select 1) + _quantity];
				} else {
					_values = if (_stuffType == 1) then {[_className, 1, _quantity]} else {[_className, _quantity]};

					_stuffOfType pushBack _values;
				};
			} forEach _classNames;
			
		} forEach [
			getWeaponCargo _weaponHolder,
			[magazinesAmmoCargo _weaponHolder, []],
			getItemCargo _weaponHolder,
			getBackpackCargo _weaponHolder
		];
	} forEach _weaponHolders;


	{if (_to canAdd _x) then {_to addWeaponCargoGlobal _x;} 
		else {hint "Container is full"; terminate _thisScript};
		} forEach (_allStuff select 0);
	{if (_to canAdd _x) then {_to addMagazineAmmoCargo _x;} 
		else {hint "Container is full"; terminate _thisScript};
		}forEach (_allStuff select 1);
	{if (_to canAdd _x) then {_to addItemCargoGlobal _x;} 
		else {hint "Container is full"; terminate _thisScript}; 
		}forEach (_allStuff select 2);
	{if (_to canAdd _x) then {_to addBackpackCargoGlobal _x;}
		else {hint "Container is full"; terminate _thisScript};
		}forEach (_allStuff select 3);
		
	hint "All weapons picked up";

};