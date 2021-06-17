addCommandHandler ("finans", 
	function ()
		if localPlayer:getData"loggedin" and localPlayer:getData"current.char" then 
			triggerServerEvent ("onClientRequestMoneyTransferWindow", localPlayer);
		end
		guiSetVisible (fn.window[1], not guiGetVisible (fn.window[1]));
		showCursor (guiGetVisible (fn.window[1]));
	end
);
bindKey (KEY, "down", "finans");

addEvent ("onMoneyTransferWindowResponded", true);
addEventHandler ("onMoneyTransferWindowResponded", root,
	function (limit)
		fn.label[3]:setText ("Kalan limit: "..limit.."₺");
	end
);	

addEventHandler ("onClientGUIBlur", fn.edit[1], 
	function ()	
		local text = guiGetText (source);
		local player = exports.mtatr_utils:findPlayer (text);
		if isElement (player) then 
			if player == localPlayer then return; end
			source:setText (player:getName());	
		end	
	end,
false);	

addEventHandler ("onClientGUIChanged", fn.edit[2], 
	function ()	
		local text = guiGetText (source);
		if #text > 0 then 
			guiSetText (source, text:match("%d+") or "");
		end	
	end,
false);	

addEventHandler ("onClientGUIClick", fn.button[1], 
	function ()
		local player = Player(fn.edit[1]:getText());
		--if player == localPlayer then return; end
		local amount = fn.edit[2]:getText();
		triggerServerEvent ("onClientRequestMoneyTransfer", localPlayer, player, amount);
	end,
false);	