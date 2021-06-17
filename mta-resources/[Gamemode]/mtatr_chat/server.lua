local muted		 = {};
local interval 	 = {};
local anti_spam	 = {};
local block_spam = 1000 -- ms

addEventHandler ("onResourceStart", getRootElement(),
	function (res)
		if getResourceName (res) == getResourceName (getThisResource ()) then
			db = exports.database:dbConnect();
			dbExec (db, "CREATE TABLE IF NOT EXISTS log_chat (id INT (11) auto_increment, time INT, date TEXT, type TEXT, source INT, player TEXT, text TEXT, target TEXT, target_player TEXT, PRIMARY KEY (`id`))");
		elseif 	getResourceName (res) == "database" then
			db = exports.database:dbConnect();
		end
	end
);

function _setPlayerMuted(player, time)
	local serial = player:getSerial();
	setPlayerMuted (player, true);
	muted[player] = Timer (
		function (p, s)
			interval[s] = nil;
			if isElement (p) then
				muted[p] = nil;
				if isPlayerMuted (p) then
					setPlayerMuted (p, false);
					outputChatBox (p:getName().." has been unmuted by Console", root, 0, 255, 0);
				end
			end
		end,
	time * 60 * 1000, 1, player, serial);
	return true;
end

function getNearByPlayers (player)
	local t = {};
	local dim = getElementDimension (player);
	local int = getElementInterior (player);
	for _, v in ipairs (getElementsByType"player") do
		local pX, pY, pZ = getElementPosition (player);
		local rootX, rootY, rootZ = getElementPosition (v);
		local distance = getDistanceBetweenPoints2D (pX, pY, rootX, rootY);
		local dim_ = getElementDimension (v);
		local int_ = getElementInterior (v);
		if distance and distance <= 40 and dim_ == dim and int == int_ then
			table.insert (t, v);
		end
	end
	return t;
end

addEventHandler ("onPlayerChat", root,
	function (msg, _t)
		local msg = msg;
		while msg:find ("#%x%x%x%x%x%x") do
			msg = msg:gsub("#%x%x%x%x%x%x", "");
		end

		if isAdvertising(msg) then
			cancelEvent();
			banPlayer(source, true, false, true, nil, "Reklam: "..msg, 0);
			return;
		end

		if anti_spam[source] then
			cancelEvent();
			return;
		end

		if not anti_spam[source] then
			anti_spam[source] = setTimer (
				function (p)
					anti_spam[p] = nil;
				end,
			block_spam, 1, source);
		end

		if not exports.mtatr_accounts:isPlayerInGame(source) then cancelEvent(); return; end
		if _t == 0 then
			cancelEvent ();
			local cursed = exports.mtatr_misc:hasPlayerCursed (msg);
			if cursed then
				_setPlayerMuted (source, cursed);
				outputChatBox (source:getName().." uygunsuz mesaj göndermeye çalıştığı için susturuldu ("..cursed.." dakika)", root, 255, 0, 0);
				return;
			end
			local r, g, b = getPlayerNametagColor(source);
			local name = getPlayerName(source);
			local code = "#ffffff";
			if exports.mtatr_accounts:isPlayerAdmin (source) then
				-- code = "#EFF704";
			end
			writeLog (source, msg, "SAY", getElementsByType"player");
			outputChatBox( name.. ": ".. code .. msg, root, r, g, b, true);
			outputServerLog( "CHAT: " .. name .. ": " .. msg );
			if getResourceFromName ("irc") and getResourceState (getResourceFromName ("irc")) == "running" then
				exports.irc:outputIRC ("07" .. noHighlight(getPlayerName(source))..": 01"..msg);
			end
			if getResourceFromName ("discord") and getResourceState (getResourceFromName ("discord")) == "running" then
			end
		elseif _t == 2 then
			cancelEvent ();
			local teams_type = exports.mtatr_main:getTeamsType () == "teams";
			if teams_type then
				local r, g, b = getPlayerNametagColor(source);
				local name = getPlayerName(source);
				local _r, _g, _b = exports.mtatr_deathmatches:getDeathmatchColors();
				local color = exports.mtatr_utils:RGBToHex (_r, _g, _b);
				for i, v in ipairs (getPlayersInTeam (getPlayerTeam (source))) do
					outputChatBox( "[TELSİZ] " .. name.. ": ".. color .. msg, v, r, g, b, true );
				end
				outputServerLog( "TELSIZ CHAT: " .. name .. ": " .. msg );
				writeLog (source, "("..getTeamName (getPlayerTeam (source))..")"..msg, "TELSIZ", getPlayersInTeam (getPlayerTeam (source)));
			else
				local name = getPlayerName(source)
				local r, g, b = getPlayerNametagColor(source)
				local message =  "[GRUP] "..name.. ': #FFFFFF' .. msg;
				for i, v in ipairs (getPlayersInTeam (getPlayerTeam (source))) do
					outputChatBox(message, v, r, g, b, true);
				end
				outputServerLog( "TEAM: " .. name .. ": " .. msg );
				writeLog (source, "("..getTeamName (getPlayerTeam (source))..")"..msg, "TEAM", getPlayersInTeam (getPlayerTeam (source)));
			end
		end
	end
);

function noHighlight(nick)
    local middle = math.ceil(#nick/2)
    local part1 = string.sub(nick,0,middle)
    local part2 = string.sub(nick,middle+2)
    return part1.."*"..part2
end


addEventHandler ("onPlayerJoin", root,
	function ()
		local int = interval[source:getSerial()];
		if int then
			int = int/60/1000;
			_setPlayerMuted (source, int);
		end
		bindKey (source, "i", "down", "chatbox", "Telsiz");
		bindKey (source, "u", "down", "chatbox", "Lokal");
	end
);

addEventHandler ("onPlayerQuit", root,
	function ()
		if isTimer (muted[source]) then
			interval[source:getSerial()] = getTimerDetails (muted[source]);
			killTimer (muted[source]);
			muted[source] = nil;
			if not isPlayerMuted (source) then
				return;
			end
		end
	end
);

addCommandHandler ("Telsiz",
	function (player, cmd, ...)
		local teams_type = exports.mtatr_main:getTeamsType () == "scoreboard";
		local msg = table.concat ({...}, " ");
		if isAdvertising(msg) then
			banPlayer(player, true, false, true, nil, "Reklam: "..msg, 0);
			return;
		end
		if teams_type then
			if exports.mtatr_deathmatches:isPlayerInDeathmatch (player) then
				local dm = exports.mtatr_deathmatches:getPlayerCurrentDeathmatch (player);
				local r, g, b = getPlayerNametagColor(player)
				local name = getPlayerName(player)
				local _r, _g, _b = exports.mtatr_deathmatches:getDeathmatchColors();
				local color = exports.mtatr_utils:RGBToHex (_r, _g, _b);
				for i, v in ipairs (exports.mtatr_deathmatches:getPlayersInDeathmatch (dm)) do
					outputChatBox( "[TELSİZ] " .. name.. ": ".. color .. msg, v, r, g, b, true );
				end
				outputServerLog( "TELSIZ: " .. name .. ": " .. msg );
				writeLog (player, msg, "TELSIZ", {});
			-- elseif exports.mtatr_jobs:isPlayerInJob (player) then
				-- local job = exports.mtatr_jobs:getPlayerCurrentJob (player);
				-- local r, g, b = getPlayerNametagColor(player)
				-- local name = getPlayerName(player)
				-- local _r, _g, _b = exports.mtatr_deathmatches:getDeathmatchColors();
				-- local color = exports.mtatr_utils:RGBToHex (_r, _g, _b);
				-- for i, v in ipairs (exports.mtatr_jobs:getPlayersInJob (job)) do
					-- outputChatBox( "[TELSİZ] " .. name.. ": ".. color .. msg, v, r, g, b, true );
				-- end
				-- outputServerLog( "TELSIZ: " .. name .. ": " .. msg );
				-- writeLog (player, msg, "TELSIZ", {});
			end
		else
			if not exports.mtatr_teams:isPlayerInAGroup (player) then return; end
			exports.mtatr_teams:chatGroup (player, msg);
			writeLog (player, msg, "TEAM", getPlayersInTeam (getPlayerTeam (player)));
		end
	end
);

addCommandHandler ("Lokal",
	function (player, cmd, ...)
		if #getNearByPlayers (player) == 1 then
			outputChatBox ("* Yakında kimse yok!", player, 200, 0, 0);
			return;
		end
		local msg = table.concat ({...}, " ");
		if isAdvertising(msg) then
			banPlayer(player, true, false, true, nil, "Reklam: "..msg, 0);
			return;
		end
		local name = getPlayerName(player) ;
		local r, g, b = getPlayerNametagColor(player);
		local message =  "[LOKAL] "..name.. ': #FFFFFF' .. msg;
		for i, v in ipairs (getNearByPlayers(player)) do
			outputChatBox(message, v, r, g, b, true);
		end
		outputServerLog( "LOCAL: " .. name .. ": " .. msg );
		writeLog (player, msg, "LOCAL", getNearByPlayers(player));
	end
);

do
	for i, v in ipairs (getElementsByType"player") do
		bindKey (v, "i", "down", "chatbox", "Telsiz");
	end
	for i, v in ipairs (getElementsByType"player") do
		bindKey (v, "u", "down", "chatbox", "Lokal");
	end
end

addEvent ("onDiscordUserSendMessage");
addEventHandler ("onDiscordUserSendMessage", root,
	function (nick, msg)
		if nick == "MTA-TR Bot" then return; end
		if isAdvertising(msg) then return; end
		outputChatBox ("*Discord "..nick..": #ffffff"..msg, root, 114, 137, 218, true);
	end
);

function isAdvertising(ip)
    -- must pass in a string value
    if ip == nil or type(ip) ~= "string" then
        return 0
    end

    -- check for format 1.11.111.111 for ipv4
    local chunks = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
    if (#chunks == 4) then
        for _,v in pairs(chunks) do
            if (tonumber(v) < 0 or tonumber(v) > 255) then
                return false
            end
        end
        return true
    end
	local advert = {
		"gaming",
		"GAMİNG",
		"MTASA-TURK.com",
	};
	for i, v in ipairs (advert) do
		if ip:find(v) then
			return true;
		end
	end
    return false
end

function writeLog (player, text, _type, target)
	local player = player;
	local player_name = getPlayerName (player);
	local id_source, id_target = exports.database:getPlayerId(player), "";
	local target_player = "";
	if getElementType(player) == "irc-user" then
		id_source = 0;
		player_name = exports.irc:ircGetUserNick (player);
	end
	if target and type (target) == "userdata" then
		if target ~= player then
			id_target = exports.database:getPlayerId (target);
			target_player = getPlayerName (target);
		end
	elseif target and type (target) == "table" then
		local players = {id = {}, name = {}};
		for i, v in ipairs (target) do
			if v ~= player then
				table.insert (players.id,  exports.database:getPlayerId (v))
				table.insert (players.name, getPlayerName (v));
			end
		end
		id_target = toJSON (players.id)
		target_player = toJSON (players.name);
		if #fromJSON (id_target) == 0 and #fromJSON (target_player) == 0 then
			id_target, target_player = "", "";
		end
	end

	dbExec (db, "INSERT INTO log_chat (time, date, type, source, player, text, target, target_player) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", getRealTime().timestamp, exports.mtatr_utils:todate(getRealTime().timestamp), _type, id_source, player_name, text, id_target, target_player);
end
