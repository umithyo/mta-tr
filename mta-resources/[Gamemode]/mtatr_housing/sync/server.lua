addEvent ("housing.sync", true);
addEventHandler ("housing.sync", root, 
	function ()
		syncHouses (client);
	end
);

addEvent ("onPlayerCharacterLogin");
function syncHouses (player)
	local player = isElement (player) and player or source;
	local data = getHouses();
	local count = 0;
	for i, v in pairs (data) do 
		count = count + 1;
		if v.owner then 
			v.name = exports.database:getAccountLastPlayedCharacter (v.owner);
		end	
	end
	
	if count > 0 then 	
		triggerClientEvent (player, "housing.sync", player, data);
	end	
	
	triggerClientEvent (player, "housing.spawn_enabled", player);
end	
addEventHandler ("onPlayerCharacterLogin", root, syncHouses);

function syncHousingData (player, id, key, data)
	triggerClientEvent (player, "housingsync.setdata", player, id, key, data);
end