addEvent("core:onClientRequestGlobal3DSound", true);
addEvent("core:onClientRequestGlobal3DSound_owner", true);

function createShared3DSound (x, y, z, path, owner, looped, distance, dim, int)
	for _, player in pairs ( getElementsByType("player") ) do
		-- if (exports.database:isPlayerLoggedIn(player) ) then
			triggerClientEvent(player, "core:onServerRequest3DSound", (owner or player), x, y, z, path, owner, looped, distance, dim, int);
		-- end
	end
end
addEventHandler("core:onClientRequestGlobal3DSound", root, createShared3DSound);

function create3DOwnerSound (path, owner, looped, distance, dim, int)
	--if (sLoggedIn(player) ) then
		local x, y, z = getElementPosition(owner);
		createShared3DSound(x, y, z, path, owner, looped, distance, dim, int);
		--x, y, z, path, looped, owner, dim, int
	--end
end
addEventHandler("core:onClientRequestGlobal3DSound_owner", root, create3DOwnerSound);

addCommandHandler ("radio", 
	function (player, cmd, url)
		if not url then 
			outputChatBox ("Kullanım: /"..cmd.." [url]", player, 255, 255, 0);
			return;
		end
		if not isPedInVehicle (player) then 
			outputChatBox ("Bu komutu kullanmak için bir aracın içinde olmanız gerekiyor.", player, 255, 0, 0);
			return;
		end
		local vehicle = getPedOccupiedVehicle (player);
		if not isElement (vehicle) then return; end
		create3DOwnerSound (url, vehicle, false, 75, getElementDimension(vehicle), getElementInterior(vehicle));
	end
);	

-- function bindRamaLaughToPlayer (player)
	-- bindKey(player, "l", "down",
		-- function()
			-- local path = find3DSound ("ramaLaugh");
			-- create3DOwnerSound(path, player, false, 50, getElementDimension(player), getElementInterior(player) );		
		-- end
	-- );
-- end

-- for _, p in pairs (getElementsByType("player") ) do
	-- if (exports.database:isPlayerLoggedIn(p) ) then
		-- bindRamaLaughToPlayer (p);
	-- end
-- end

-- addEvent ("onPlayerCoreLogin");
-- addEventHandler("onPlayerCoreLogin", root,
	-- function()
		-- bindRamaLaughToPlayer (source);
		-- bindSwagniLaughToPlayer(source);
	-- end
-- );

-- function bindSwagniLaughToPlayer (player)
	-- bindKey(player, "k", "down",
		-- function()
			-- local path = find3DSound ("swagniTaunt");
			-- create3DOwnerSound(path, player, false, 50, getElementDimension(player), getElementInterior(player) );
		-- end
	-- );
-- end
-- for _, pl in pairs (getElementsByType("player")) do
	-- if (exports.database:isPlayerLoggedIn(pl) ) then
		-- bindSwagniLaughToPlayer(pl)
	-- end	
-- end