_dbConnect = dbConnect;

function dbConnect ()
	local dbName = getSystemEnvVariable("MYSQL_DB_NAME");
    local host = getSystemEnvVariable("PROJECT_NAME").."mysql-server";
    if getSystemEnvVariable("MTA_ENVIRONMENT") == "Local" then
        host = getSystemEnvVariable("HOST_IP");
    end
	local user, pass = getSystemEnvVariable("MYSQL_DB_USER"), getSystemEnvVariable("MYSQL_DB_PASSWORD");
	local db = _dbConnect ("mysql", "dbname="..dbName..";host="..host, user, pass);
	if sourceResource and type (sourceResource) == "userdata" then
		addEventHandler ("onResourceStop", getResourceRootElement (sourceResource),
			function ()
				destroyElement (db);
			end
		);
	end
	return db;
end

local db 			= dbConnect ();
local ID 			= {};
local mail			= {};
local console 		= {};
local serial		= {};
local taken_names 	= {};
local addresslist 	= {};
local maxID 		= 0;

local db_tables = {
	userinfo = {},
	fr_stats = {},
};

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		local tick = getTickCount ();
		local count = 0;
		for i, data in pairs (db_tables) do
			local query = "SELECT * FROM "..i;
			local qh = dbQuery (db, query);
			local result = dbPoll (qh, -1);
			for _, v in ipairs (result) do
				if not data[v.mail] then
					data[v.mail] = {};
					ID[v.id] = v.mail;
					mail[v.mail] = v.id;
					if v.serial then
						if not serial[v.serial] then
							serial[v.serial] = {};
						end
						table.insert (serial[v.serial], v.id);
					end
				end

				if (maxID < v.id) then	maxID = v.id; end

				for column, value in pairs (v) do
					if not console[i] then
						console[i] = {};
					end
					console[i][column] = true;
					data[v.mail][column] = value;
					if column == "characters" then
						if value then
							for char in pairs (fromJSON (value)) do
								taken_names [char:lower()] = true;
							end
						end
					end
				end
				if i == "userinfo" then
					count = count + 1;
				end
			end
		end
		for i, v in ipairs  (dbPoll (dbQuery (db, "SELECT DISTINCT user_id, serial, address FROM addresslist"), -1) or {}) do
			if not addresslist[v.user_id] then
				addresslist[v.user_id] = {};
			end
			table.insert (addresslist[v.user_id],
				{
					serial = v.serial,
					ip = v.address,
				}
			);
		end
		triggerEvent ("onDatabaseReady", resourceRoot, "main_db");
		outputDebugString ("Cached "..count.." account(s) in "..getTickCount()-tick.." ms.");
	end
);
-------------EXPORTS-----------
function setPlayerData (id, tbl, key, data)
	if not id or not key or not tbl then return false; end
	local mail_ = id;
	local method = "id";
	local id = tonumber (id);
	if not id then method = "mail"; end
	id = method == "id" and getAccountFromID (id) or mail_;

	if not db_tables[tbl][id] then
		db_tables[tbl][id] = {};
		dbExec (db, "INSERT INTO `"..tbl.."` (mail) VALUES (?)", id);
		if tbl == "userinfo" then
			local user_id = maxID + 1;
			db_tables.userinfo[id].id = user_id;
			mail[id] = user_id;
			ID[user_id] = id;
		end
	end

	if not console[tbl] then
		console[tbl] = {};
	end

	if not console[tbl][key] then
		dbExec(db, "ALTER TABLE `"..tbl.."` ADD `??` text", key);
		console[tbl][key] = true;
	end

	if db_tables[tbl][id] then
		dbExec (db, "UPDATE `"..tbl.."` SET `??` = ? WHERE mail = ?", key, data, id);
		db_tables[tbl][id][key] = data;
	end

	id = getIDFromAccount (id);

	if key == "serial" and tbl == "userinfo" then
		if not serial[data] then
			serial[data] = {};
		end
		table.insert (serial[data], id);
	end

	if (maxID < id) then maxID = id; end

	return true;
end

function getPlayerData (id, tbl, key)
	if not id or not key or not tbl then return false; end
	local mail_ = id;
	local method = "id";
	local id = tonumber (id);
	if not id then method = "mail"; end
	id = method == "id" and getAccountFromID (id) or mail_;

	if not db_tables[tbl][id] then return false; end

	local data = db_tables[tbl][id][key];
	if data == "true" then
		data = true;
	elseif data == "false" then
		data = false;
	end
	return tonumber (data) or data;
end

function getAccounts()
	local tbl = {};
	for i, v in pairs (db_tables.userinfo) do
		table.insert (tbl, v);
	end
	table.sort (tbl, function(a, b) return a.id < b.id; end);
	return tbl;
end
function getAccountFromID (id)
	return ID[id];
end

function getIDFromAccount (acc)
	return mail[acc];
end

function getAccountSerial (id)
	return getPlayerData (id, "userinfo", "serial");
end

function getAccountFromSerial (num)
	return serial[num];
end

function resetAccountPassword (id)
	local reset_pass = "12345678";
	return setPlayerData (id, "userinfo", "password", md5 (reset_pass));
end

function setAccountPassword (id, pass)
	return setPlayerData (id, "userinfo", "password", md5 (pass));
end

function setAccountName (id, name)
	local old_name = getPlayerData (id, "userinfo", "mail");
	mail[old_name] = nil;
	ID[id] = name;

	for i, v in pairs (db_tables) do
		setPlayerData (id, i, "mail", name);
		v[old_name] = nil;
	end
end

function getPlayerId (player)
	return isElement (player) and getElementData (player, "ID");
end

function getPlayerAccount (player)
	return isElement (player) and ID[getElementData (player, "ID")];
end

function getAccountPlayer (acc)
	for i, v in ipairs (getElementsByType"player") do
		if getPlayerAccount (v) == acc then
			return v;
		end
	end
	return false;
end

function getPlayerFromID (id)
	for i, v in ipairs (getElementsByType"player") do
		if getPlayerId(v) == id then
			return v;
		end
	end
	return false;
end

function getAccountCharacters (id)
	return fromJSON (getPlayerData (id, "fr_stats", "characters") or "[[]]");
end

function getAccountCharacterList (id)
	local chars = fromJSON (getPlayerData (id, "fr_stats", "characters") or "[[]]");
	local tbl = {};
	for i, v in pairs (chars) do
		v.name = i;
		table.insert (tbl, v);
	end
	table.sort (tbl, function (a, b) return a.creation < b.creation; end );

	return tbl;
end

function setCharacterData (id, char, key, data)
	local chars = getAccountCharacters (id);
	if not chars[char] then
		chars[char] = {};
		taken_names[char:lower()] = true;
	end
	chars[char][key] = data;
	return setPlayerData (id, "fr_stats", "characters", toJSON (chars));
end

function getCharacterData (id, char, key)
	local chars = getAccountCharacters (id);
	return chars[char] and chars[char][key];
end

function getPlayerCharacters (player)
	if isElement (player) then
	local id = getPlayerId (player);
		return getAccountCharacters (id);
	end
end

function getPlayerCharacterList (player)
	if isElement (player) then
	local id = getPlayerId (player);
		return getAccountCharacterList (id);
	end
end

function setPlayerCharacterData (player, char, key, data)
	local id = getPlayerId (player);
	return setCharacterData (id, char, key, data);
end

function getPlayerCharacterData (player, char, key)
	local id = getPlayerId (player);
	return getCharacterData (id, char, key);
end

function isCharacterNameAvailable (name)
	return not taken_names[name:lower()];
end

function getAccountLastPlayedCharacter (id)
	return getPlayerData (id, "fr_stats", "last_played_char");
end

_giveMoney = givePlayerMoney;
function givePlayerMoney (player, amount, reason)
	if not reason then
		if type (sourceResource) == "userdata" then
			outputDebugString (sourceResource:getName().. " used givePlayerMoney without a reason.", 2);
		end
	end
	local id = getPlayerId (player);
	if id then
		setPlayerData (id, "fr_stats", "money", getPlayerMoney (player) + amount);
		setElementData (player, "Para", getPlayerMoney (player) + amount.."₺");
		writeLog (id, "money", amount, reason);
		return _giveMoney(player, amount);
	end
end

_takeMoney = takePlayerMoney;
function takePlayerMoney (player, amount, reason)
	if not reason then
		if type (sourceResource) == "userdata" then
			outputDebugString (sourceResource:getName().. " used takePlayerMoney without a reason.", 2);
		end
	end
	local id = getPlayerId (player);
	if id then
		setPlayerData (id, "fr_stats", "money", getPlayerMoney (player) - amount);
		setElementData (player, "Para",  getPlayerMoney (player) - amount.."₺");
		writeLog (id, "money", amount*-1, reason);
		return _takeMoney(player, amount);
	end
end

_setMoney = setPlayerMoney;
function setPlayerMoney (player, amount, reason)
	if not reason then
		if type (sourceResource) == "userdata" then
			outputDebugString (sourceResource:getName().. " used setPlayerMoney without a reason.", 2);
		end
	end
	local id = getPlayerId (player);
	if id then
		setPlayerData (id, "fr_stats", "money", amount);
		setElementData (player, "Para", amount.."₺");
		writeLog (id, "money", amount, reason);
		return _setMoney(player, amount);
	end
end

function addBankMoney (player, amount, reason)
	if not reason then
		if type (sourceResource) == "userdata" then
			outputDebugString (sourceResource:getName().. " used addBankMoney without a reason.", 2);
		end
	end
	local id = getPlayerId (player) or player;
	local newamount = tonumber  (getPlayerData (id, "fr_stats", "money")) + tonumber(amount);
	local acc;
	if tonumber (player) then
		acc =  tonumber(player);
		if isElement (getPlayerFromID (player)) then
			givePlayerMoney (getPlayerFromID (player), tonumber(amount), "Bank");
			return
		end
	end
	if isElement (player) then
		acc = getPlayerId (player);
	end
	setPlayerData (acc, "fr_stats", "money", newamount);
	writeLog (id, "bank", amount, reason);
	return true;
end

dbExec (db, "CREATE TABLE IF NOT EXISTS log_bank (id INT (11) auto_increment, category TEXT, user_id INT, username TEXT, text TEXT, cash INT, balance INT, time INT, PRIMARY KEY (`id`))");

function writeLog (id, category, cash, text)
	if id and text then
		local tbl = "log_bank";
		local name = getAccountLastPlayedCharacter(id);
		local balance = getPlayerData (id, "fr_stats", "money");
		local timestamp = getRealTime().timestamp + 7200;
		dbExec (db, "INSERT INTO "..tbl.." (category, user_id, username, text, cash, balance, time) VALUES (?, ?, ?, ?, ?, ?, ?)", category, id, name, text, cash, balance, timestamp);
	end
end

function getPlayerAddressList (player)
	local id = getPlayerId (player)
	return addresslist[id];
end

function getAddressList ()
	return addresslist;
end

function getAccountAddressList (id)
	return addresslist[id];
end

function getSerialAddressList (serial)
	local list = {};
	for i, tbl in pairs (addresslist) do
		for _, v in pairs (tbl) do
			if v.serial == serial then
				table.insert (list,
					{
						account = i,
						ip = v.ip
					}
				)
			end
		end
	end
	return list
end

function getIPAddressList (ip)
	local list = {};
	for i, tbl in pairs (addresslist) do
		for _, v in pairs (tbl) do
			if v.ip == ip then
				table.insert (list,
					{
						account = i,
						serial = v.serial
					}
				)
			end
		end
	end
	return list;
end

function addPlayerAddress (player)
	local id = getPlayerId (player);
	if not addresslist[id] then
		addresslist[id] = {};
	end
	for i, v in ipairs (addresslist[id]) do
		if (v.serial == getPlayerSerial  (player)) and (v.ip == getPlayerIP (player)) then
			return
		end
	end
	if cond then
		table.insert (addresslist[id],
			{
				serial = getPlayerSerial  (player),
				ip = getPlayerIP (player),
			}
		);
	end
	dbExec (db, "INSERT INTO addresslist (user_id, serial, address) VALUES (?, ?, ?)", id, getPlayerSerial  (player), getPlayerIP (player))
end
