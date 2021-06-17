addEventHandler ("onResourceStart",getResourceRootElement(getThisResource()),
function()
  local allGreenzones = getElementsByType ("radararea")
  for i,v in ipairs (allGreenzones) do
    local r,g,b = getRadarAreaColor (v)
      local x,y = getElementPosition (v)
      local sx,sy = getRadarAreaSize (v)
      local col = createColCuboid (x,y, -50, sx,sy, 7500)
      setElementID (col, "greenzoneColshape")
	  setRadarAreaColor (v, r, g, b, 127)
  end
	local x, y, w, h = 159.52196, -1921.55542, 230, 180;
	createRadarArea (x, y, w, h, 0, 255, 0, 0);
	res_col = createColCuboid (x, y, -50, w, h, 7500)
end)

addEventHandler ("onColShapeHit", getRootElement(), 
function(hitElement, matchingDimension)
  if (isElement(hitElement)) and (getElementID (source) == "greenzoneColshape") and matchingDimension then
	local hitElement = hitElement;
	local vh;
	if (getElementType (hitElement) == "player") and isPedInVehicle( hitElement ) then 
		  vh = getPedOccupiedVehicle( hitElement )
	elseif (getElementType (hitElement) == "vehicle") then 
		vh = hitElement;
	end	
	if isElement (vh) then 
	  setVehicleEngineState( vh, false )
	  blowVehicle( vh, false)
	  setTimer( function(v) if isElement (v) then  destroyElement (v)  end end, 3000, 1, vh )  
	end 
	if isElement (hitElement) then 
		if (getElementType (hitElement) == "player") then 
			toggleControl (hitElement, "fire", false)
			toggleControl (hitElement, "aim_weapon", false)
			toggleControl (hitElement, "vehicle_fire", false)
			setElementData(hitElement, "greenzoned", true )
			triggerClientEvent (hitElement, "enableGodMode", hitElement)
			--outputDebugString (getPlayerName(hitElement) .. " has entered the greenzone")
		end	
	end	
  end
end)

addEventHandler ("onColShapeLeave", getRootElement(), 
function(leaveElement, matchingDimension)
  if (getElementType (leaveElement) == "player") and (getElementID (source) == "greenzoneColshape") then
    toggleControl (leaveElement, "fire", true)
    toggleControl (leaveElement, "aim_weapon", true)
    toggleControl (leaveElement, "vehicle_fire", true)
	setElementData( leaveElement, "greenzoned", false )
    triggerClientEvent (leaveElement, "disableGodMode", leaveElement)
    --outputDebugString (getPlayerName(leaveElement) .. " has left the greenzone")
  end
end)

addEvent ("gz.onload", true);
addEventHandler ("gz.onload", root, 
	function ()
	 for i, v in ipairs (getElementsByType"colshape", resourceRoot) do 
		if getElementID (v) == "greenzoneColshape" then 
			if isElementWithinColShape(client, v) then 
				local hitElement = client;
				if (getElementType (hitElement) == "player") then 
					toggleControl (hitElement, "fire", false)
					toggleControl (hitElement, "aim_weapon", false)
					toggleControl (hitElement, "vehicle_fire", false)
					setElementData(hitElement, "greenzoned", true )
					triggerClientEvent (hitElement, "enableGodMode", hitElement)
					--outputDebugString (getPlayerName(hitElement) .. " has entered the greenzone")
				end	
			end	
		end	
	  end
	end
);	

addEventHandler ("onPlayerSpawn", root, 
	function ()
		for i, v in ipairs (getElementsByType("colshape", resourceRoot)) do 
			if getElementID (v) == "greenzoneColshape" then 
				if isElementWithinColShape(source, v) then 
					toggleControl (source, "fire", false)
					toggleControl (source, "aim_weapon", false)
					toggleControl (source, "vehicle_fire", false)
					setElementData(source, "greenzoned", true )
					triggerClientEvent (source, "enableGodMode", source)
					--outputDebugString (getPlayerName(hitElement) .. " has entered the greenzone")
				end
			end
		end
	end
);

local evaded = {};

addEventHandler ("onPlayerWasted", root,
	function (_, killer)
		if isElement (killer) and getElementType(killer) == "player" then
			if killer == source then return false; end
			if isElementWithinColShape (source, res_col) then
				if exports.mtatr_accounts:isPlayerAdmin(killer) then return; end
				checkEvaded (killer);
			end
		end
	end
);

addEventHandler ("onPlayerQuit", root,
	function ()
		evaded[source] = nil;
	end
);

function checkEvaded (player)
	if not evaded[player] then 
		evaded[player] = 3;
	end
	evaded[player] = evaded[player] - 1;
	outputChatBox ("Spawn kill! Kalan hakkın: "..evaded[player], player);
	if evaded[player] <= 0 then 
		exports.mtatr_admin:jailPlayer(player, true, "Oto");
		-- banPlayer (player, true, false, false, "20 dakika", "Spawn Kill", 20*60);
		-- return;
		return;
	end	
	killPed (player);
end