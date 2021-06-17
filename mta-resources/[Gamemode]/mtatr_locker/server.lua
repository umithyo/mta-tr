local locked = {};
local players = {};

addEventHandler ("onPlayerVehicleEnter", root, 
	function (veh)
		locked[veh] = source;
		players[source] = veh;
	end
);	

function canPlayerLockVehicle(player, veh)
	if not locked[veh] then 
		return false;
	end	
	if not isElement (veh) then 
		return false;
	end
	if isVehicleBlown (veh) then 
		return false;
	end	
	if locked[veh] ~= player then 
		return false;
	end
	if exports.mtatr_blackexport:isBlackExportVehicle(veh) then 
		return false;
	end 	
	return true;
end

function toggle (veh)
	setVehicleLocked (veh, not isVehicleLocked(veh));
	return isVehicleLocked (veh) and "Aracınız kilitlendi." or "Kilit açıldı.";
end

addCommandHandler ("lock", 
	function (player)
		local veh = players[player];
		if canPlayerLockVehicle (player, veh) then 
			local msg = toggle (veh);
			outputChatBox (msg, player);
		end
	end
);

addEventHandler ("onPlayerJoin", root, 
	function ()	
		bindKey (source, "l", "down", "lock");
	end
);	

for i, v in ipairs  (getElementsByType"player") do 
	bindKey (v, "l", "down", "lock");
end	

addEventHandler ("onVehicleExplode", root, 
	function ()
		locked[source] = nil;
	end
);	

addEventHandler ("onPlayerQuit", root,
	function ()
		players[source] = nil;
	end
);	