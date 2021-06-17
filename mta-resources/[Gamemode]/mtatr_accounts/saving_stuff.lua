addEventHandler ("onPlayerWasted", root,
	function ()
		if not isPlayerLoggedIn (source) then return; end
		if isPlayerAvailableToSave (source) then
			saveWeapons (source);
			saveMisc (source);
			local id = exports.database:getPlayerId (source);
			local char = getPlayerCurrentCharacter (source);
			local x, y, z, dim, int;
			if exports.mtatr_housing:isHouseSpawnEnabled(source) then
				x, y, z, dim, int = exports.mtatr_housing:getPlayerSpawnPoint(source);
			end
			local house_loc = x and {x, y, z};
			exports.database:setCharacterData (id, char, "location", house_loc or DEFAULT_CHAR_INFO.location);
			exports.database:setCharacterData (id, char, "dim", dim or 0);
			exports.database:setCharacterData (id, char, "int", int or 0);
		end
	end
);

addEventHandler ("onPlayerQuit", root,
	function ()
		if not isPlayerLoggedIn (source) then return; end
		if isPlayerAvailableToSave (source) then
			if exports.mtatr_civ:getPlayerMission(source) then return; end
			saveWeapons (source);
			saveLocation (source);
			saveMisc (source);
		end
	end
);

function saveWeapons (player)
	local id, char = checkSavingAvailability (player);
	if id and char then
		local weapons = exports.mtatr_utils:getPedWeapons(player);
		exports.database:setCharacterData (id, char, "weapons", weapons);
	end
end

function saveLocation (player)
	local id, char = checkSavingAvailability (player);
	if id and char then
		local location = {getElementPosition(player)};
		exports.database:setCharacterData (id, char, "location", location);
		local dim = getElementDimension (player);
		local int = getElementInterior (player);
		exports.database:setCharacterData (id, char, "dim", dim);
		exports.database:setCharacterData (id, char, "int", int);
	end
end

function saveMisc (player)
	local id, char = checkSavingAvailability (player);
	if id and char then
		local model = getElementModel (player);
		exports.database:setCharacterData (id, char, "model", model);
	end
end

function checkSavingAvailability (player)
	local logs = {};
	if not isElement (player) then
		table.insert (logs, "ERROR GETTING PLAYER IN SAVING SCRIPT BOUND TO "..eventName or "???".. " ON PLAYER "..getPlayerName (player) or "???");
	end
	local id = exports.database:getPlayerId (player);
	if not id then
		table.insert (logs, "ERROR GETTING ID IN SAVING SCRIPT BOUND TO "..eventName or "???".. " ON PLAYER "..getPlayerName (player) or "???")
	end
	local char = getPlayerCurrentCharacter (player)
	if not char then
		table.insert (logs, "ERROR GETTING PLAYER CHAR IN SAVING SCRIPT BOUND TO "..eventName or "???".. " ON PLAYER "..getPlayerName (player) or "???");
	end
	if next (logs) then
		for i, v in ipairs (logs) do
			iprint (v);
		end
		return false;
	end
	return id, char
end

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root,
	function (char)
		local id = exports.database:getPlayerId (source);
		exports.database:setPlayerData (id, "fr_stats", "last_played_char", char);
	end
);

function isPlayerInDM (player)
	return isPlayerLoggedIn (player) and exports.mtatr_deathmatches:isPlayerInDeathmatch (player);
end

function isPlayerAvailableToSave (player)
	return not ( isPlayerInDM (player) or exports.mtatr_civ:getPlayerMission(player) or getElementData (player, "inevent") or getElementData (player, "inpvp") );
end
