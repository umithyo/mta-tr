_setNametagColor = setPlayerNametagColor;

function setPlayerNametagColor (player, r, g, b)
	local blip = exports.mtatr_playerblips:getPlayerBlip (player);
	if isElement (blip) then
		setBlipColor (blip, r, g, b, 255);
	end
	return _setNametagColor (player, r, g, b);
end

function output (...)
	exports.mtatr_engines:output (...);
end

PRIZE				= {};
MAP					= {index = 1};
LIMIT				= 8;
DIMENSION			= 6969;
EVENT_STARTED		= false;
EVENT_STARTING		= false;
RESTRICT_TIME 		= 15;

ORDER = {
	["Hunters"] 	= {},
	["Bodyguards"] 	= {},
};

TEAMS = {
	["Hunters"] 	= {},
	["Bodyguards"] 	= {},
};

TEAM_COLORS = {
	["Hunters"]		= {254, 154, 46},
	["Bodyguards"] 	= {46, 225, 255},
	["President"] 	= {221, 255, 46},
};

players 			= {};

stats 				= {};

properties			= {};

pending 			= {};

defaults = {
	money = 6000,
	exp = 450
};

scores = {
	["Hunters"] 	= 0,
	["Bodyguards"] 	= 0
};

president 			= nil;

--TIMERS--
timers 				= {};

SKINS = {
	President = {
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
		{model = 17},
	},
	Bodyguards = {
		{model = 36},
		{model = 37},
		{model = 37},
		{model = 163},
		{model = 164},
		{model = 165},
		{model = 166},
		{model = 280},
		{model = 281},
		{model = 282},
		{model = 283},
		{model = 286},
		{model = 285},
		{model = 287},
		{model = 267},
		{model = 265},
	},
	Hunters = {
		{model = 18},
		{model = 19},
		{model = 20},
		{model = 21},
		{model = 28},
		{model = 29},
		{model = 30},
		{model = 32},
		{model = 34},
		{model = 42},
		{model = 45},
		{model = 47},
		{model = 188},
		{model = 127},
		{model = 124},
		{model = 33},
	},
};

LEVEL_DEPENDENCIES  = {
	President 	= {1, 1, 1, 2, 3, 6, 10, 14, 20, 25, 30},
	Bodyguards 	= {1, 1, 1, 2, 3, 4, 5, 6, 7, 10, 14, 18, 20, 22, 26, 30},
	Hunters		= {1, 1, 1, 2, 3, 4, 5, 6, 7, 10, 14, 18, 20, 22, 26, 30},
};

WEAPONS = {
	President = {
		[1] = {
			{id = 3, ammo = 1},
			{id = 22, ammo = 300},
			{id = 14, ammo = 1},
		},
		[2] = {
			{id = 3, ammo = 1},
			{id = 23, ammo = 150},
			{id = 14, ammo = 1},
		},
		[3] = {
			{id = 3, ammo = 1},
			{id = 29, ammo = 450},
			{id = 14, ammo = 1},
		},
		[4] = {
			{id = 3, ammo = 1},
			{id = 22, ammo = 300},
			{id = 29, ammo = 450},
			{id = 14, ammo = 1},
		},
		[5] = {
			{id = 26, ammo = 100},
			{id = 33, ammo = 150},
		},
		[6] = {
			{id = 25, ammo = 100},
			{id = 30, ammo = 600},
		},
		[7] = {
			{id = 25, ammo = 100},
			{id = 31, ammo = 600},
		},
		[8] = {
			{id = 27, ammo = 150},
			{id = 33, ammo = 100},
		},
		[9] = {
			{id = 24, ammo = 400},
			{id = 27, ammo = 1000},
			{id = 31, ammo = 1500},
		},
		[10] = {
			{id = 24, ammo = 400},
			{id = 27, ammo = 1000},
			{id = 31, ammo = 1500},
			{id = 34, ammo = 500},
		},
		[11] = {
			{id = 24, ammo = 400},
			{id = 27, ammo = 1000},
			{id = 31, ammo = 1500},
			{id = 34, ammo = 500},
			{id = 35, ammo = 10},
		}
	},
	Bodyguards = {
		[1] = {
			{id = 22, ammo = 500},
			{id = 28, ammo = 600},
		},
		[2] = {
			{id = 22, ammo = 500},
			{id = 28, ammo = 600},
		},
		[3] = {
			{id = 22, ammo = 500},
			{id = 32, ammo = 600},
		},
		[4] = {
			{id = 22, ammo = 500},
			{id = 29, ammo = 750},
		},
		[5] = {
			{id = 23, ammo = 150},
			{id = 32, ammo = 600},
		},
		[6] = {
			{id = 23, ammo = 150},
			{id = 29, ammo = 750},
		},
		[7] = {
			{id = 25, ammo = 100},
			{id = 32, ammo = 600},
		},
		[8] = {
			{id = 26, ammo = 100},
			{id = 32, ammo = 600},
		},
		[9] = {
			{id = 26, ammo = 100},
			{id = 29, ammo = 750},
		},
		[10] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
		},
		[11] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
			{id = 33, ammo = 100},
		},
		[12] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
			{id = 30, ammo = 700},
		},
		[13] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 30, ammo = 700},
		},
		[14] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
		},
		[15] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
			{id = 34, ammo = 150},
		},
		[16] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
			{id = 34, ammo = 150},
			{id = 36, ammo = 15},
		},
	},
	Hunters = {
		[1] = {
			{id = 22, ammo = 500},
			{id = 28, ammo = 600},
		},
		[2] = {
			{id = 22, ammo = 500},
			{id = 28, ammo = 600},
		},
		[3] = {
			{id = 22, ammo = 500},
			{id = 32, ammo = 600},
		},
		[4] = {
			{id = 22, ammo = 500},
			{id = 29, ammo = 750},
		},
		[5] = {
			{id = 23, ammo = 150},
			{id = 32, ammo = 600},
		},
		[6] = {
			{id = 23, ammo = 150},
			{id = 29, ammo = 750},
		},
		[7] = {
			{id = 25, ammo = 100},
			{id = 32, ammo = 600},
		},
		[8] = {
			{id = 26, ammo = 100},
			{id = 32, ammo = 600},
		},
		[9] = {
			{id = 26, ammo = 100},
			{id = 29, ammo = 750},
		},
		[10] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
		},
		[11] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
			{id = 33, ammo = 100},
		},
		[12] = {
			{id = 24, ammo = 100},
			{id = 25, ammo = 100},
			{id = 30, ammo = 700},
		},
		[13] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 30, ammo = 700},
		},
		[14] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
		},
		[15] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
			{id = 34, ammo = 150},
		},
		[16] = {
			{id = 24, ammo = 100},
			{id = 27, ammo = 100},
			{id = 31, ammo = 900},
			{id = 34, ammo = 150},
			{id = 36, ammo = 15},
		},
	}
};

for name, team in pairs (WEAPONS) do
	for i, tbl in ipairs (team) do
		for k, weapon in ipairs (tbl) do
			if not SKINS[name][i].weapons then
				SKINS[name][i].weapons = {};
			end
			if not SKINS[name][i].weapons[k] then
				SKINS[name][i].weapons[k] = {};
			end
			SKINS[name][i].weapons[k] = getWeaponNameFromID (weapon.id).. "("..weapon.ammo..")";
		end
	end
end

function clearAllData ()
	local map_index = MAP.index;
	PRIZE			= {};
	MAP				= {index = map_index};
	LIMIT			= 8;
	EVENT_STARTED	= false;
	EVENT_STARTING	= false;
	players 		= {};
	stats 			= {};
	president 		= nil;
	pending 		= {};
	properties 		= {};

	scores = {
		["Hunters"] 	= 0,
		["Bodyguards"] 	= 0
	};

	ORDER = {
		["Hunters"] 	= {},
		["Bodyguards"] 	= {},
	};

	for i, v in pairs (timers) do
		if isTimer (v) then
			killTimer (v);
		end
	end

	timers 			= {};
end
