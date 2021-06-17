setGameType"GÜNLÜK ETKİNLİKLER GÖREVLER VE DAHA FAZLASI";
setMaxPlayers(150);
setGlitchEnabled ("crouchbug", true);

addEventHandler ("onPlayerDamage", root,
	function (attacker)
		if attacker then
			if attacker ~= source then
				if exports.mtatr_deathmatches:isPlayerInDeathmatch (attacker) then
					if getElementType (source) == "player" then
						triggerClientEvent (attacker, "misc.playDamageSound", attacker);
					end
				end
			end
		end
	end
)

local server = {};

local db

local database_online	-- Is server_stats Database Online?
local server = {}		-- 'server_stats' Database Cache

addEvent("onDatabaseLoad", true)	-- Triggers when database is ready

addEventHandler("onResourceStart",root,
	function(res)
		if ( res == getThisResource() ) or res == getResourceFromName("database")  then
			if (not getResourceFromName("database") or getResourceState(getResourceFromName("database")) ~= "running") then return end
			db = exports.database:dbConnect()
			dbExec(db, "CREATE TABLE IF NOT EXISTS `server_stats`(`id` INT NOT NULL AUTO_INCREMENT, `key` TEXT, `value` TEXT, PRIMARY KEY(id))")
			if not loaded then
				dbQuery(cacheDatabase, db, "SELECT * FROM `server_stats`")
				loaded = true
			end
		end
	end
);

function cacheDatabase(qh)
	local result = dbPoll(qh, 0)
	for i,row in ipairs(result) do
		server[row.key] = row.value
	end
	database_online = true
	triggerEvent("onDatabaseLoad", resourceRoot, "server_stats")
	if getServerPort() == 22003 then
		local peak = getServerStat("peak") or 0
		-- setMaxPlayers(peak+1)
	end
end

-- Database Exports
-------------------->>

function setServerStat(key, value)
	if (not database_online) then return false end
	if (not key or type(key) ~= "string") then return false end

	if (server[key] == nil) then
		dbExec(db, "INSERT INTO `server_stats`(`key`,`value`) VALUES(?,?)", key, tostring(value))
	else
		if (value ~= nil) then
			dbExec(db, "UPDATE `server_stats` SET `value`=? WHERE `key`=?", tostring(value), key)
		else
			dbExec(db, "UPDATE `server_stats` SET `value`=NULL WHERE `key`=?", key)
		end
	end
	server[key] = value
	return true
end

function getServerStat(key)
	if (not database_online) then return end
	if (not key or type(key) ~= "string") then return end
	return tonumber(server[key]) or server[key]
end

function modifyServerStat(key, value)
	local stat = getServerStat(key) or 0
	if (type(stat) ~= "number") then return false end
	return setServerStat(key, stat + value)
end

addEventHandler("onPlayerJoin", root,
	function()
		local peak = getServerStat("peak") or 0
		local players = #getElementsByType("player")
		if (players > peak) then
			outputChatBox("PEAK: Sunucu en fazla oyuncu sayısına ulaştı! "..players.."!", root, 150, 255, 150);
			setServerStat("peak", players)
			if getServerPort() == 22003 then
				-- setMaxPlayers(players+5)
			end
			for i,v in ipairs(getElementsByType("player")) do
				exports.database:givePlayerMoney(v, 300, "Peak");
			end
		end
	end
);
