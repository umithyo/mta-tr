addEventHandler ("onPlayerLogin",root,
	function (account)
		if exports.mtatr_accounts:isPlayerInStaff (source) then 
			bindKey (source , "x", "down", bindDonkey);	
		end	
	end	
);

function bindDonkey (player)
	if exports.mtatr_accounts:isPlayerInStaff (player) then 
		triggerClientEvent (player, "donkey.showcursor", player);
	end		
end

addEventHandler ("onPlayerLogout", root, 
	function ()
		unbindKey (source, "x", "down", bindDonkey);
	end
);	

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		for i, v in ipairs (getElementsByType"player") do 
			if exports.mtatr_accounts:isPlayerInStaff (v) then 
				bindKey (v , "x", "down", bindDonkey);	
			end	
		end
	end
);	