KEY = "f2";
hm = {
    button = {},
    window = {},
    memo = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		outputChatBox ("Yardım için "..KEY:upper().." tuşuna basınız.", 255, 255, 0);
		local screenW, screenH = guiGetScreenSize()
        hm.window[1] = guiCreateWindow((screenW - 554) / 2, (screenH - 377) / 2, 554, 377, "Yardım ("..KEY:upper()..")", false)
        guiWindowSetSizable(hm.window[1], false)
		guiSetVisible (hm.window[1], false);
		
		local texts = {};
		
		for i, v in ipairs (xmlNodeGetChildren (getResourceConfig ("help.xml"))) do
			local key = xmlNodeGetName (v);
			local text = xmlNodeGetValue (v);
			texts[key] = text or "";
		end	

        hm.button.cmds = guiCreateButton(0.02, 0.07, 0.13, 0.07, "Komutlar", true, hm.window[1])
        hm.button.hotkeys = guiCreateButton(0.17, 0.07, 0.13, 0.07, "Kısayollar", true, hm.window[1])
        hm.button.gameplay = guiCreateButton(0.31, 0.07, 0.13, 0.07, "Oyun", true, hm.window[1])
        hm.button.deathmatch = guiCreateButton(0.47, 0.07, 0.15, 0.07, "Deathmatch", true, hm.window[1])
        hm.button.contact = guiCreateButton(0.63, 0.07, 0.18, 0.07, "İletişim Kanalları", true, hm.window[1])
        hm.button.about = guiCreateButton(0.83, 0.07, 0.13, 0.07, "Hakkında", true, hm.window[1])
		
		local font = guiCreateFont ("RobotoSlab-Bold.ttf");
		
        hm.memo[1] = guiCreateMemo(0.02, 0.15, 0.96, 0.82, "", true, hm.window[1])		
		guiMemoSetReadOnly (hm.memo[1], true)
		guiSetFont (hm.memo[1], font);

		for i, v in pairs (hm.button) do 
			addEventHandler ("onClientGUIClick", v, 
				function ()
					guiSetText (hm.memo[1], texts[i] or "");
				end,
			false);
		end	
		
		guiSetText (hm.memo[1], texts.cmds);
    end
)

bindKey (KEY, "down", 
	function ()
		guiSetVisible (hm.window[1], not guiGetVisible(hm.window[1]));
		showCursor(guiGetVisible(hm.window[1]));
	end
);	

addEvent ("onSpawnResponded", true);
addEventHandler ("onSpawnResponded", root, 
	function ()
		guiSetVisible (hm.window[1], not guiGetVisible(hm.window[1]));
		showCursor(guiGetVisible(hm.window[1]));
	end
);	