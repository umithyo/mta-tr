function isPlayerInEvent (player)
	return not pending[player] and players[player];
end

function getPlayerId (player)
	for i, team in pairs (ORDER) do
		for k, v in pairs (team) do
			if v == player then
				return k, i;
			end
		end
	end
	return false;
end

function getTeamBarDef (team)
	local t;
	if team == "President" or team == "Bodyguards" then
		t = "Government";
	else
		t = "Hunters";
	end
	return t;
end

function spawnInEvent (player)
	local id = getPlayerId (player) or 1;
	local team = players[player].team;
	local _t = team;
	if team == "President" then
		_t = "Bodyguards";
	end
	local x, y, z = unpack (MAP.spawnpoints[_t][id].pos);
	local rot = MAP.spawnpoints[_t][id].rot;
	spawnPlayer (player, x, y, z, rot, 0, 0, DIMENSION);

	givePlayerEventProperties (player);
end


function getPlayersInEvent ()
	local tbl = {};
	for i in pairs (players) do
		if not pending[i] then
			table.insert (tbl, i);
		end
	end
	return tbl;
end

function getPlayersInEventTeam (team)
	local tbl = {};
	if TEAMS [team] then
		for i in pairs (TEAMS [team]) do
			table.insert (tbl, i);
		end
	end
	return tbl;
end

function getPlayerEventTeam (player)
	if isPlayerInEvent (player) then
		return players[player].team;
	end
end

function getTeamCount (team)
	if TEAMS[team] then
		local count = 0;
		for _ in pairs (TEAMS[team]) do
			count = count + 1;
		end
		if team == "Bodyguards" then
			if isElement (president) then
				count = count + 1;
			end
		end
		return count;
	end
	return false;
end

function getTeamScore (team)
	return scores[team];
end

function getTeamsCount ()
	local count = 0;
	count = getTeamCount ("Hunters") + getTeamCount ("Bodyguards");
	if isElement (president) then
		count = count + 1;
	end
	return count;
end

function setPlayerEventTeam (player, team, skin)
	if team == nil then
		setPlayerOut (player);
		return;
	end
	if team ~= "OTO SEÇİM" then
		local canhe, err = canPlayerChooseTeam (team);
		local skinav = canPlayerChooseSkin (player, team, skin);
		if canhe then
			if skinav == true then
				if team == "President" then
					president = player;
					outputChatBox ("President "..player:getName().."!", root, 255, 255, 0);
					properties [player] = {skin = skin};
					return true;
				end
				properties [player] = {skin = skin};
				TEAMS[team][player] = true;
				return true;
			else
				exports.mtatr_hud:dm (skinav, player, 255, 0, 0);
			end
		else
			exports.mtatr_hud:dm (err, player, 255, 0, 0);
		end
	else
		if getTeamCount ("Hunters") >= getTeamCount ("Bodyguards") then
			return setPlayerEventTeam (player, "Bodyguards", 1);
		elseif  getTeamCount ("Bodyguards") >= getTeamCount ("Hunters") then
			return setPlayerEventTeam (player, "Hunters", 1);
		end
	end
	return false;
end

function canPlayerChooseTeam (team)
	if team == "President" then
		if isElement (president) then
			return false, "Takım dolu!";
		end
	elseif team == "AUTO ASSIGN" then
		return true;
	else
		if team == "Hunters" then
			if getTeamCount ("Hunters") > getTeamCount ("Bodyguards") then
				return false, "Takım dolu!";
			end
		elseif team == "Bodyguards" then
			if getTeamCount ("Bodyguards") > getTeamCount ("Hunters") then
				return false, "Takım dolu!";
			end
		end
	end
	return true;
end

function savePreEventProperties (player)
	exports.mtatr_accounts:saveMisc(player);
	exports.mtatr_accounts:saveWeapons(player);
	exports.mtatr_accounts:saveLocation(player);
	local model 	= getElementModel (player);
	local pos 		= {getElementPosition (player)};
	local dimension = getElementDimension (player);
	local interior	= getElementInterior (player);
	local health	= player:getHealth();
	local armor		= player:getArmor();

	players[player] = {
		model	= model,
		pos		= {getElementPosition  (player)},
		dim		= dimension,
		int 	= interior,
		health	= health,
		armor	= armor,
		weapons = {},
		color 	= {getPlayerNametagColor (player)},
	};

	for i = 1, 12 do
		table.insert (players [player].weapons, {weapon = getPedWeapon (player, i), ammo = getPedTotalAmmo (player, i)});
	end
end

function savePlayerProperties (player)
	local team;

	if president == player then
		team = "President";
	end
	for i, v in pairs (TEAMS) do
		if v[player] then
			team = i;
		end
	end
	local team_ = team;
	if team_ == "President" then
		team_ = "Bodyguards";
	end
	local id = exports.mtatr_engines:getNextSlot (ORDER[team_]);
	ORDER[team_][id] = player;

	players [player].id = id;
	players [player].team = team;

	stats [player] = {};

	exports.mtatr_accounts:saveMisc(player);
	exports.mtatr_accounts:saveWeapons(player);
end

function setPlayerIn (player)
	savePlayerProperties(player);

	setElementHealth (player, 100);

	takeAllWeapons (player);

	triggerEvent ("onPlayerJoinPTP", player);

	local id = getPlayerId (player) or 1;
	local team = players[player].team;
	local _t = team;
	if team == "President" then
		_t = "Bodyguards";
	end
	local x, y, z = unpack (MAP.spawnpoints[_t][id].pos);
	local rot = MAP.spawnpoints[_t][id].rot;
	fadeCamera (player, false);
	if not EVENT_STARTED then
		setElementFrozen (player, true);
		toggleAllControls (player, false, true, false);
	end
	setTimer (
		function (p)
			p:setPosition(x, y, z);
			p:setRotation(0, 0, rot);
			givePlayerEventProperties (p);
			fadeCamera (p, true);
		end,
	1000, 1, player);
end

function givePlayerEventProperties (player)
	local team = getPlayerEventTeam (player);
	local skin = properties[player].skin;
	local prop = SKINS[team][skin];
	local model = prop.model;
	local weapons = WEAPONS[team][skin];

	player:setModel (model);
	for i, v in ipairs (weapons) do
		giveWeapon (player, v.id, v.ammo);
	end
end

function getPlayerId (player)
	return players[player].id, players[player].team
end

function setPlayerOut (player)
	setElementData (player, "inevent", nil);
	fadeCamera (player, false);
	if isPedDead (player) then
		exports.mtatr_play:spawn(player);
	end
	local team = getPlayerEventTeam (player);

	if TEAMS[team] then
		TEAMS[team][player] = nil;
	end

	local id, team_ = getPlayerId (player);
	if team_ == "President" then
		team_ = "Bodyguards";
	end
	if id and team_ and ORDER[team_] then
		ORDER[team_][id] = nil;
	end

	if players [player] then
		if isElement (player) then
			local model, dim, int = players [player].model, players [player].dim, players [player].int;
			local health, armor = players[player].health, players[player].armor;
			local weapons = players[player].weapons;
			local x, y, z = unpack (players[player].pos);
			local r, g, b = unpack (players[player].color);
			setTimer (
				function (p)
					if isElement (p) then
						p:setModel (model);
						p:setDimension (dim);
						p:setInterior (int);
						p:setPosition (x, y, z);
						setElementHealth (p, health);
						setPedArmor (p, armor);
						takeAllWeapons (p);
						for i, v in pairs (weapons) do
							giveWeapon (p, v.weapon, v.ammo);
						end
						fadeCamera (p, true);
						setPlayerNametagColor (p, r, g, b);
						setCameraTarget (p, p);
						exports.mtatr_engines:destroyTeamMenu(p);
						setElementFrozen(p, false);
						toggleAllControls(p, true);
					end
				end,
			1000, 1, player);
			players[player] = nil;
		end
	end

	stats[player] = nil;
	pending [player] = nil;
	local blip = exports.mtatr_playerblips:getPlayerBlip (player);
	if isElement (blip) then
		setBlipSize (blip, 2);
	end
	exports.mtatr_play:disableSpawnFor (player, false);
end

function check ()
	if president and isElement (president) then
		if not EVENT_STARTED then
			if getTeamsCount () >= LIMIT * 2 then
				EVENT_STARTING = true; -- if this is true, players can't leave the event.
				timers.starter = Timer (
					function ()
						runEvent ();
					end,
				60*1000, 1);
			end
		end
	end
end

function killPlayers ()
	for i, v in ipairs (getPlayersInEvent()) do
		triggerEvent ("onPlayerLeavePTP", v)
	end
	for i in pairs (pending) do
		exports.mtatr_engines:destroyTeamMenu(i);
		setElementDimension (i, 0);
	end
end
addEventHandler ("onResourceStop", resourceRoot,
	function ()
		for i, player in ipairs (getElementsByType"player") do
			if players [player] then
				if isElement (player) then
					setPlayerPropertiesBack (player);
				end
			end
		end
		triggerEvent ("onPTPFinished", resourceRoot, 3);
	end
);

function setPlayerPropertiesBack(player)
	local model, dim, int = players [player].model, players [player].dim, players [player].int;
	local health, armor = players[player].health, players[player].armor;
	local weapons = players[player].weapons;
	local x, y, z = unpack (players[player].pos);
	local r, g, b = unpack (players[player].color);
	player:setModel (model);
	player:setDimension (dim);
	player:setInterior (int);
	player:setPosition (x, y, z);
	setElementHealth (player, health);
	setPedArmor (player, armor);
	for i, v in pairs (weapons) do
		giveWeapon (player, v.weapon, v.ammo);
	end
	fadeCamera (player, true);
	toggleAllControls (player, true);
	setElementFrozen (player, false);
	setCameraTarget (player, player);
	exports.mtatr_engines:destroyTeamMenu(player);
	if isPedDead (player) then
		exports.mtatr_play:spawn(player);
	end
	setPlayerNametagColor (player, r, g, b)
end

function getStats (_type)
	local tbl = {};
	for i, v in pairs (stats) do
		table.insert (tbl, {name = i:getName(), kills = v.kills, dmg = v.dmg});
	end
	table.sort (tbl, function (a, b) if a[_type] and b[_type] then  return a[_type] > b[_type]; end end);
	return tbl;
end

function getTeamTotalHP (team)
	local hp = 0;
	for i, v in ipairs (getPlayersInEventTeam(team)) do
		if isElement (v) then
			hp = hp + v:getHealth() + (getPedArmor (v) or 0);
		end
	end
	if isElement (president) and team == "Bodyguards" then
		hp = hp + president:getHealth () + (getPedArmor(president) or 0);
	end
	return hp;
end

function updateInformation (team, key, data)
	for i, v in ipairs (getPlayersInEvent()) do
		if not key then
			local HuntersTotalHP, BodyguardsTotalHP = getTeamTotalHP ("Hunters"), getTeamTotalHP ("Bodyguards");
			local time = exports.mtatr_engines:getEventProperty ("ptp", "timeout");
			local timer = exports.mtatr_engines:getEventTimerDetails ("ptp");
			if timer then
				time = timer/60/1000;
			end
			local tbl = {time = time};
			tbl.team1 = {
				text 	= "Hunters",
				colour 	= (TEAM_COLORS.Hunters),
				players = getTeamCount ("Hunters"),
				score 	= getTeamScore ("Hunters"),
				health 	= HuntersTotalHP,
			};
			tbl.team2 = {
				text 	= "Government",
				colour 	= (TEAM_COLORS.Bodyguards),
				players = getTeamCount ("Bodyguards"),
				score 	= getTeamScore ("Bodyguards"),
				health 	= BodyguardsTotalHP,
			};
			exports.mtatr_engines:updateTeamsBar (v, tbl);
		else
			local t = getTeamBarDef (team);
			exports.mtatr_engines:updateTeamsBarData (v, t, key, data);
		end
	end
end

function canPlayerChooseSkin (player, team, skin)
	return exports.mtatr_mode:getPlayerCharacterLevel(player) >= LEVEL_DEPENDENCIES[team][skin] or "Bu sınıfı seçebilmek için seviyeniz en az "..LEVEL_DEPENDENCIES[team][skin].." olmalı.";
end
