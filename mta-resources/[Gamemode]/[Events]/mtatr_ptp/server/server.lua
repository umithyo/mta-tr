maps = {};

addEvent ("onEventFinished");
addEventHandler ("onEventFinished", root,
	function (event)
		if event == "Protect the President" then
			if MAP.radars then
				for i in pairs (MAP.radars) do
					destroyElement (i);
				end
			end
			if isElement (MAP.col) then
				destroyElement (MAP.col);
			end

			clearAllData ();
		end
	end
);

addEvent ("onPlayerJoinPTP");
addEventHandler ("onPlayerJoinPTP", root,
	function ()
		pending [source] = nil;
		check();
		updateInformation ();
		local team = getPlayerEventTeam (source);
		for i in pairs (pending) do
			exports.mtatr_engines:updateTeamMenu (i, team, "players", getTeamCount (team));
		end
		exports.mtatr_engines:destroyTeamMenu(source, 1000);
		exports.mtatr_engines:showTeamsBar (source, true);

		local team = getPlayerEventTeam (source);
		local r, g, b = unpack (TEAM_COLORS[team]);
		setPlayerNametagColor (source, r, g, b);
	end
);

addEvent ("onPlayerSubmitEventTeam");
addEventHandler ("onPlayerSubmitEventTeam", root,
	function (team, skin)
		if setPlayerEventTeam (source, team, skin) then
			setPlayerIn (source);
		end
	end
);

addEvent ("onPlayerLeavePTP", true);
addEventHandler ("onPlayerLeavePTP", root,
	function (quit)
		if not quit then
			if EVENT_STARTING then
				exports.mtatr_hud:dm ("Etkinliği şuan terkedemezsiniz!", source, 255, 0, 0);
				return;
			end
		end

		exports.mtatr_engines:setPlayerImmuneAgainst(source);

		if quit == true then
			if president == source then
				triggerEvent ("onPTPFinished", resourceRoot);
			end
		end

		if players[source] then
			setPlayerOut (source);
		end

		updateInformation ();

		local team = getPlayerEventTeam (source);
		if team then
			for i in pairs (pending) do
				exports.mtatr_engines:updateTeamMenu (i, team, "players", getTeamCount (team));
			end
		end

		if EVENT_STARTED then
			if getTeamCount ("Hunters") == 0 then
				triggerEvent ("onPTPFinished", resourceRoot, 0);
			elseif getTeamCount ("Bodyguards") == 0 then
				triggerEvent ("onPTPFinished", resourceRoot, -1);
			end
		end

		exports.mtatr_engines:showTeamsBar (source, false);

		setElementData (source, "inevent", nil);
	end
);

addEvent ("onPTPRun");
addEventHandler ("onPTPRun", root,
	function ()
		exports.mtatr_engines:setPlayerImmuneAgainst (president, TEAMS.Bodyguards);
		for i, v in ipairs (getPlayersInEventTeam ("Bodyguards")) do
			exports.mtatr_engines:setPlayerImmuneAgainst (v, TEAMS.Bodyguards);
			exports.mtatr_engines:setPlayerImmuneAgainst (v, president);
		end
		for i, v in ipairs (getPlayersInEventTeam ("Hunters")) do
			exports.mtatr_engines:setPlayerImmuneAgainst (v, TEAMS.Hunters);
		end
		triggerEvent ("onEventRun", resourceRoot, "ptp");
	end
);

addCommandHandler ("eventcik",
	function (player)
		if not isPlayerInEvent(player) then return; end
		if not EVENT_STARTED then
			triggerEvent ("onPlayerLeavePTP", player);
		else
			outputChatBox ("Etkinliği şuan terkedemezsiniz!", player, 255, 0, 0);
		end
	end
);

addEventHandler ("onPlayerWasted", root,
	function (_, killer)
		if isElement (killer) then
			if isPlayerInEvent (killer) and isPlayerInEvent (source) then
				if killer ~= source then
					if not stats[killer] then
						stats[killer] = {};
					end
					stats[killer].kills = (stats[killer].kills or 0) + 1;

					local id = exports.database:getPlayerId (killer);
					local kills = (exports.database:getPlayerData (id, "fr_stats", "ptp.kills") or 0) + 1;
					exports.database:setPlayerData (id, "fr_stats", "ptp.kills", kills);

					local s_id = exports.database:getPlayerId (source);
					local deaths = (exports.database:getPlayerData (s_id, "fr_stats", "ptp.deaths") or 0) + 1;
					exports.database:setPlayerData (s_id, "fr_stats", "ptp.deaths", deaths);

					scores[getPlayerEventTeam (killer)] = (scores[getPlayerEventTeam (killer)] or 0) + 1;

					updateInformation (getPlayerEventTeam (killer), "score", getTeamScore (getPlayerEventTeam (killer)));

				end
			end
		end
		if isPlayerInEvent (source) then
			setTimer (spawnInEvent, 1000, 1, source);
		end
		if president == source then
			if EVENT_STARTED then
				triggerEvent ("onPresidentExecuted", resourceRoot, killer);
			end
		end
	end
);

addEventHandler ("onPlayerDamage", root,
	function (attacker, _, _, loss)
		if isElement (attacker) then
			if attacker ~= source then
				if isPlayerInEvent (attacker) and isPlayerInEvent (source) then
					if isElement (attacker) then
						if not stats[attacker] then
							stats[attacker] = {};
						end
						stats[attacker].dmg = (stats[attacker].dmg or 0) + loss;

						local id = exports.database:getPlayerId (attacker);
						local dmg = (exports.database:getPlayerData (id, "fr_stats", "ptp.dmg") or 0) + loss;
						exports.database:setPlayerData (id, "fr_stats", "ptp.dmg", dmg);
					end
				end
			end
		end
		if isPlayerInEvent (source) then
			local team = getPlayerEventTeam (source);
			if president == source then
				team = "Bodyguards";
			end
			updateInformation (team, "health", getTeamTotalHP (team));
		end
	end
);

addEventHandler ("onPickupUse", root,
	function (player)
		if isElement (player) then
			if getPickupType (source) == 0 or getPickupType (source) == 1 then
				if isPlayerInEvent (player) then
					local team = getPlayerEventTeam (player);
					if president == player then
						team = "Bodyguards";
					end
					updateInformation (team, "health", getTeamTotalHP (team));
				end
			end
		end
	end
);

addEventHandler ("onPlayerQuit", root,
	function ()
		if players[source] then
			triggerEvent ("onPlayerLeavePTP", source, true);
		end
	end
);

addEvent ("onPresidentExecuted");
addEventHandler ("onPresidentExecuted", root,
	function (executor, executorWeapon, executorWeaponAmmo, bodypart)
		if executor and isElement (executor) then
			triggerEvent ("onPTPFinished", resourceRoot, 1, executor);
		elseif executor == true then
			triggerEvent ("onPTPFinished", resourceRoot, 3);
		else
			triggerEvent ("onPTPFinished", resourceRoot, 2);
		end
		president = nil;
	end
);

-- ON PTP FINISH

-- REASON -1 = ALL BODYGUARDS QUIT
-- REASON 0 = ALL HUNTERS QUIT
-- REASON 1 = PRESIDENT EXECUTED
-- REASON 2 = PRESIDENT QUIT
-- REASON 3 = TIME IS UP
-- REASON 4 = REMOTELY CLOSED

addEvent ("onPTPFinished");
addEventHandler ("onPTPFinished", root,
	function (reason, executor)
		stopResource (maps [MAP.index]);
		if reason then
			if EVENT_STARTED then
				for v in pairs (pending) do
					exports.mtatr_engines:showTeamsBar (v, false);
					if not isPedDead (v) then
						local blip = exports.mtatr_playerblips:getPlayerBlip (v);
						setBlipSize (blip, 2);
					end
					exports.mtatr_play:disableSpawnFor (v, false);
					setPlayerOut (v);
				end
				local text 		= "";
				local kill		= getStats ("kills")[1];
				local dmg		= getStats ("dmg")[1];
				local winners;
				if kill and dmg then
					local topkiller = kill.name;
					local topdmger	= dmg.name;
					local topkill   = kill.kill;
					local topdmg 	= dmg.dmg;
					if topkiller and topdmger and topkill and topdmg then
						text = "En iyi skor: "..topkiller.."("..topkill.." öldürme)\nEn iyi hasar: "..topdmger.."("..math.floor (topdmg).." dmg)\nÖdül: "..PRIZE.money.. "₺ ve + "..PRIZE.exp.." deneyim puanı.";
					end
				end
				if reason == 3 then
					local r, g, b = unpack (TEAM_COLORS.Bodyguards);
					outputChatBox ("PTP bitti! Korumalar, başkanı "..exports.mtatr_engines:getEventProperty ("ptp", "timeout").." dakika boyunca korumayı başardı ve etkinliği kazandı!", root, r, g, b);
					for i, v in ipairs (getPlayersInEvent ()) do
						output ("Bodyguards Kazandı!", text, v, r, g, b)
					end
					winners = getPlayersInEventTeam("Bodyguards")
					winners[#winners+1] = president;
				elseif reason == 2 then
					local r, g, b = unpack (TEAM_COLORS.Hunters);
					outputChatBox ("PTP bitti! Hunters, başkan oyundan çıktığı için etkinliği kazandı!", root, r, g, b);
					for i, v in ipairs (getPlayersInEvent ()) do
						output ("Hunters Kazandı!", text, v, r, g, b)
					end
					winners = getPlayersInEventTeam("Hunters");
				elseif reason == 1 then
					local r, g, b = unpack (TEAM_COLORS.Hunters);
					if isElement (executor) then
						outputChatBox ("PTP bitti! Başkan, "..executor:getName().." tarafından öldürüldü!", root, r, g, b);
					else
						outputChatBox ("PTP bitti! Başkan kaza sonucu öldü.", root, r, g, b);
					end
					for i, v in ipairs (getPlayersInEvent ()) do
						output ("Hunters Kazandı!", text, v, r, g, b)
					end
					winners = getPlayersInEventTeam("Hunters");
				elseif reason == 0 then
					local r, g, b = unpack (TEAM_COLORS.Bodyguards);
					outputChatBox ("PTP bitti! Bodyguards, Hunters takımındaki tüm oyuncuları öldürmeyi başardı!", root, r, g, b);
					for i, v in ipairs (getPlayersInEvent ()) do
						output ("Korumalar kazandı!", text, v, r, g, b)
					end
					winners = getPlayersInEventTeam("Bodyguards")
				elseif reason == -1 then
					local r, g, b = unpack (TEAM_COLORS.Hunters);
					outputChatBox ("PTP bitti! Hunters, Bodyguards takımındaki tüm oyuncuları öldürmeyi başardı!", root, r, g, b);
					for i, v in ipairs (getPlayersInEvent ()) do
						output ("Hunters Kazandı!", text, v, r, g, b)
					end
					winners = getPlayersInEventTeam("Hunters");
				end

				for i, v in ipairs (winners) do
					exports.database:givePlayerMoney (v, PRIZE.money, "Event PTP");
					exports.mtatr_mode:givePlayerCharacterExperience (v, PRIZE.exp, "Event PTP");
				end

				for i, v in ipairs (getPlayersInEvent ()) do
					exports.mtatr_engines:showTeamsBar (v, false);
					exports.mtatr_engines:setEventFinished (v, 6);
					setTimer (setPlayerOut, 6000, 1, v);
					if not isPedDead (v) then
						local blip = exports.mtatr_playerblips:getPlayerBlip (v);
						setBlipSize (blip, 2);
					end
					exports.mtatr_play:disableSpawnFor (v, false)
				end
				setTimer (triggerEvent, 6500, 1, "onEventFinished", resourceRoot, "Protect the President");
			end
		else
			for i, v in ipairs (getPlayersInEvent ()) do
				exports.mtatr_engines:showTeamsBar (v, false);
				if not isPedDead (v) then
					local blip = exports.mtatr_playerblips:getPlayerBlip (v);
					setBlipSize (blip, 2);
				end
				exports.mtatr_play:disableSpawnFor (v, false);
				setPlayerOut (v);
			end
			for v in pairs (pending) do
				exports.mtatr_engines:showTeamsBar (v, false);
				if not isPedDead (v) then
					local blip = exports.mtatr_playerblips:getPlayerBlip (v);
					setBlipSize (blip, 2);
				end
				exports.mtatr_play:disableSpawnFor (v, false);
				setPlayerOut (v);
			end
			outputChatBox ("PTP bitti.", root, 255, 255, 0);
			triggerEvent ("onEventFinished", resourceRoot, "Protect the President");
		end
	end
);

addEvent ("onPTPStarted");
addEventHandler ("onPTPStarted", root,
	function ()
		timers.timeout = setTimer (
			function ()
				local situation = (getTeamCount ("Bodyguards") < LIMIT/2 and getTeamCount ("Hunters") < LIMIT/2);
				if not EVENT_STARTING or not EVENT_STARTED then
					if not situation then
						killEvent ();
					else
						EVENT_STARTING = true; -- if this is true, players can't leave the event.
						timers.starter = Timer (
							function ()
								runEvent ();
							end,
						60*1000, 1);
					end
				end
			end,
		2*60*1000, 1);
	end
);

addEvent ("onCountDownReachedToEnd");
addEventHandler ("onCountDownReachedToEnd", root,
	function ()
		if EVENT_STARTING then
			for i, v in ipairs (getPlayersInEvent ()) do
				setElementFrozen (v, false);
				toggleAllControls (v, true);
				exports.mtatr_engines:startTeamsBarTimer (v);
				EVENT_STARTED = true;
			end
			local blip = exports.mtatr_playerblips:getPlayerBlip (president);
			setBlipSize (blip, 5);
			triggerEvent ("onPTPRun", resourceRoot);
		end
	end
);

function runEvent ()
	for i, v in ipairs (getPlayersInEvent ()) do
		exports.mtatr_engines:startCountDown (v);
	end
end

function killEvent ()
	for i, v in ipairs (getPlayersInEvent ()) do
		exports.mtatr_engines:output ("ETKİNLİK BAŞLATILAMADI", "Yeterli sayıda katılım olmadığından etkinlik sonlandırıldı. Yönlendiriliyorsunuz...", v, 255, 0, 0);
		setElementFrozen (v, false);
		toggleAllControls (v, true);
	end
	setTimer (triggerEvent, 3000, 1, "onPTPFinished", resourceRoot);
	killPlayers ();
end

-------MAPS--------

function initializeMap ()
	for i, v in ipairs (getResources ()) do
		if v:getName ():find ("ptp_") then
			table.insert (maps, v);
		end
	end
end
addEventHandler ("onResourceStart", resourceRoot, initializeMap);

function getRandomMap ()
	return maps[math.random (#maps)];
end

function startMap ()
	MAP.index = MAP.index + 1;
	if not maps[MAP.index] then
		MAP.index = 1;
	end
	local curmap = maps [MAP.index];
	startResource (curmap);
	MAP.mapper = getResourceInfo (curmap, "author");
	MAP.name = getResourceInfo (curmap, "name");
	LIMIT = (#getElementsByType"Team1" + #getElementsByType"Team2") / 4;
	local settings = exports.mtatr_engines:getResourceSettings (curmap);
	if settings then
		PRIZE.money = fromJSON (settings.prize_money.value);
		PRIZE.exp = fromJSON (settings.prize_exp.value);
	else
		PRIZE.money = defaults.money;
		PRIZE.exp = defaults.exp;
	end
	MAP.spawnpoints = {
		["Hunters"] = {};
		["Bodyguards"] = {};
	};

	for i, v in ipairs (getElementsByType"Team1") do
		local x, y, z = getElementPosition (v);
		local rot = getElementData (v, "rotZ")
		table.insert (MAP.spawnpoints.Bodyguards, {pos = {x, y, z}, rot = rot});
	end

	for i, v in ipairs (getElementsByType"Team2") do
		local x, y, z = getElementPosition (v);
		local rot = getElementData (v, "rotZ")
		table.insert (MAP.spawnpoints.Hunters, {pos = {x, y, z}, rot = rot});
	end
end

function addRestriction (player, dim)
	if isElement (player) and dim then
		exports.mtatr_engines:addRestriction (player, RESTRICT_TIME);
	end
end

function removeRestriction (player, dim)
	if isElement (player) and dim then
		exports.mtatr_engines:removeRestriction (player);
	end
end
