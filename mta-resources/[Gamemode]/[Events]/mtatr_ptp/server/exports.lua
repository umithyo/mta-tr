function startEvent ()
	startMap ();
	local col, radars = exports.mtatr_engines:createAntiRushPoints();
	col:setDimension (DIMENSION);
	addEventHandler ("onColShapeHit", col, removeRestriction);
	addEventHandler ("onColShapeLeave", col, addRestriction);
	for v in pairs (radars) do 
		setElementDimension (v, DIMENSION);
	end	
	MAP.radars 	= radars;
	MAP.col		= col;
	triggerEvent ("onPTPStarted", resourceRoot);
end

function stopEvent ()
	triggerEvent ("onPTPFinished", resourceRoot);
end

function joinEvent(player)		
	savePreEventProperties (player);
	
	for k, tbl in pairs (SKINS) do 
		for i, v in ipairs (tbl) do 
			v.name = "Level "..i;
		end
	end	
	
	local team_info = {
		{
			name = "President",
			skins = SKINS.President,
			colour = TEAM_COLORS.President,
			players = isElement (president) and 1 or 0,
			desc = "Oyunu kazanmak için oyun sonuna kadar canlı kalman gerekiyor."
		},
		{
			name = "Bodyguards",
			skins = SKINS.Bodyguards,
			colour = TEAM_COLORS.Bodyguards,
			players = getTeamCount ("Bodyguards"),
			desc = "Başkanı oyun sonuna kadar koruman gerekiyor."
		},
		{
			name = "Hunters",
			skins = SKINS.Hunters,
			colour = TEAM_COLORS.Hunters,
			players = getTeamCount ("Hunters"),
			desc = "Başkanı ne pahasına kadar öldürmen gerekiyor."
		}
	};
	
	pending [player] = true;
	
	setElementDimension (player, DIMENSION);
	
	exports.mtatr_engines:createTeamMenu(player, "PTP", "Silahlar", DIMENSION, team_info);
	
	outputChatBox ("Etkinlik başlamadan önce çıkmak için /eventcik yazabilirsiniz.", player, 255, 0, 0);
	
	setElementData (player, "inevent", "PTP");
end

function getMapDetails()
	return "Slotlar: ".. LIMIT * 2 .. " Map: ".. MAP.name .. "\nMapper: "..MAP.mapper;
end

function canPlayerJoinEvent (player)
	if isPlayerInEvent (player) then 
		return false, "Zaten etkinliktesiniz!";	
	end	
	if isPedInVehicle (player) then 
		return false, "Araçtan çıkmanız gerekiyor!";
	end	
	return true;
end	