function notificate (player, text, r, g, b)
	triggerClientEvent (player, "login.notificate", player, text, {r, g, b});
end

addEvent ("onPlayerCoreRegister");
addEvent ("onPlayerCoreLogin");

function canPlayerRegister (player, name)
	local max_acc = 3;
	local serial = getPlayerSerial(player);
	local acc = exports.database:getAccountFromSerial (serial);
	if (acc and type (acc) == "table" and #acc >= max_acc) then
		return false, "Bir bilgisayarda en fazla "..max_acc.." hesap kaydedebilirsiniz.";
	end
	if exports.database:getPlayerData (name, "userinfo", "id") then
		return false, "Bu e-mail adresi zaten bir hesaba kayıtlı.";
	end
	return true;
end

addEvent ("onPlayerRequestRegistration", true);
addEventHandler ("onPlayerRequestRegistration", root, 
	function (mail, pass)	
		local isvalid, err = canPlayerRegister (client, mail);
		if not isvalid then
			notificate (client, err, 255, 0, 0);
			return
		end		
		registerPlayer (client, mail, pass);
	end
);

function registerPlayer (player, mail, pass)
	local info = {
		password = md5 (pass),
		serial = getPlayerSerial (player),
		registerdate = getRealTime().timestamp,
		lastseen = getRealTime().timestamp,
	};
	for i, v in pairs (info) do
		exports.database:setPlayerData (mail, "userinfo", i, v);
	end
	local stats = {
			money = 10000,
			lastseen = getRealTime().timestamp,
		};
	for i, v in pairs (stats) do
		exports.database:setPlayerData (mail, "fr_stats", i, v);
	end
	triggerEvent ("onPlayerCoreRegister", player, mail);
end

function canPlayerLogin (player, name, pass)
	local u_pass = exports.database:getPlayerData (name, "userinfo", "password");
	if not u_pass then
		return false, "Yanlış şifre veya e-mail adresi girdiniz.";
	end
	local pass = md5 (pass);
	if pass ~= u_pass then
		return false, "Yanlış şifre veya e-mail adresi girdiniz.";
	end
	if isElement (exports.database:getAccountPlayer (name)) then
		return false, "Bu hesapta biri zaten oyunda!";
	end
	if isPlayerLoggedIn (player) then
		return false, "Çoktan giriş yaptınız!";
	end
	return true;
end

addEvent ("onPlayerRequestLogin", true);
addEventHandler ("onPlayerRequestLogin", root,
	function (mail, pass)
	local isvalid, err = canPlayerLogin (client, mail, pass);
	if not isvalid then
		notificate (client, err, 255, 0, 0);
		return
	end
	logPlayerIn (client, mail);
	end
);	

function logPlayerIn (player, mail)
	triggerClientEvent (player, "onClientPlayerLogin", player);	
	triggerEvent ("onPlayerCoreLogin", player, mail);
end

addEventHandler ("onPlayerCoreRegister", root, 
	function (mail)
		logPlayerIn (source, mail);
	end
);	

addEvent ("onPlayerCoreLogin");
addEventHandler ("onPlayerCoreLogin", root, 
	function (mail)
		setElementData (source, "ID", exports.database:getIDFromAccount (mail));
		local function g_Data (data)
			local id = exports.database:getPlayerId (source);
			return exports.database:getPlayerData (id, "fr_stats", data);
		end
		local money = g_Data ("money") or 0;
		local data = {
			["Para"] = money.."₺",
			loggedin = true,
		};
		for i, v in pairs (data) do 
			setElementData (source, i, v);
		end
		setPlayerMoney (source, money);
		exports.database:addPlayerAddress(source);
	end
);

function isPlayerLoggedIn (player)
	return getElementData (player, "loggedin");
end

local occupied = {};

function findNextSlot(player)
	local i = 1;
	while occupied[i] do 
		i = i+1;
	end
	return i;
end
	
addEventHandler ("onPlayerJoin", root, 
	function ()
		setElementData (source, "Ülke", exports.admin:getPlayerCountry(source) or "-");
		local slot = findNextSlot();
		occupied[slot] = source;
		setPlayerName (source, "mta-tr.com".. (slot or 1));
	end
);

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root, 
	function ()
		for i, v in pairs (occupied) do 
			if v == source then 			
				occupied[i] = nil;
			end
		end
	end
);	

addEventHandler ("onPlayerQuit", root, 
	function ()
		for i, v in pairs (occupied) do 
			if v == source then 			
				occupied[i] = nil;
			end
		end
	end
);	