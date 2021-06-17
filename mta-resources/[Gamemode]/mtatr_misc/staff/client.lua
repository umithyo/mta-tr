addEvent ("staff.gm", true);
addEventHandler ("staff.gm", root, 
	function (enabled)
		if enabled == true then 
			addEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
		else
			removeEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
		end	
	end
);	

addEventHandler ("onClientResourceStart", resourceRoot,
	function ()
		triggerServerEvent ("staff.load", localPlayer);
	end
);	

addEvent ("aimmodes.grav", true);
addEventHandler ("aimmodes.grav", root, 
	function (target)
		local x, y, z = getPedTargetEnd (localPlayer);
		triggerServerEvent ("aimmodes.grav", localPlayer, target, x, y, z);
	end
);	