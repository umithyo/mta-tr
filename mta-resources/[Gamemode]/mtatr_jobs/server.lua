function getPlayerCurrentJob (player)
	return isPlayerInJob(player);
end

function isPlayerInJob (player)
	return isElement (player) and player:getData"injob";
end

function getPlayersInJob (job)
	local tbl = {};
	for i, v in ipairs (getElementsByType"player") do
		if getPlayerCurrentJob (v) == job then
			table.insert (tbl, v);
		end
	end
	return tbl;
end

addEvent ("onPlayerRequestJob", true);
addEventHandler ("onPlayerRequestJob", root,
	function (job)
		if isPedDead (client) then return; end
		if isPedInVehicle (client) then outputChatBox ("Mesleğe girmek için önce aracınızdan inmeniz gerekli!", client, 255, 0, 0); return; end
		if exports.mtatr_deathmatches:isPlayerInDeathmatch (client) then return; end
		if exports.mtatr_jobs:isPlayerInJob (client) then return; end
		if getElementAttachedTo (client) then return; end
		setPlayerInJob (client, job);
	end
);

function setPlayerInJob (player, job)
	exports.mtatr_accounts:saveWeapons (player);
	exports.mtatr_accounts:saveLocation (player);
	exports.mtatr_accounts:saveMisc (player);
	triggerClientEvent (player, "jobs.closeWindow", player);
	warpPlayerToJob (player, job);
	player:setData ("injob", job);
	if DM_TYPE == "teams" then
		setPlayerTeam (player, getTeamFromName ("Meslek: "..job));
	else
		setElementData (player, "Meslek", job);
	end
	triggerEvent ("onPlayerJoinJob", player, job);
end

addEvent ("onPlayerJoinJob");
addEventHandler ("onPlayerJoinJob", root,
	function (job)
		local r, g, b = getJobColors ();
		outputChatBox (source:getName().. ", "..job.. " mesleğine girdi", root, r, g, b);
		outputChatBox ("Çıkmak için /meslekcik yazabilirsin.", source, r, g, b);
		-- triggerClientEvent (source, "onClientPlayerJoinsJob", source, job);
	end
);

local function getRandomSpawnPoint (job)
	return JOBS[job][math.random(#JOBS[job])];
end

function warpPlayerToJob (player, job)
	fadeCamera (player, false);
	setTimer (
		function (p, d)
			if isElement (p) then
				if isPlayerInJob (p) then
					local point = getRandomSpawnPoint (d);
					local x, y, z = unpack (point.pos);
					local rot = point.rot;

					takeAllWeapons (p);

					p:setPosition (x, y, z);
					p:setRotation (0, 0, rot);

					local weapons = getJobWeapons (d);
					for i, v in ipairs (weapons) do
						giveWeapon (p, v.id, v.ammo);
					end

					local model = point.model;
					setElementModel (p, model);

					fadeCamera (p, true);
				end
			end
		end,
	1000, 1, player, job);
end

local function spawn (player)
	local job = getPlayerCurrentJob (player);
	fadeCamera (player, false);

	setTimer (
		function (p, d)
			if isElement (p) then
				if isPlayerInJob (p) then
					local char = exports.mtatr_accounts:getPlayerCurrentCharacter (p);
					local function g_data (data)
						return exports.database:getPlayerCharacterData (p, char, data);
					end
					local point = getRandomSpawnPoint (d);
					local x, y, z = unpack (point.pos);
					local rot = point.rot;
					local model = point.model;
					spawnPlayer (p, x, y, z, rot, model, 0, 0);

					local weapons = getJobWeapons (d);
					for i, v in ipairs (weapons) do
						giveWeapon (p, v.id, v.ammo);
					end

					fadeCamera (p, true);
				end
			end
		end,
	1000, 1, player, job);
end

function setPlayerOutOfJob (player)
	if isPlayerInJob (player) then
		triggerEvent ("onPlayerLeaveJob", player);
		if isPedDead (player) then exports.mtatr_play:spawn (player); end
		fadeCamera (player, true);
		local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
		local location = exports.database:getPlayerCharacterData (player, char, "location");
		local x, y, z = unpack (location);
		local weapons = exports.database:getPlayerCharacterData (player, char, "weapons");
		local model = exports.database:getPlayerCharacterData (player, char, "model")
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
		player:setData ("injob", nil);
		if JOB_TYPE == "teams" then
			setPlayerTeam (player, nil);
		else
			setElementData (player, "Meslek", nil);
		end
		setElementModel (player, model);
	end
end

addEvent ("onPlayerLeaveJob");
addEventHandler ("onPlayerLeaveJob", root,
	function ()
		local r, g, b = getJobColors ();
		outputChatBox (source:getName().. " meslekten çıktı! (/meslekcik)", root, r, g, b);
	end
);

addCommandHandler ("meslekcik",
	function (p)
		if isPlayerInJob (p) then
			fadeCamera (p, false);
			setTimer (setPlayerOutOfJob, 1000, 1, p);
		end
	end
);

addEventHandler ("onPlayerWasted", root,
	function (_, killer)
		if isPlayerInJob (source) then
			spawn (source);
		end
	end
);

addEventHandler ("onResourceStop", resourceRoot,
	function ()
		for i, v in ipairs (getElementsByType"player") do
			if isPlayerInJob (v) then
				setPlayerOutOfJob (v);
			end
		end
	end
);
