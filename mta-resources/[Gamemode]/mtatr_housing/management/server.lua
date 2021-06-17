HOUSING_LIMIT = 4;
local spawn_in_house = {};

addEvent ("onClientPlayerRequestHouseManagementPanel", true);
addEvent ("onClientPlayerExitsHouse", true);

addEventHandler ("onClientPlayerExitsHouse", root, 
	function (id)
		fadeCamera (client, false, .3);
		setTimer (
			function (p, i)
				local location = getHouseData (i, "location");
				local rotation = location.rotation;
				local rx, ry, rz = unpack (rotation.exit);
				local x, y, z = unpack (location.exit);
				local rot = findRotation (x, y, rx, ry);
				setElementPosition (p, x, y, z);
				setElementDimension (p, 0);
				setElementInterior (p, 0);				
				setElementRotation (p, 0, 0, rot);
				fadeCamera (p, true);
			end,
		500, 1, client, id);	
	end
);	

addEventHandler ("onClientPlayerRequestHouseManagementPanel", root, 
	function (id)
		if canPlayerOpenManagementMenu (client) then 
			triggerClientEvent (client, "housing.management", client, id);
			triggerLatentClientEvent (client, "housing.managementadmin", client, canPlayerCreateHouse(client));
		end	
	end
);	

function canPlayerOpenManagementMenu (player)
	if isPedInVehicle (player) then 
		outputChatBox ("Bu menüyü kullanmak için araçtan inmeniz gerek.", player, 255, 0, 0);
		return;
	end	
	return true;
end	

function setHouseLocked (id, state)
	setHouseData (id, "locked", tostring (state));
end

function isHouseLocked (id)
	return getHouseData (id, "locked");
end	

function setHouseForSale (id, price)
	if tonumber (price) then 
		if tonumber (price) > 0 then 
			setHouseData (id, "for_sale", "true");
			setHouseData (id, "sale_price", price);
		end	
	else
		setHouseData (id, "for_sale", "false");
		setHouseData (id, "sale_price", getHouseData (id, "bought_price"));
	end	
end

function sellHouse (player, id, price)
	local price = price or (getHouseData (id, "bought_price") * 96) / 100;
	exports.database:givePlayerMoney (player, price, "Sold house #"..id);
	setHouseData (id, "owner", nil);
	setHouseData (id, "for_sale", "true");
	setHouseData (id, "sale_price", getHouseData (id, "bought_price"));
	setHouseData (id, "name", nil);
	triggerClientEvent (player, "onClientPlayerSoldHouse", player, id);
end

function buyHouse (player, id, offer, price)
	local price = price or getHouseData (id, "sale_price");
	if not tonumber (price) then 
		outputChatBox ("Bir hata oluştu", player, 255, 0, 0);
		return;
	end	
	local money = getPlayerMoney (player);
	local for_sale = getHouseData (id, "for_sale");
	local owner = getHouseData (id, "owner");
	if money < price then
		dm ("Bu eve paranız yetmiyor.", player, 255, 0, 0)
		if offer then 
			if isElement (exports.database:getPlayerFromID (owner)) then 
				dm ("Bu oyuncu evi karşılayamıyor.", exports.database:getPlayerFromID (owner));
				local offers_ = getHouseData(id, "offers");
				offers_[exports.database:getPlayerId(player)] = nil;
				setHouseData (id, "offers", toJSON (offers_))
			end
		end	
		return false; 
	end 
	if owners[exports.database:getPlayerId(player)] then 
		if #owners[exports.database:getPlayerId(player)] >= HOUSING_LIMIT then 
			dm ("Maksimum ev sayısına ulaştınız. ("..HOUSING_LIMIT..")", player);
			return 
		end
	end	
	
	exports.database:takePlayerMoney (player, price, "Bought house #"..id);
	setHouseData (id, "owner", nil);
	setHouseData (id, "owner", exports.database:getPlayerId (player));
	setHouseData (id, "bought_date", getRealTime().timestamp);
	setHouseData (id, "bought_price", price);
	setHouseData (id, "for_sale", "false");
	setHouseData (id, "offers", toJSON({}));
	setHouseData (id, "name", exports.mtatr_accounts:getPlayerCurrentCharacter(player));
	if for_sale and owner then 
		if not isElement (exports.database:getPlayerFromID(owner)) then 
			exports.database:addBankMoney (owner, price, "Sold house #"..id.." to "..player:getName().. " Offer: "..tostring(offer));
		else
			exports.database:givePlayerMoney(exports.database:getPlayerFromID(owner), price, "Sold house #"..id.." to "..player:getName() .. " Offer: "..tostring(offer));
		end	
		if isElement (exports.database:getPlayerFromID (owner)) then 
			outputChatBox (player:getName().. " evinizi "..price.."₺ ye satın aldı!", exports.database:getPlayerFromID (owner), 0, 255, 0);
			triggerClientEvent (exports.database:getPlayerFromID (owner), "onClientPlayerSoldHouse", exports.database:getPlayerFromID (owner), id);
		end
	end	
	triggerClientEvent (player, "onClientPlayerBoughtHouse", player, id);
end

function offerPrice (player, id, price)
	local money = getPlayerMoney (player);
	if money < price then dm ("Bu eve paranız yetmiyor.", player, 255, 0, 0) return false; end 
	if owners[exports.database:getPlayerId(player)] then 
		if #owners[exports.database:getPlayerId(player)] >= HOUSING_LIMIT then 
			dm ("Maksimum ev sayısına ulaştınız. ("..HOUSING_LIMIT..")", player);
			return 
		end
	end	
	local data = getHouseData (id, "offers") or {};
	if type (data) == "string" then 
		data = fromJSON(data);
	end	
	data[tostring (exports.database:getPlayerId (player))] = {name = exports.mtatr_accounts:getPlayerCurrentCharacter (player), offer = price};
	dm ("Teklif verildi!", player, 0, 200, 0);
	setHouseData (id, "offers", toJSON (data));
end

function acceptOffer (player_id, id)
	if isElement (exports.database:getPlayerFromID (player_id)) then 
		local offers = getHouseData (id, "offers");
		
		local offer = offers[tostring (player_id)].offer;
		local owner = getHouseData (id, "owner");
		local player = exports.database:getPlayerFromID(owner);
		sellHouse (player, id, offer);
		buyHouse (exports.database:getPlayerFromID (player_id), id, true, offer);
		offers[player_id] = nil;
		setHouseData (id, "offers", toJSON("[[]]"));
	else
		local owner = getHouseData (id, "owner");
		local player = exports.database:getPlayerFromID(owner);
		dm ("Oyuncu çevrimiçi değil.", player);
	end
end

function declineOffer(player_id, id)
	if isElement (exports.database:getPlayerFromID (player_id)) then 
		local player = exports.database:getPlayerFromID (player_id);
		dm ("#"..id.. " numaralı ev için verdiğiniz teklif reddedildi...", player);
	end	
	local offers = getHouseData (id, "offers");
	offers[player_id] = nil;
	setHouseData (id, "offers", toJSON(offers or "[[]]"));
end

function deleteHouse (id)
	local owner = getHouseData (id, "owner");
	if owner then 
		local price = getHouseData (id, "bought_price");
		exports.database:addBankMoney (owner, price, "House #"..id.." deleted");
	end	
	houses[id] = nil;
	dbExec (db, "DELETE FROM fr_housing WHERE id = ?", id);
end
addEvent ("housing.deletehouse", true);
addEventHandler ("housing.deletehouse", root, deleteHouse);

function isHouseSpawnEnabled (player)
	return spawn_in_house[player];
end

function getPlayerSpawnPoint(player)
	if isHouseSpawnEnabled (player) then 
		local house = spawn_in_house[player];
		local location = getHouseData (house, "location");
		local spawnpoint = location.spawn;
		local x, y, z = unpack (spawnpoint);
		local dim, int = location.dim, location.int;
		return x, y, z, tonumber (dim), tonumber (int);
	end
end	

----------------
-- EVENTS
----------------
addEvent ("housing.setspawnin", true);
addEventHandler ("housing.setspawnin", root, 
	function (value)
		if isPlayerOwner (client, value) then  
			spawn_in_house[client] = value;
		end	
	end
);

addEvent ("housing.offer", true);
addEventHandler ("housing.offer", root, 
	function (id, price)
		offerPrice (client, id, price);
	end
);	

addEvent ("housing.buyhouse", true);
addEventHandler ("housing.buyhouse", root, 
	function (id)
		buyHouse (client, id);
	end
);	

addEvent ("housing.setforsale", true);
addEventHandler ("housing.setforsale", root, 
	function (id, price)
		if tonumber (price) and tonumber (price) < 1 then
			outputChatBox ("Sıfırdan büyük bir sayı girmeniz gerek.", player, 200, 0, 0);
			return;
		end	
		setHouseForSale (id, price);
	end
);	

addEvent ("housing.sell", true);
addEventHandler ("housing.sell", root, 
	function (id)
		sellHouse (client, id);
	end
);	

addEvent ("housing.delete", true);
addEventHandler ("housing.delete", root, 
	function (id)
		deleteHouse (id);
	end
);

addEvent ("housing.reactoffer", true);
addEventHandler ("housing.reactoffer", root, 
	function (player_id, id, accept)
		if accept then 
			acceptOffer (player_id, id);		
		else
			declineOffer (player_id, id);
		end	
	end
);	

addEvent ("housing.enter", true);
addEventHandler ("housing.enter", root, 
	function (id)
		if isHouseLocked (id) and not isPlayerOwner (client, id) then 
			outputChatBox ("Bu ev kilitli.", client, 200, 0, 0);
			return;
		end	
		fadeCamera (client, false, .3);
		setTimer (
			function (p, i)
				local location = getHouseData (i, "location");
				if location then 
					local rotation = location.rotation;
					local x, y, z = unpack (rotation.enter);
					local rx, ry, rz = unpack (location.marker);
					local rot = findRotation (rx, ry, x, y);
					local dim, int = getHouseData (i, "location").dim, getHouseData (i, "location").int;
					setElementPosition (p, x, y, z);
					setElementDimension (p, dim);
					setElementInterior (p, int);
					setElementRotation (p, 0, 0, rot);
					fadeCamera(p, true);
				end	
			end,
		500, 1, client, id);	
		triggerClientEvent (client, "housing.management", client);
	end
);	

addEvent ("housing.lock", true);
addEventHandler ("housing.lock", root, 
	function (id)
		if isPlayerOwner (client, id) then 
			setHouseLocked (id, not isHouseLocked(id));
		end
	end
);	