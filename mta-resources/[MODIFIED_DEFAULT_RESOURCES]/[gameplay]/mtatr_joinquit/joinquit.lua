addEvent ("onPlayerCharacterLogin");
addEventHandler("onPlayerCharacterLogin", root,
	function(char)
		outputChatBox(char .. ' oyuna başladı.', root, 208, 116, 116);
	end,
true, "low");

addEventHandler('onPlayerChangeNick', root,
	function(oldNick, newNick)
		cancelEvent();
	end
)

addEventHandler('onPlayerQuit', root,
	function(reason)
		if getElementData (source, "current.char") then
			outputChatBox(getPlayerName(source) .. ' oyundan çıktı. (' .. reason .. ')', root, 208, 116, 116);
		end
	end
)
