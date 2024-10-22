local players = {};

function getPlayerCurrentDeathmatch (player)
	return players[player];
end

function isPlayerInDeathmatch (player)
	return isElement (player) and player:getData"indm";
end

function getPlayersInDeathmatch (dm)
	local tbl = {};
	for i, v in ipairs (getElementsByType"player") do
		if getPlayerCurrentDeathmatch (v) == dm then
			table.insert (tbl, v);
		end
	end
	return tbl;
end


function setPlayerInDeathmatch (player, dm)
	exports.mtatr_accounts:saveWeapons (player);
	exports.mtatr_accounts:saveLocation (player);
	exports.mtatr_accounts:saveMisc (player);
	players[player] = dm;
	warpPlayerToDeathmatch (player, dm);
	player:setData ("indm", dm);
	if DM_TYPE == "teams" then
		setPlayerTeam (player, getTeamFromName ("Deathmatch: "..dm));
	else
		setElementData (player, "Deathmatch", dm);
	end
	triggerEvent ("onPlayerJoinDeathmatch", player, dm);
end

addEvent ("onPlayerJoinDeathmatch");
addEventHandler ("onPlayerJoinDeathmatch", root,
	function (dm)
		local r, g, b = getDeathmatchColors ();
		outputChatBox (source:getName().. ", "..dm.. " ("..getDeathmatchData (dm, "group").. ") DM bölümüne girdi", root, r, g, b);
		outputChatBox ("Çıkmak için /dmcik yazabilirsin.", source, r, g, b);
		triggerClientEvent (source, "onClientPlayerJoinsDeathmatch", source, getDeathmatchType(dm), dm);
	end
);


addEvent ("onPlayerLeaveDeathmatch");
addEventHandler ("onPlayerLeaveDeathmatch", root,
	function ()
		local r, g, b = getDeathmatchColors ();
		outputChatBox (source:getName().. " deathmatch'ten kaçtı! (/dmcik)", root, r, g, b);
		triggerClientEvent (source, "onClientPlayerLeavesDeathmatch", source);
	end
);

local function getRandomSpawnPoint (dm)
	return DMS[dm][math.random(#DMS[dm])];
end

function warpPlayerToDeathmatch (player, dm)
	fadeCamera (player, false);

	setTimer (
		function (p, d)
			if isElement (p) then
				if isPlayerInDeathmatch (p) then
					local point = getRandomSpawnPoint (d);
					local x, y, z = unpack (point.pos);
					local rot = point.rot or 0;

					takeAllWeapons (p);

					local dim = getDeathmatchData (d, "DMDIM");
					local int = getDeathmatchData (d, "DMINT");

					p:setDimension (dim);
					p:setInterior (int);
					p:setPosition (x, y, z);
					p:setRotation (0, 0, rot);

					local weapons = getDeathmatchWeapons (d);
					for i, v in ipairs (weapons) do
						giveWeapon (p, v.id, v.ammo);
					end

					fadeCamera (p, true);
				end
			end
		end,
	1000, 1, player, dm);
end

function spawn (player)
	local dm = getPlayerCurrentDeathmatch (player);
	fadeCamera (player, false);

	setTimer (
		function (p, d)
			if isElement (p) then
				if isPlayerInDeathmatch (p) then
					local char = exports.mtatr_accounts:getPlayerCurrentCharacter (p);
					local function g_data (data)
						return exports.database:getPlayerCharacterData (p, char, data);
					end
					local point = getRandomSpawnPoint (d);
					local x, y, z = unpack (point.pos);
					local rot = point.rot;
					local dim = getDeathmatchData (d, "DMDIM");
					local int = getDeathmatchData (d, "DMINT");

					local model = g_data ("model");
					spawnPlayer (p, x, y, z, rot, model, int, dim);

					local weapons = getDeathmatchWeapons (d);
					for i, v in ipairs (weapons) do
						giveWeapon (p, v.id, v.ammo);
					end

					fadeCamera (p, true);
				end
			end
		end,
	1000, 1, player, dm);
end

function setPlayerOutOfDeathmatch (player)
	if isPlayerInDeathmatch (player) then
		if isPedDead (player) then exports.mtatr_play:spawn (player); end
		fadeCamera (player, true);
		local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
		local location = exports.database:getPlayerCharacterData (player, char, "location");
		local x, y, z = unpack (location);
		local weapons = exports.database:getPlayerCharacterData (player, char, "weapons");
		takeAllWeapons (player);
		for i, v in ipairs (weapons) do
			giveWeapon (player, v.id, v.ammo);
		end
		local function g_data (data)
			return exports.database:getPlayerCharacterData (player, char, data);
		end
		local dim, int = g_data ("dim") or 0, g_data ("int") or 0;
		player:setDimension (dim);
		player:setInterior (int);
		player:setPosition (x, y, z);
		players[player] = nil;
		player:setData ("indm", nil);
		if DM_TYPE == "teams" then
			setPlayerTeam (player, nil);
		else
			setElementData (player, "Deathmatch", nil);
		end
		triggerEvent ("onPlayerLeaveDeathmatch", player, dm);
	end
end
addCommandHandler ("dmcik",
	function (p)
		if isPlayerInDeathmatch (p) then
			fadeCamera (p, false);
			setTimer (setPlayerOutOfDeathmatch, 1000, 1, p);
		end
	end
);

addEventHandler ("onPlayerWasted", root,
	function (_, killer)
		if isPlayerInDeathmatch (source) then
			spawn (source);
			local dm = getPlayerCurrentDeathmatch (source);
			local prize = getDeathmatchData (dm, "prize");
			exports.database:takePlayerMoney (source, prize/2, "Deathmatch");
			if isElement (killer) and killer ~= source then
				if isPlayerInDeathmatch (killer) then
					if getDeathmatchType (getPlayerCurrentDeathmatch (source)) == "zombie" then return; end
					if getPlayerCurrentDeathmatch (source) == getPlayerCurrentDeathmatch (killer) then
						exports.database:givePlayerMoney (killer, prize, "Deathmatch");
					end
				end
			end
		end
	end
);

addEvent ("onZombieWasted");
addEventHandler ("onZombieWasted", root,
	function (killer)
		if isPlayerInDeathmatch (killer) then
			local dm = getPlayerCurrentDeathmatch (killer);
			if getDeathmatchType (dm) == "zombie" then
				local prize = getDeathmatchData (dm, "prize");
				exports.database:givePlayerMoney (killer, prize, "Zombie Deathmatch");
				exports.mtatr_mode:givePlayerCharacterExperience (killer, ZOMBIE_EXPERIENCE);
			end
		end
	end
);

addEventHandler ("onResourceStop", resourceRoot,
	function ()
		for i, v in ipairs (getElementsByType"player") do
			if isPlayerInDeathmatch (v) then
				setPlayerOutOfDeathmatch (v);
			end
		end
	end
);
