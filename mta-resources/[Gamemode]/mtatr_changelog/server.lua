function getUpdates ()
	local updates = {};
	if fileExists (":"..getResourceName(getThisResource()).."/changelog.txt") then 
		local file = fileOpen (":"..getResourceName(getThisResource()).."/changelog.txt");
		if file then
			updates = fileRead (file, fileGetSize (file));
		end	
		fileClose (file)
		updates = fromJSON ("["..updates.."]");
	end
	return updates;
end	

addEvent ("updates:getUpdates", true);
addEventHandler ("updates:getUpdates", root, 
	function ()
		if exports.mtatr_accounts:isPlayerInGame(client) then 
			triggerLatentClientEvent (client, "updates:getUpdates", client, getUpdates());
		end	
	end
);	

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root, 
	function ()
		triggerLatentClientEvent (source, "updates:getUpdates", source, getUpdates());
	end
);	

function addUpdate()
	triggerLatentClientEvent (resourceRoot, "updates:getUpdates", root, getUpdates());
end