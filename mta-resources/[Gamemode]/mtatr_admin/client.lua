KEY = "M";
local screenW, screenH = guiGetScreenSize();

local maps = {};

ad = {
	window = {},
	tab = {},
	tabpanel = {},
    label = {},
    gridlist = {},
    button = {},
    edit = {},
    combobox = {}
}

jail = {
	{int = 1, text = "1 dakika"},
	{int = 2, text = "2 dakika"},
	{int = 5, text = "5 dakika"},
	{int = 10, text = "10 dakika"},
	{int = 20, text = "20 dakika"},
	{int = 30, text = "30 dakika"},
	{int = 60, text = "1 saat"},
	{int = 120, text = "2 saat"},
	{int = 240, text = "4 saat"},
	{int = 600, text = "10 saat"},
};

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
        ad.window[1] = guiCreateWindow((screenW - 615) / 2, (screenH - 483) / 2, 615, 483, "Gamemode Manager ("..KEY..")", false)
        guiWindowSetSizable(ad.window[1], false)

        ad.tabpanel[1] = guiCreateTabPanel(0.01, 0.05, 0.97, 0.93, true, ad.window[1])

        ad.tab[1] = guiCreateTab("Event Yöneticisi", ad.tabpanel[1])

        ad.gridlist[1] = guiCreateGridList(0.01, 0.02, 0.66, 0.96, true, ad.tab[1])
        guiGridListAddColumn(ad.gridlist[1], "Event", 0.7)
        guiGridListAddColumn(ad.gridlist[1], "Durum", 0.2)
        ad.button[1] = guiCreateButton(0.69, 0.88, 0.14, 0.08, "Başlat", true, ad.tab[1])
        ad.button[2] = guiCreateButton(0.85, 0.88, 0.14, 0.08, "Durdur", true, ad.tab[1])
        ad.button[10] = guiCreateButton(0.69, 0.02, 0.14, 0.08, "Force Start", true, ad.tab[1])
		ad.gridlist[5] = guiCreateGridList(0.69, 0.13, 0.30, 0.73, true, ad.tab[1])   
		guiGridListAddColumn(ad.gridlist[5], "Harita", 0.8);

        ad.tab[2] = guiCreateTab("Oyun Yöneticisi", ad.tabpanel[1])

        ad.gridlist[2] = guiCreateGridList(0.02, 0.02, 0.36, 0.96, true, ad.tab[2])
        guiGridListAddColumn(ad.gridlist[2], "Oyuncu", 0.9)
        ad.button[3] = guiCreateButton(0.63, 0.02, 0.35, 0.05, "Hapset", true, ad.tab[2])
        guiSetProperty(ad.button[3], "NormalTextColour", "FFAAAAAA")
        ad.button[4] = guiCreateButton(0.63, 0.09, 0.35, 0.05, "Deneyim Puanı Ver", true, ad.tab[2])
        guiSetProperty(ad.button[4], "NormalTextColour", "FFAAAAAA")
        ad.button[5] = guiCreateButton(0.63, 0.16, 0.35, 0.05, "Hesabı Dondur", true, ad.tab[2])
        guiSetProperty(ad.button[1], "NormalTextColour", "FFAAAAAA")
        ad.label[1] = guiCreateLabel(0.39, 0.03, 0.23, 0.19, "", true, ad.tab[2])

        ad.tab[3] = guiCreateTab("Karakterler", ad.tabpanel[1])

        ad.edit[1] = guiCreateEdit(0.39, 0.09, 0.27, 0.07, "", true, ad.tab[3])
        ad.label[2] = guiCreateLabel(0.23, 0.02, 0.58, 0.08, "Hesap Adı", true, ad.tab[3])
        guiLabelSetHorizontalAlign(ad.label[2], "center", false)
        ad.gridlist[3] = guiCreateGridList(0.01, 0.19, 0.97, 0.56, true, ad.tab[3])
        guiGridListAddColumn(ad.gridlist[3], "Karakter", 0.1)
        guiGridListAddColumn(ad.gridlist[3], "Para", 0.1)
        guiGridListAddColumn(ad.gridlist[3], "Skor", 0.1)
        guiGridListAddColumn(ad.gridlist[3], "Ölüm", 0.1)
        guiGridListAddColumn(ad.gridlist[3], "Seviye", 0.1)
        guiGridListAddColumn(ad.gridlist[3], "Son Giriş", 0.1)
		
        ad.button[6] = guiCreateButton(0.68, 0.09, 0.09, 0.07, "Ara", true, ad.tab[3])
        ad.combobox[1] = guiCreateComboBox(0.01, 0.75, 0.77, 0.25, "", true, ad.tab[3])
        ad.edit[2] = guiCreateEdit(0.80, 0.75, 0.19, 0.06, "", true, ad.tab[3])
        ad.button[7] = guiCreateButton(0.83, 0.85, 0.14, 0.06, "Değiştir", true, ad.tab[3])

        ad.tab[4] = guiCreateTab("Hesap Hareketleri", ad.tabpanel[1])

        ad.gridlist[4] = guiCreateGridList(0.01, 0.01, 0.77, 0.96, true, ad.tab[4])
        guiGridListAddColumn(ad.gridlist[4], "Hesap", 0.2)
        guiGridListAddColumn(ad.gridlist[4], "IP", 0.2)
        guiGridListAddColumn(ad.gridlist[4], "Serial", 0.2)
        guiGridListAddColumn(ad.gridlist[4], "Kayıt Tarihi", 0.2)
        guiGridListAddColumn(ad.gridlist[4], "Son Görülme", 0.2)
        ad.combobox[2] = guiCreateComboBox(0.79, 0.16, 0.21, 0.29, "", true, ad.tab[4])
        guiComboBoxAddItem(ad.combobox[2], "Hesap")
        guiComboBoxAddItem(ad.combobox[2], "Serial")
        guiComboBoxAddItem(ad.combobox[2], "IP")
        ad.edit[3] = guiCreateEdit(0.79, 0.45, 0.21, 0.06, "", false, ad.tab[4])
        ad.button[8] = guiCreateButton(0.83, 0.53, 0.11, 0.05, "Ara", true, ad.tab[4])
		
		ad.tab[3]:setEnabled(false); --maintenance
		ad.tab[4]:setEnabled(false); --maintenance
		-- ad.button[4]:setEnabled(false); --maintenance
		ad.button[5]:setEnabled(false); --maintenance
		
		ad.window[2] = guiCreateWindow((screenW - 339) / 2, (screenH - 126) / 2, 339, 126, "Süre Belirleyin", false)
        guiWindowSetSizable(ad.window[2], false)

        ad.combobox[3] = guiCreateComboBox(0.03, 0.19, 0.94, 0.56, "", true, ad.window[2])
        guiComboBoxAddItem(ad.combobox[3], "Oto")
		
        ad.button[9] = guiCreateButton(0.34, 0.75, 0.31, 0.17, "Onayla", true, ad.window[2])

		for i, v in pairs (ad.button) do
			addEventHandler ("onClientGUIClick", v, guiConf, false);	
		end
		
		for i, v in pairs (ad.gridlist) do 
			addEventHandler ("onClientGUIClick", v, guiConf, false);
		end	
		
		for i, v in ipairs (jail) do 
			guiComboBoxAddItem(ad.combobox[3], v.text);
		end	
		
		refreshGrid();
		
		guiSetVisible (ad.window[1], false);
		guiSetVisible (ad.window[2], false);
		
		triggerServerEvent("events.sendevents", localPlayer);
    end
)

function showJailTimes(name)
	ad.window[2]:setText (name.. " / Süre Belirleyin");
	guiSetVisible (ad.window[2], true);
	guiBringToFront(ad.window[2]);
end

function refreshGrid ()
	local selected = guiGridListGetSelectedItem (ad.gridlist[2]);
	guiGridListClear (ad.gridlist[2]);
	for i, v in ipairs (getElementsByType"player") do 
		if not isElement (getPlayerTeam (v)) then 
			local r, g, b = v:getNametagColor ();
			local row = guiGridListAddRow (ad.gridlist[2]);
			guiGridListSetItemText (ad.gridlist[2], row, 1, v:getName(), false, false);
			guiGridListSetItemColor (ad.gridlist[2], row, 1, r, g, b);
		end
	end	
	for _, team in ipairs (getElementsByType"team") do 
		local catrow = guiGridListAddRow (ad.gridlist[2]);
		local r, g, b = getTeamColor (team);
		guiGridListSetItemText (ad.gridlist[2], catrow, 1, team:getName(), true, false);
		guiGridListSetItemColor (ad.gridlist[2], catrow, 1, r, g, b);
		for i, v in ipairs (getPlayersInTeam (team)) do 
			local row = guiGridListAddRow (ad.gridlist[2]);
			guiGridListSetItemText (ad.gridlist[2], row, 1, v:getName(), false, false);
			guiGridListSetItemColor (ad.gridlist[2], row, 1, r, g, b);
		end
	end	
	guiGridListSetSelectedItem (ad.gridlist[2], selected, 1);
end
addEvent ("admin.refreshGrid", true);
addEventHandler ("admin.refreshGrid", root, refreshGrid);

function setStats (_type)
	if isElement (ad.window[2]) then ad.window[2]:destroy(); end
	if isElement (ad.window[3]) then return end
	ad.window[3] = guiCreateWindow((screenW - 357) / 2, (screenH - 74) / 2, 357, 74, _type, false)
	guiWindowSetMovable(ad.window[3], false)
	guiWindowSetSizable(ad.window[3], false)
	guiSetProperty(ad.window[3], "AlwaysOnTop", "True")

	ad.edit.ss = guiCreateEdit(0.13, 0.42, 0.49, 0.27, "", true, ad.window[3])
	ad.button.ss_ok = guiCreateButton(0.64, 0.43, 0.12, 0.26, "OK", true, ad.window[3])
	ad.button.ss_cancel = guiCreateButton(0.77, 0.43, 0.20, 0.26, "Close", true, ad.window[3])
	
	for i, v in pairs (ad.button) do
		if isElement (v) then 
			removeEventHandler ("onClientGUIClick", v, guiConf, false);	
			addEventHandler ("onClientGUIClick", v, guiConf, false);
		end	
	end
end	

function guiConf()
	if source == ad.button[1] then 
		local item = guiGridListGetSelectedItem (ad.gridlist[1]);
		-- if item == -1 then return; end
		local text = guiGridListGetItemText (ad.gridlist[1], item, 1);
		local item = guiGridListGetSelectedItem (ad.gridlist[5]);
		-- if item == -1 then return; end
		local map_name = guiGridListGetItemText (ad.gridlist[5], item, 1);
		triggerServerEvent ("admin.startevent", localPlayer, text, map_name);
	elseif source == ad.button[2] then 
		local item = guiGridListGetSelectedItem (ad.gridlist[1]);
		-- if item == -1 then return; end
		local text = guiGridListGetItemText (ad.gridlist[1], item, 1);
		triggerServerEvent ("admin.stopevent", localPlayer, text);
	elseif source == ad.button[3] then 
		local item = guiGridListGetSelectedItem (ad.gridlist[2]);
		if item == -1 then
			outputChatBox ("Önce bir oyuncu seçin.", 255, 0, 0);
			return;
		end
		local text = guiGridListGetItemText (ad.gridlist[2], item, 1);
		local player = Player(text);
		if isElement (player) then 
			if getElementData (player, "jailed") then 
				triggerServerEvent ("admin.jailplayer", localPlayer, player);
				return;
			end
		end	
		showJailTimes(text)
	elseif source == ad.button[4] then 
		setStats("Give Experience")
	elseif source == ad.button.ss_cancel then 
		if isElement (ad.window[3]) then ad.window[3]:destroy(); end
	elseif source == ad.button.ss_ok then 
		local player = Player (guiGridListGetItemText (ad.gridlist[2], guiGridListGetSelectedItem (ad.gridlist[2]), 1))
		if isElement (player) then 	
			local text = ad.edit.ss:getText ();
			local key = ad.window[3]:getText():gsub ("Set ", "");
			key = key:gsub ("Give ", "");
			if #text > 0 then 
				triggerServerEvent ("admin.setstat", localPlayer, player, key, tonumber (text));
			end	
			if isElement (ad.window[3]) then ad.window[3]:destroy(); end
		end		
	elseif source == ad.button[9] then 
		local item = guiComboBoxGetSelected (ad.combobox[3]);
		if item == -1 then return; end
		local time = "Oto";
		if jail[item] then 
			time = jail[item].int*60*1000;
		end	
		local player_name = ad.window[2]:getText():gsub(" / Süre Belirleyin", "");
		local player = Player(player_name);
		if isElement (player) then 
			triggerServerEvent ("admin.jailplayer", localPlayer, player, time);
		end	
		guiSetVisible(ad.window[2], false);
	elseif source == ad.button[10] then 
		local item = guiGridListGetSelectedItem (ad.gridlist[1]);
		if item == -1 then return; end
		local text = guiGridListGetItemText (ad.gridlist[1], item, 1);
		triggerServerEvent("admin.forcestartevent", localPlayer, text);
	elseif source == ad.gridlist[1] then 
		guiGridListClear(ad.gridlist[5]);
		local item = guiGridListGetSelectedItem (ad.gridlist[1]);
		if item == -1 then return; end
		local text = guiGridListGetItemText (ad.gridlist[1], item, 1);
		if maps[text] then 
			for i, v in ipairs (maps[text]) do 
				local row = guiGridListAddRow(ad.gridlist[5]);
				guiGridListSetItemText (ad.gridlist[5], row, 1, v, false, false);
			end
		end	
	elseif source == ad.gridlist[2] then 
		ad.label[1]:setText("");
		local item = guiGridListGetSelectedItem (ad.gridlist[2]);
		if item == -1 then return; end
		local text = guiGridListGetItemText (ad.gridlist[2], item, 1);
		local player = Player(text);
		if isElement (player) then 
			ad.label[1]:setText("Karakter: "..tostring(getElementData(player, "current.char")));
		end	
	end	
end

addEvent ("events.getevents", true);
addEventHandler ("events.getevents", root, 
	function (tbl, active, tbl2)	
		guiGridListClear (ad.gridlist[1]);
		guiGridListClear (ad.gridlist[5]);
		for i, v in ipairs (tbl) do 
			local row = guiGridListAddRow(ad.gridlist[1]);
			local r, g, b = 200, 0, 0;
			local state = "-";
			if v.name == active then 
				r, g, b = 0, 255, 0;
				state = "Aktif"
			end
			guiGridListSetItemText (ad.gridlist[1], row, 1, v.name, false, false);
			guiGridListSetItemText (ad.gridlist[1], row, 2, state, false, false);
			guiGridListSetItemColor (ad.gridlist[1], row, 2, r, g, b);
		end	
		if tbl2 then 
			maps = tbl2;
			
		end	
	end
);	

bindKey (KEY, "down", 
	function ()
		triggerServerEvent ("admin.request", localPlayer);
	end
);

addEvent ("admin.respond", true);
addEventHandler ("admin.respond", root, 
	function (acl)
		if acl == true then --only event manager
			for i=2, #ad.tab do 
				ad.tab[i]:setEnabled(false);
			end
		end	
		guiSetVisible (ad.window[1], not guiGetVisible (ad.window[1]));
		showCursor (guiGetVisible (ad.window[1]));
		guiSetInputMode ("no_binds_when_editing");
	end
);