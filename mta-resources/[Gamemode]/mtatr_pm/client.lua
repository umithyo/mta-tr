pm = {
    edit = {},
    button = {},
    window = {},
    gridlist = {},
    memo = {},
	messages = {
		msg = "", state = "",
	},
	states = {
		unread = {symbol = "•", {217, 157, 43}},
		read = {symbol = "○", {0, 255, 0}},
	}
};
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        pm.window[1] = guiCreateWindow(0.33, 0.33, 0.36, 0.37, "Özel Mesaj (F4)", true)
        guiSetVisible(pm.window[1], false)

        pm.gridlist[1] = guiCreateGridList(0.02, 0.06, 0.40, 0.80, true, pm.window[1])
        guiGridListAddColumn(pm.gridlist[1], "Okundu", 0.15)
		guiGridListAddColumn (pm.gridlist[1], "Oyuncu", .7)
        pm.edit[1] = guiCreateEdit(0.03, 0.88, 0.83, 0.09, "", true, pm.window[1])
        pm.button[1] = guiCreateButton(0.87, 0.88, 0.11, 0.09, "Gönder", true, pm.window[1])
        guiSetProperty(pm.button[1], "NormalTextColour", "FFAAAAAA")
        pm.memo[1] = guiCreateMemo(0.43, 0.06, 0.55, 0.80, "", true, pm.window[1])   
		pm.messages = pm.loadmessages ();		
		for i, v in ipairs (getElementsByType "player") do 
			if v ~= localPlayer then 
				local r, g, b = 255, 255, 255
				local symbol = ""
				if pm.messages[tostring (v:getData ("ID"))] then 
					r, g, b = unpack (pm.states [pm.messages[tostring (v:getData ("ID"))].state][1]);
					symbol = pm.states[pm.messages[tostring(v:getData("ID"))].state].symbol;
				end	
				local row = guiGridListAddRow (pm.gridlist[1]);
				guiGridListSetItemText (pm.gridlist[1], row, 1, symbol, false, false);
				guiGridListSetItemText (pm.gridlist[1], row, 2, v:getName(), false, false);
				guiGridListSetItemColor (pm.gridlist[1], row, 1, r, g, b);
			end	
		end	
		local count = 0;
		for i, v in pairs (pm.messages) do 
			if v.state then 
				if v.state == "unread" then 
					if getPlayerFromID (tonumber (i)) then 
						count = count + 1;
					end	
				end
			end
		end
		if count > 0 then 
			outputChatBox (count.." okunmamış mesajınız var. F4'e basarak kontrol edebilirsiniz.", 255, 127, 0);
		end	
		addEventHandler ("onClientGUIAccepted", pm.edit[1],
			function ()
				local b = pm.button[1];
				local g = pm.gridlist[1];
				local e = pm.edit[1];
				
				local item = guiGridListGetSelectedItem (g);
				if #e:getText () ~= 0 and #e:getText():gsub(" ", "") ~= 0 then 
					if item == -1 then outputChatBox ("Mesaj gönderilemedi.", 255, 0, 0); return end
					local text, target = e:getText(), Player (guiGridListGetItemText(g, item, 2));
					
					if isElement (target) then 
						triggerServerEvent ("onPlayerPersonalMessageSend", localPlayer, text, target);
					end
				end
			end
		);
    end 
);
function getPlayerFromID (id)
	for k, player in ipairs (getElementsByType"player") do 
		if player:getData ("ID") == id then 
			return player;
		end
	end
	return false;
end	
bindKey ("F4", "down", 
	function ()
		guiSetInputMode ("no_binds_when_editing");
		local selected = guiGridListGetSelectedItem (pm.gridlist[1]);
		local text = guiGridListGetItemText (pm.gridlist[1], selected, 2);
		guiSetVisible (pm.window[1], not guiGetVisible (pm.window[1]));
		showCursor (guiGetVisible (pm.window[1]));
		if guiGetVisible (pm.window[1]) then 
			guiGridListClear (pm.gridlist[1]);
			for i, v in ipairs (getElementsByType "player") do 
				if v ~= localPlayer then 
					local r, g, b = 255, 255, 255
					local symbol = ""
					if pm.messages[tostring (v:getData ("ID"))] then 
						r, g, b = unpack (pm.states [pm.messages[tostring (v:getData ("ID"))].state][1]);
						symbol = pm.states[pm.messages[tostring(v:getData("ID"))].state].symbol;
					end	
					local row = guiGridListAddRow (pm.gridlist[1]);
					guiGridListSetItemText (pm.gridlist[1], row, 1, symbol, false, false);
					guiGridListSetItemText (pm.gridlist[1], row, 2, v:getName(), false, false);
					guiGridListSetItemColor (pm.gridlist[1], row, 1, r, g, b);
				end	
			end	
			guiEditSetCaretIndex (pm.edit[1], 1);
		end
		for i = 0, guiGridListGetRowCount (pm.gridlist[1]) do 
			if guiGridListGetItemText (pm.gridlist[1], i, 2) == text then 
				guiGridListSetSelectedItem (pm.gridlist[1], i, 2);
			end	
		end	
		if not selected then 
			pm.memo[1]:setText("");
		end	
	end
);	

function pm.sendPm ()
	local e = pm.edit[1];
	local g = pm.gridlist[1];
	local item = guiGridListGetSelectedItem (g);
	if #e:getText () ~= 0 and #e:getText():gsub(" ", "") ~= 0 then 
		if item == -1 then outputChatBox ("Message could not be sent.", 255, 0, 0); return end
		local text, target = e:getText(), Player (guiGridListGetItemText(g, item, 2));
		if isElement (target) then 
			refreshFile (text, localPlayer, target);
			e:setText ("");
			guiSetText (pm.memo[1], "");
			if pm.messages [tostring (target:getData ("ID"))] then 
				local message = pm.messages [tostring (target:getData ("ID"))].msg or "";
				guiSetText (pm.memo[1], message);
				pm.messages [tostring (target:getData ("ID"))].state = "read";
				guiMemoSetCaretIndex (pm.memo[1], math.max (guiMemoGetCaretIndex(pm.memo[1]), #message))
				saveChangesOnFile();
			end
		end	
		pm.refreshgrid();
	end	
end
addEvent ("onClientPlayerSendPersonalMessage", true);
addEventHandler ("onClientPlayerSendPersonalMessage", root, pm.sendPm);

function refreshFile (msg, sender, player)
	if not pm.messages[tostring (player:getData("ID"))] then 
		pm.messages[tostring (player:getData("ID"))] = {msg = sender:getName()..": " ..msg, state = "unread"};
	else
		pm.messages[tostring (player:getData("ID"))].msg = pm.messages[tostring (player:getData("ID"))].msg.."\n"..sender:getName()..": "..msg;
		pm.messages[tostring (player:getData("ID"))].state = "unread";
	end	
	local file, messages;
	if not fileExists ("messages.txt") then 
		file = fileCreate ("messages.txt");
	else
		file = fileOpen ("messages.txt");
	end		
	fileWrite (file, toJSON (pm.messages))	
	fileClose (file);
end

function saveChangesOnFile ()
	local file, messages;
	if not fileExists ("messages.txt") then 
		file = fileCreate ("messages.txt");
	else
		file = fileOpen ("messages.txt");
	end		
	fileWrite (file, toJSON (pm.messages))	
	fileClose (file);
end

addEventHandler ("onClientGUIClick", root, 
	function ()
		local b = pm.button[1];
		local g = pm.gridlist[1];
		local e = pm.edit[1];
		if source == e then 
			guiSetInputMode ("no_binds_when_editing");
		elseif source == b then 
			local b = pm.button[1];
			local g = pm.gridlist[1];
			local e = pm.edit[1];
			
			local item = guiGridListGetSelectedItem (g);
			if #e:getText () ~= 0 and #e:getText():gsub(" ", "") ~= 0 then 
				if item == -1 then outputChatBox ("Mesaj gönderilemedi.", 255, 0, 0); return end
				local text, target = e:getText(), Player (guiGridListGetItemText(g, item, 2));
				
				if isElement (target) then 
					triggerServerEvent ("onPlayerPersonalMessageSend", localPlayer, text, target);
				end
			end
		elseif source == g then 
			guiSetText (pm.memo[1], "");
			local item = guiGridListGetSelectedItem (g);
			if item == -1 then return end
			local player = isElement (Player (guiGridListGetItemText(g, item, 2))) and Player (guiGridListGetItemText(g, item, 2));
			if player then 
				if pm.messages [tostring (player:getData ("ID"))] then 
					local message = pm.messages [tostring (player:getData ("ID"))].msg or "";
					guiSetText (pm.memo[1], message);
					pm.messages [tostring (player:getData ("ID"))].state = "read";
					guiGridListSetItemColor (pm.gridlist[1], item, 1, unpack(pm.states.read[1]));	
					guiMemoSetCaretIndex (pm.memo[1], math.max (guiMemoGetCaretIndex(pm.memo[1]), #message))
					local file, messages;
					if not fileExists ("messages.txt") then 
						file = fileCreate ("messages.txt");
					else
						file = fileOpen ("messages.txt");
					end	
					fileWrite (file, toJSON (pm.messages))	
					fileClose (file);
				end
			end	
		end
	end
);	

addEvent ("onClientPlayerReceivePersonalMessage", true);
addEventHandler ("onClientPlayerReceivePersonalMessage", root, 
	function (player, msg)
		if not guiGetVisible (pm.window[1]) then 
			exports.mtatr_hud:dm (player:getName().." size bir mesaj gönderdi. F4'e basarak kontrol edebilirsiniz!");
		end	
		refreshFile (msg, player, player);
		local g = pm.gridlist[1];
		local item = guiGridListGetSelectedItem (g);
		if item ~= -1 then
			local plr = isElement (Player (guiGridListGetItemText(g, item, 2))) and Player (guiGridListGetItemText(g, item, 2));
			if plr == player then 
				if pm.messages [tostring (player:getData ("ID"))] then 
					guiSetText (pm.memo[1], "");
					local message = pm.messages [tostring (player:getData ("ID"))].msg or "";
					guiSetText (pm.memo[1], message);
					pm.messages [tostring (player:getData ("ID"))].state = "read";
					guiMemoSetCaretIndex (pm.memo[1], math.max (guiMemoGetCaretIndex(pm.memo[1]), #message));
					saveChangesOnFile();
				end	
			end	
		end	
		pm.refreshgrid();
		setTimer(setWindowFlashing, 1000, 2, true, 3);
		createTrayNotification(player:getName().." adlı oyuncu size mesaj gönderdi.", "info", true);
	end
);	

function pm.refreshgrid ()
	for i=0, guiGridListGetRowCount (pm.gridlist[1]) do 
		local player = Player (guiGridListGetItemText (pm.gridlist[1], i, 2)); 
		if isElement (player) then 
			local r, g, b = 255, 255, 255
			local symbol = "";
			if pm.messages[tostring (player:getData ("ID"))] then 
				r, g, b = unpack (pm.states [pm.messages[tostring (player:getData ("ID"))].state][1]);
				symbol = pm.states[pm.messages[tostring(player:getData("ID"))].state].symbol;
			end	
			guiGridListSetItemText (pm.gridlist[1], i, 1, symbol, false, false)
			guiGridListSetItemColor (pm.gridlist[1], i, 1, r, g, b);
		end	
	end	
end

function pm.loadmessages() 
	local file, messages; 
	if fileExists ("messages.txt") then 
		file = fileOpen ("messages.txt");
	end	
	if file then 
		messages = fromJSON (fileRead (file, fileGetSize (file)) or "[[]]");
		fileClose (file);
	end	
	return messages or {};
end