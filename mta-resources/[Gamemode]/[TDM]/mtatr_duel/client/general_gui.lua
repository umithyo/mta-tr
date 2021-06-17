addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
        duel.window[1] = guiCreateWindow(10, (screenH - 682) / 2, 345, 682, "MTA-TR.com Duel", false)

        duel.gridlist[1] = guiCreateGridList(0.03, 0.09, 0.94, 0.23, true, duel.window[1])
        guiGridListAddColumn(duel.gridlist[1], "ID", 0.1)
        guiGridListAddColumn(duel.gridlist[1], "Tür", 0.2)
        guiGridListAddColumn(duel.gridlist[1], "Oyuncular", 0.2)
        guiGridListAddColumn(duel.gridlist[1], "Başlatan", 0.2)
		guiGridListAddColumn(duel.gridlist[1], "Bahis", .2)
        duel.gridlist[2] = guiCreateGridList(0.03, 0.33, 0.94, 0.22, true, duel.window[1])
        guiGridListAddColumn(duel.gridlist[2], "Odadaki Oyuncular", 0.9)
        duel.button[1] = guiCreateButton(0.03, 0.55, 0.46, 0.04, "Odaya Gir (Takım 1)", true, duel.window[1])
        guiSetFont(duel.button[1], "default-small")
        guiSetProperty(duel.button[1], "NormalTextColour", "FFAAAAAA")
        duel.button[2] = guiCreateButton(0.51, 0.55, 0.46, 0.04, "Odaya Gir (Takım 2)", true, duel.window[1])
        guiSetFont(duel.button[2], "default-small")
        guiSetProperty(duel.button[2], "NormalTextColour", "FFAAAAAA")
        duel.tabpanel[1] = guiCreateTabPanel(0.03, 0.60, 0.94, 0.38, true, duel.window[1])

        duel.tab[1] = guiCreateTab("PVP", duel.tabpanel[1])

        duel.combobox[1] = guiCreateComboBox(0.02, 0.03, 0.95, 0.37, "", true, duel.tab[1])
        duel.combobox[2] = guiCreateComboBox(0.02, 0.15, 0.95, 0.37, "", true, duel.tab[1])
        duel.edit[1] = guiCreateEdit(0.02, 0.29, 0.94, 0.11, "Bahis", true, duel.tab[1])
        duel.button[3] = guiCreateButton(0.21, 0.86, 0.57, 0.09, "Oda Oluştur", true, duel.tab[1])
        guiSetProperty(duel.button[3], "NormalTextColour", "FFAAAAAA")

        duel.tab[2] = guiCreateTab("TDM", duel.tabpanel[1])

        duel.combobox[3] = guiCreateComboBox(0.02, 0.04, 0.94, 0.43, "", true, duel.tab[2])
        duel.combobox[4] = guiCreateComboBox(0.02, 0.16, 0.66, 0.43, "", true, duel.tab[2])
        duel.edit[4] = guiCreateEdit(0.71, 0.16, 0.26, 0.10, "", true, duel.tab[2])
        duel.combobox[5] = guiCreateComboBox(0.02, 0.28, 0.66, 0.43, "", true, duel.tab[2])
        duel.combobox[6] = guiCreateComboBox(0.02, 0.40, 0.66, 0.43, "", true, duel.tab[2])
        duel.edit[5] = guiCreateEdit(0.71, 0.28, 0.26, 0.10, "", true, duel.tab[2])
        duel.edit[6] = guiCreateEdit(0.71, 0.40, 0.26, 0.10, "", true, duel.tab[2])
        duel.edit[7] = guiCreateEdit(0.02, 0.59, 0.65, 0.10, "Maks. Oyuncu", true, duel.tab[2])
        duel.edit[8] = guiCreateEdit(0.71, 0.59, 0.26, 0.10, "", true, duel.tab[2])
        duel.edit[9] = guiCreateEdit(0.02, 0.73, 0.65, 0.10, "Bahis", true, duel.tab[2])
        duel.button[4] = guiCreateButton(0.21, 0.88, 0.57, 0.09, "Oda Oluştur", true, duel.tab[2])
        guiSetProperty(duel.button[4], "NormalTextColour", "FFAAAAAA")


        duel.window[2] = guiCreateWindow(0.25, 0.12, 0.24, 0.30, "", true)
        guiWindowSetSizable(duel.window[2], false)

        duel.gridlist[3] = guiCreateGridList(0.03, 0.08, 0.94, 0.62, true, duel.window[2])
        guiGridListAddColumn(duel.gridlist[3], "Odadaki Oyuncular", 0.9)
        duel.button[5] = guiCreateButton(0.03, 0.72, 0.38, 0.10, "Maçı Başlat", true, duel.window[2])
        guiSetProperty(duel.button[5], "NormalTextColour", "FFAAAAAA")
        duel.button[6] = guiCreateButton(0.03, 0.86, 0.38, 0.10, "Odadan Ayrıl", true, duel.window[2])
        guiSetProperty(duel.button[6], "NormalTextColour", "FFAAAAAA")
        duel.button[7] = guiCreateButton(0.59, 0.72, 0.38, 0.10, "Odadan At", true, duel.window[2])
        guiSetProperty(duel.button[7], "NormalTextColour", "FFAAAAAA")
        duel.button[8] = guiCreateButton(0.59, 0.86, 0.38, 0.10, "Odayı Kapat", true, duel.window[2])
        guiSetProperty(duel.button[8], "NormalTextColour", "FFAAAAAA")   

		duel.button[9] = guiCreateButton(0.03, 0.03, 0.94, 0.04, "Freeroam'a Geç", true, duel.window[1])
        guiSetFont(duel.button[9], "default-bold-small")
        guiSetProperty(duel.button[9], "NormalTextColour", "FFAAAAAA")
		
		guiEditSetReadOnly(duel.edit[8], true);
		
		for i, wnd in ipairs (duel.window) do 
			guiSetVisible(wnd, false);
			guiWindowSetSizable(wnd, false)
			guiWindowSetMovable(wnd, false)
		end
		
		for i, type in ipairs ({"gridlist", "button"}) do 
			for k, elem in pairs (duel[type]) do 
				addEventHandler ("onClientGUIClick", elem, guiConf, false);
			end
		end
		
		for i, v in pairs (duel.gridlist) do 
			guiGridListSetSortingEnabled(v, false);
		end
		
		for i, v in pairs (duel.edit) do 
			addEventHandler ("onClientGUIFocus", v, guiConf, false);
			addEventHandler ("onClientGUIChanged", v, guiConf, false);
		end	
		
		for _, v in ipairs (weapons) do 		
			guiComboBoxAddItem (duel.combobox[2], getWeaponNameFromID(v));
		end
		
		for i=4, 6 do
			local combo=duel.combobox[i];
			for _, v in ipairs (weapons) do 		
				guiComboBoxAddItem (combo, getWeaponNameFromID(v));
			end
		end
		
		for k, map in ipairs (PVP_MAP) do 
			guiComboBoxAddItem(duel.combobox[1], map.name);
		end
		
		for k, map in ipairs (TDM_MAP) do 
			guiComboBoxAddItem(duel.combobox[3], map.name);
		end
		
		addEventHandler ("onClientGUIComboBoxAccepted", duel.combobox[1], guiConf, false);
		addEventHandler ("onClientGUIComboBoxAccepted", duel.combobox[3], guiConf, false);
    end
);

function guiConf()
	if source==duel.button[9] then
		tr("changemode");
	elseif source==duel.button[3] then
		local weapons=getWeapons("PVP");
		local bet=duel.edit[1]:getText();
		local map;
		local item = guiComboBoxGetSelected(duel.combobox[1]);
		if item == -1 then
			exports.mtatr_hud:dm ("Lütfen önce bir map seçin!", 255, 0, 0);
			return;
		end
		local text = guiComboBoxGetItemText(duel.combobox[1], item);
		local map = findMap(PVP_MAP, text);
		if not tonumber(map) then return; end
		if #weapons <= 0 then 
			outputChatBox ("Silah seçtiğinizden emin olun.", 255, 0, 0);
			return;
		end	
		if tonumber(bet) then 
			tr("create", weapons, "PVP", 2, bet, tonumber(map));
		else
			exports.mtatr_hud:dm ("Lütfen bahis girdiğinizden emin olun!", 255, 0, 0);
		end	
	elseif source==duel.button[4] then 
		local weapons=getWeapons("TDM");
		local bet=duel.edit[9]:getText();
		local map;
		local item = guiComboBoxGetSelected(duel.combobox[3]);
		if item == -1 then
			exports.mtatr_hud:dm ("Lütfen önce bir map seçin!", 255, 0, 0);
			return;
		end
		local text = guiComboBoxGetItemText(duel.combobox[3], item);
		local map = findMap(TDM_MAP, text);
		local limit = duel.edit[7]:getText();
		if not tonumber(limit) then 
			outputChatBox ("Limit girdiğinizden emin olun.", 255, 0, 0);
			return;
		end
		if #weapons <= 0 then 
			outputChatBox ("Silah seçtiğinizden emin olun.", 255, 0, 0);
			return;
		end	
		if not tonumber(map) then return; end
		if tonumber(bet) then 
			tr("create", weapons, "TDM", limit*2, bet, tonumber(map));
		else
			exports.mtatr_hud:dm ("Lütfen bahis girdiğinizden emin olun!", 255, 0, 0);
		end	
	elseif source==duel.button[1] then 
		local room = gt(duel.gridlist[1]);
		if room then 
			room=tonumber(room);
			tr("join", room, "team1");
		end	
	elseif source==duel.button[2] then
		local room = gt(duel.gridlist[1]);
		if room then 
			room=tonumber(room);
			tr("join", room, "team2");
		end	
	elseif source==duel.button[5] then 
		tr("start");
	elseif source==duel.button[6] then 
		tr("leave");
	elseif source==duel.button[7] then
		local player = gt(duel.gridlist[3]);
		if player then 
			player = Player(player);
		end
		if isElement (player) then 
			tr("kick", player);
		end
	elseif source==duel.button[8] then 
		tr("closeroom");
	elseif source==duel.combobox[1] then
		local map;
		local item = guiComboBoxGetSelected(duel.combobox[1]);
		if item == -1 then return; end
		local text = guiComboBoxGetItemText(duel.combobox[1], item);
		local map=findMap(PVP_MAP, text);
		if not map then return; end
		local angle=PVP_MAP[map].angle;
		local int=PVP_MAP[map].int or 0;
		if angle then
			setCameraInterior(int)
			setCameraMatrix(unpack(angle));
		end
	elseif source==duel.combobox[3] then 
		local map;
		local item = guiComboBoxGetSelected(duel.combobox[3]);
		if item == -1 then return; end
		local text = guiComboBoxGetItemText(duel.combobox[3], item);
		local map=findMap(TDM_MAP, text);
		if not map then return; end

		local angle=TDM_MAP[map].angle;
		local int=TDM_MAP[map].int or 0;
		if angle then
			setCameraInterior(int)
			setCameraMatrix(unpack(angle));
		end
	elseif source==duel.edit[1] or source==duel.edit[9] then 
		if eventName=="onClientGUIFocus" then 
			if source:getText()=="Bahis" then 
				source:setText("");
			end
		else 
			local text = guiGetText (source);
			if #text > 0 then 
				guiSetText (source, text:match("%d+") or "");
			end	
		end	
	elseif source==duel.edit[7] then 
		if eventName=="onClientGUIFocus" then 
			if source:getText()=="Maks. Oyuncu" then 
				source:setText("");
			end	
		else
			local text = guiGetText (source);
			if #text > 0 then 
				guiSetText (source, text:match("%d+") or "");
				guiSetText(duel.edit[8], text*2);
			else
				guiSetText (duel.edit[8], "");
			end	
		end	
	elseif source==duel.gridlist[1] then 
		local room=gt(source);
		loadGrid(duel.gridlist[2], room);
	end
end

function getWeapons(typ)
	local tbl={};
	if typ=="PVP" then
		local item = guiComboBoxGetSelected(duel.combobox[2]);
		if item == -1 then return; end
		local text = guiComboBoxGetItemText(duel.combobox[2], item);
		local id = getWeaponIDFromName(text);
		if not id then return; end
		table.insert(tbl, {id=id, ammo=9999});
	else
		for i=4, 6 do
			local combo=duel.combobox[i];
			local edit=duel.edit[i];
			local item = guiComboBoxGetSelected(combo);
			if item ~= -1 then 
				local id = getWeaponIDFromName(guiComboBoxGetItemText(combo, item));
				if id then 
					local ammo=tonumber(edit:getText()) or 999;
					if tonumber(ammo) then 
						table.insert(tbl, {id=id, ammo=ammo});
					end
				end
			end
		end
	end
	return tbl;
end