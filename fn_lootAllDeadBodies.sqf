
[Soldier1, MyBox, true] spawn {

	params["_from","_to","_remove"]; 
	
	// ----------------------------------------------------------------------------
	// Copy from here for console execution, which is the only this works right now
	// The cargo space of the object seems to be a problem, the function works
	// but the amount of equipment it picks up makes any normal storage overloaded
	
	_bodies = allDeadMen; // list of dead units, not optional
	_to = cursorTarget; // where the equipment will be added, not optional
	_remove = false; // removes the looted equipment from the ground, optional but bugged when true
	_createContainer = true; // creates an infinite box and moves the content there, optional 
	_pickWeaponInInventory = true; // optional
	_pickMagazinesInWeapon = true; // optional
	_pickHelmet = true; // optional
	_pickVest= true;// optional
	_pickUniform = true; // optional
	_pickWeaponOnFloor = true; // optional
	_pickWeaponDistance = 500; // Change the loot radius here, in metres
	_pickBackPack = true; // optional
	_pickNVGTools = true; // optional
	
// Container storage is a big limitation because of how powerful this script is
// This creates a crate from the Old Man DLC that has an infinite (or looks infinite) storage
// The idea is then to move or load the box into a truck, ideally via ACE interactions

if (_createContainer == true) then {

	_magicBox = createVehicle ["VirtualReammoBox_small_F", position player, [], 0, "NONE"];
	_to = _magicBox;

};	


{
		_from = _x;
		
	// Weapons - that works

	if 	(_pickWeaponInInventory == true) then {

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
	};

		
	// Magazines in weapons

	if (_pickMagazinesInWeapon == true) then {
		
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
	};
		
	// Helmets 

	if (_pickHelmet == true) then {

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
	};
		
	// Vests - sifting Ammo then the vest itself

	if	(_pickVest == true) then {
		
		_content = vestItems _from;
		{
			_to addItemCargoGlobal [_x, 1];
			systemChat _x;
			
		} forEach _content;
		
		_vest = vest _from; 
		
		if (count _vest > 0) then {  
			if (_to canAdd _vest) then {
					_to addItemCargoGlobal [_vest,1];
					
					systemChat _vest;
					
				// Removes the item if asked
				//if (_remove == true) then {
				//	 removeVest _from;
				//};
				} else {hint "Container is full"; terminate _thisScript};
		};
	};

	// Uniforms - picks up the pockets of the uniform!

	if (_pickUniform == true) then {

		_content = uniformItems _from;
		{
			_ToAddToCargo = [_x, 1];
			_to addItemCargoGlobal _ToAddToCargo;
		
		} forEach _content;

	};
	// NVGs

	if (_pickNVGTools == true) then {
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
	};
		
	// Backpacks

	if (_pickBackPack == true) then {

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
		
	};
	
	
} forEach _bodies;

// Weapons on the floor at specified distance
// This bit of code is 99% not from me and I have to find where I found it so I can reference it

if (_pickWeaponOnFloor == true) then {

	private _allStuff = [
		[], // Weapons
		[], // Magazines
		[], // Items
		[] // Backpacks
	];

	private ["_className", "_classNames", "_index", "_predicate", "_quantities", "_quantity", "_stuff", "_stuffOfType", "_stuffType", "_values", "_weaponHolder", "_weaponHolders"];

	_weaponHolders = (nearestObjects [player, ["WeaponHolder", "WeaponHolderSimulated"], _pickWeaponDistance]);

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
		
		if (_remove == true) then {
		
			deleteVehicle _weaponHolder;
		
		};
		
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
		
		
	hint "Looting complete";
	
};
	
	// Stop copy here for manual execution
	// ----------------------------------------------------------------------------

};