addEventHandler ("onClientResourceStart", resourceRoot, 
	function ()
		triggerServerEvent ("housing.sync", localPlayer);
	end
);	

houses = {};
pickups = {};
markers = {};
blips = {};

addEvent ("housing.sync", true);
addEventHandler ("housing.sync", root, 
	function (data)
		if localPlayer:getData("loggedin") then 
			houses = data;
			syncHouses ();
			addEventHandler ("onClientRender", root, drawHousesInfo);
		end	
	end
);

function setHouseData (id, key, data)
	if houses[id] then 
		houses[id][key] = data;
		refreshHouse (id);
		if key == "offers" then 
			if mn and mn.gridlist then 
				if isElement (mn.gridlist[1]) then 
					loadOffers ();
				end
			end	
		end	
		setManagementGui(getHouseFromLabel());
	end	
end
addEvent ("housingsync.setdata", true);
addEventHandler ("housingsync.setdata", root, setHouseData);

function getHouseData (id, key)
	if not id or not key then return false; end
	local data = houses[id][key];
	if data == "true" then 
		data = true;
	elseif data == "false" then 
		data = false;
	end	
	return tonumber (data) or data;
end

function getHouseId (house)
	return pickups[house] or markers[house];
end	

function syncHouses ()
	for i, v in pairs (houses) do 
		local id = i;
		local pickup_id = 1272;
		if v.for_sale == "true" then 
			pickup_id = 1273;
		end
		local location = v.location;
		local px, py, pz = unpack (location.pickup);
		local pickup = createPickup (px, py, pz, 3, pickup_id);
		local mx, my, mz = unpack (location.marker);
		local marker = createMarker (mx, my, mz, "arrow", 2.0, 15, 247, 135);
		marker:setDimension (location.dim);
		marker:setInterior (location.int);
		houses[id].pickup = pickup;
		houses[id].marker = marker;
		pickups[pickup] = id;	
		markers[marker] = id;
		if getHouseData (id, "owner") == localPlayer:getData ("ID") then 
			blips[id] = createBlip (px, py, pz, 31);
		end	
	end
end	

function syncHouse (id, data)
	houses[id] = data;
	local pickup_id = 1272;
	if data.for_sale == "true" then 
		pickup_id = 1273;
	end	
	local location = data.location;
	local px, py, pz = unpack (location.pickup);
	local pickup = createPickup (px, py, pz, 3, pickup_id);
	local mx, my, mz = unpack (location.marker);
	local marker = createMarker (mx, my, mz, "arrow", 2.0, 15, 247, 135);
	marker:setDimension (location.dim);
	marker:setInterior (location.int);
	houses[id].pickup = pickup;
	houses[id].marker = marker;
	pickups[pickup] = id;	
	markers[marker] = id;
end
addEvent ("housingsync.addhouse", true);
addEventHandler ("housingsync.addhouse", root, syncHouse);

function refreshHouse (id)
	local data = houses[id];
	local pickup_id = 1272;
	if data.for_sale == "true" then 
		pickup_id = 1273;
	end	
	if houses[id].pickup then 
		setPickupType (houses[id].pickup, 3, pickup_id);
	end	
end

function deleteHouse (id)
	if isElement (houses[id].pickup) then 
		pickups[houses[id].pickup] = nil;
		houses[id].pickup:destroy();
	end	
	if isElement (houses[id].marker) then 
		markers[houses[id].marker] = nil;
		houses[id].marker:destroy();
	end
	houses[id] = nil;
	triggerServerEvent ("housing.deletehouse", localPlayer, id);
	closeManagementMenu();
end	

local LABEL_OFFSET = 0.50
function drawHousesInfo()
	for pickup, id in pairs (pickups) do
		local px, py, pz = getCameraMatrix()
		--local name = getElementData(pickup, "address")
		local name = getHouseData (id, "name");
		if ( not name ) then name = "Satılık" end 
		local value = getHouseData (id, "sale_price");
		if localPlayer:getDimension() ~= 0 or localPlayer:getInterior() ~= 0 then return end	
		if (name and value) then			
			local tx, ty, tz = getElementPosition(pickup)
			tz = tz + LABEL_OFFSET
			local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
			if (dist < 15) then
				if (isLineOfSightClear(px, py, pz, tx, ty, tz, true, true, false, true, true, false, false)) then
					local x,y = getScreenFromWorldPosition(tx, ty, tz)
					if (x) then
						-- local tick = getTickCount()/360
						-- local hover = math.sin(tick) * 10
						local hover = 0;
						local text = name.."\n₺"..tocomma(value)
						dxDrawText(text, x+1, y+1+hover, x+1, y+1+hover, tocolor(0,0,0), 1, "default-bold", "center", "center")
						dxDrawText(text, x+1, y-1+hover, x+1, y-1+hover, tocolor(0,0,0), 1, "default-bold", "center", "center")
						dxDrawText(text, x-1, y+1+hover, x-1, y+1+hover, tocolor(0,0,0), 1, "default-bold", "center", "center")
						dxDrawText(text, x-1, y-1+hover, x-1, y-1+hover, tocolor(0,0,0), 1, "default-bold", "center", "center")
						dxDrawText(text, x, y+hover, x, y+hover, tocolor(255,255,255), 1, "default-bold", "center", "center")
					end
				end
			end
		end
	end
end

addEvent ("onClientPlayerBoughtHouse", true);
addEventHandler ("onClientPlayerBoughtHouse", root, 
	function (id)
		local pickup = getHouseData (id, "pickup");
		local px, py, pz = getElementPosition (pickup);
		if getHouseData (id, "owner") == localPlayer:getData ("ID") then 
			blips[id] = createBlip (px, py, pz, 31);
		end	
	end
);	

addEvent ("onClientPlayerSoldHouse", true);
addEventHandler ("onClientPlayerSoldHouse", root, 
	function (id)
		if isElement (blips[id]) then 
			blips[id]:destroy();
			if spawnInHouse == id then 
				spawnInHouse = nil;
				triggerServerEvent ("housing.setspawnin", localPlayer, spawnInHouse);
			end
			if isElement (mn.window[2]) then 
				mn.window[2]:destroy();
				return
			end		
		end
	end
);	
		