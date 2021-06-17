addEvent ("menu.onSendMessage", true);
addEventHandler ("menu.onSendMessage", root,
	function (key, message)
		local team = getPlayerTeam (client);
		if team and isElement (team) then
			if key and tonumber (key) then
				local dot = ".";
				if message == "Go!" then
					dot = "";
				end
				for i, v in ipairs (getPlayersInTeam(team)) do
					outputChatBox ("[RADIO]"..client:getName()..": "..message.. dot, v);
					triggerClientEvent (v, "menu.onSendMessage", v, key, message);
				end
			end
		end
	end
);
