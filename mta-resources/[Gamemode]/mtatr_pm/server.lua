pm = {};

addEventHandler ("onPlayerCommand", root, 
	function (cmd)
		if cmd == "msg" then 
			cancelEvent ();
			outputChatBox ("/pm [isim] komutunu kullanın!", source, 255, 0, 0);
		end
	end
);

function pm.sendPm (msg, player, target)
	local target = target;
	if exports.mtatr_chat:isAdvertising(msg) then 
		outputChatBox ("Reklam algılandı. Yöneticiye bildiriliyor...", player, 255, 0, 0);
		outputDebugString ("roaboar, "..player:getName().." tried to advertise '"..msg.."'", 2)
		return; 
	end	
	if exports.mtatr_utils:findPlayer (target) then 
		target = exports.mtatr_utils:findPlayer (target);
	else
		target = nil;
	end
	if target and isElement (target) then 
		if target ~= player then 
			outputChatBox ("[PM] #FACC2E".. player:getName().. ": #ffffff"..msg, target, 255, 217, 43, true);
			outputChatBox ("[PM to] #FACC2E"..target:getName().. ": #ffffff"..msg, player, 255, 217, 43, true);
		end	
	else
		outputChatBox ("Oyuncu bulunamadı!", player, 255, 0, 0);
	end	
end	

addCommandHandler ("pm",
	function (player, cmd, target, ...)
		if isPlayerMuted (player) then 
			outputChatBox ("PM: You are muted", player, 255, 168, 0);
			return false;
		end	
		pm.sendPm (table.concat({...}, " "), player, target);
	end
);	

addEvent ("onPlayerPersonalMessageSend", true);
addEventHandler ("onPlayerPersonalMessageSend", root, 
	function (msg, player)
		if exports.mtatr_chat:isAdvertising(msg) then 
			outputChatBox ("Reklam algılandı. Yöneticiye bildiriliyor...", client, 255, 0, 0);
			outputDebugString ("roaboar, "..client:getName().." tried to advertise '"..msg.."'", 2)
			return; 
		end	
		if isPlayerMuted (client) then 
			outputChatBox ("PM: You are muted", client, 255, 168, 0);
			return false;
		end	
		if msg and msg ~= "" and isElement (player) then 
			triggerClientEvent (player, "onClientPlayerReceivePersonalMessage", player, client, msg);
			triggerClientEvent (client, "onClientPlayerSendPersonalMessage", client);	
		end
	end
);	