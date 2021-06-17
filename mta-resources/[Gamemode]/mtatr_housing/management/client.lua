local function requestHousePanel (key, state, id)
	triggerServerEvent ("onClientPlayerRequestHouseManagementPanel", localPlayer, id);
end

addEventHandler ("onClientPickupHit", root, 
	function (player, dim)
		if pickups[source] and player == localPlayer and dim then 
			if isPedInVehicle (player) then return; end
			local id = pickups[source];
			exports.mtatr_hud:dNote ("housePickup", "Press 'X' to Ev panelini aç/kapa.", 255, 226, 0);
			unbindKey ("x", "down", closeManagementMenu);	
			bindKey ("x", "down", requestHousePanel, id);
		end
	end
);	

addEventHandler ("onClientPickupLeave", root, 
	function (player, dim)
		if player == localPlayer then 
			if pickups[source] then 
				closeManagementMenu ();	
				unbindKey ("x", "down", closeManagementMenu);	
				unbindKey ("x", "down", requestHousePanel);		
				bindKey ("x", "down", closeManagementMenu);	
				exports.mtatr_hud:dNote ("housePickup");
			end
		end
	end
);	

addEventHandler ("onClientMarkerHit", root,
	function (player, dim)
		if markers[source] and player == localPlayer and dim then 
			local id = markers[source];
			triggerServerEvent ("onClientPlayerExitsHouse", localPlayer, id);
			setTimer (setElementInterior, 500, 1, localPlayer, 0);
		end
	end
);	

function closeManagementMenu()
	if isElement (mn.window[1]) then 
		mn.window[1]:destroy();
		showCursor (false);
		if isElement (mn.window[2]) then 
			mn.window[2]:destroy();
		end				
		unbindKey ("x", "down", closeManagementMenu);	
		exports.mtatr_hud:dNote ("housePickup");
	end	
end

mn = {
    button = {},
    window = {},
    label = {},
    edit = {},
	checkbox = {},
	gridlist = {},
};

local screenW, screenH = guiGetScreenSize()
function createManagementMenu(id)
	if not id then 
		if isElement (mn.window[1]) then 
			mn.window[1]:destroy();
			showCursor (false);
			if isElement (mn.window[2]) then 
				mn.window[2]:destroy();
			end	
			return
		end	
	end	
	if houses[id] then 
		if isElement (mn.window[1]) then 
			mn.window[1]:destroy();
			showCursor (false);
			if isElement (mn.window[2]) then 
				mn.window[2]:destroy();
			end	
			return
		end	
		local name = getHouseData (id, "name") or "Unowned";
		local bought_price = getHouseData (id, "bought_price") or getHouseData (id, "sale_price");
		local sale_price = getHouseData (id, "sale_price");		
		local sale = getHouseData (id, "for_sale");
		local isOwner = localPlayer:getData ("ID") == getHouseData (id, "owner");
		
		mn.window[1] = guiCreateWindow(0.36, 0.33, 0.30, 0.38, "Ev", true);

		mn.button[1] = guiCreateButton(0.32, 0.79, 0.19, 0.07, "Satışa çıkar", true, mn.window[1])
		mn.button[2] = guiCreateButton(0.54, 0.79, 0.19, 0.07, "Sat", true, mn.window[1])
		mn.button[2]:setVisible(false);
		mn.button[3] = guiCreateButton(0.77, 0.79, 0.19, 0.07, "Gir", true, mn.window[1])
		mn.button[4] = guiCreateButton(0.02, 0.53, 0.20, 0.06, "Satın Al", true, mn.window[1])
		mn.button[5] = guiCreateButton(0.74, 0.52, 0.20, 0.06, "Teklif Ver", true, mn.window[1])
		mn.button[7] = guiCreateButton(0.74, 0.26, 0.20, 0.06, "Teklifler", true, mn.window[1])
		mn.button[10] = guiCreateButton (.77, .89, .19, .07, "Kilitle", true, mn.window[1]);
		
		mn.label[1] = guiCreateLabel(0.85, 0.07, 0.11, 0.04, "ID: "..id, true, mn.window[1])
		guiSetFont(mn.label[1], "default-small")
		guiLabelSetColor(mn.label[1], 255, 226, 0)
		mn.label[2] = guiCreateLabel(0.03, 0.11, 0.17, 0.07, "Ev Sahibi", true, mn.window[1])
		guiSetFont(mn.label[2], "default-bold-small")
		guiLabelSetColor(mn.label[2], 255, 226, 0)
		guiLabelSetHorizontalAlign(mn.label[2], "center", false)
		guiLabelSetVerticalAlign(mn.label[2], "center")
		mn.label[3] = guiCreateLabel(0.02, 0.44, 0.96, 0.07, "-----------------------------------------------------------------------------------------------", true, mn.window[1])
		guiSetFont(mn.label[3], "default-bold-small")
		guiLabelSetColor(mn.label[3], 255, 226, 0)
		mn.label[4] = guiCreateLabel(0.21, 0.11, 0.19, 0.07, name, true, mn.window[1])
		guiLabelSetVerticalAlign(mn.label[4], "center")
		mn.label[5] = guiCreateLabel(0.03, 0.21, 0.17, 0.07, "Net tutar", true, mn.window[1])
		guiSetFont(mn.label[5], "default-bold-small")
		guiLabelSetColor(mn.label[5], 255, 226, 0)
		guiLabelSetHorizontalAlign(mn.label[5], "center", false)
		guiLabelSetVerticalAlign(mn.label[5], "center")
		mn.label[6] = guiCreateLabel(0.21, 0.21, 0.19, 0.07, "₺"..bought_price, true, mn.window[1])
		guiLabelSetVerticalAlign(mn.label[6], "center")
		mn.label[7] = guiCreateLabel(0.03, 0.31, 0.17, 0.07, "Fiyat", true, mn.window[1])
		guiSetFont(mn.label[7], "default-bold-small")
		guiLabelSetColor(mn.label[7], 255, 226, 0)
		guiLabelSetHorizontalAlign(mn.label[7], "center", false)
		guiLabelSetVerticalAlign(mn.label[7], "center")
		mn.label[8] = guiCreateLabel(0.21, 0.31, 0.19, 0.07, "₺"..sale_price, true, mn.window[1])
		guiLabelSetVerticalAlign(mn.label[8], "center")
		mn.label[9] = guiCreateLabel(0.38, 0.52, 0.04, 0.07, "₺", true, mn.window[1])
		guiLabelSetHorizontalAlign(mn.label[9], "right", false)
		guiLabelSetVerticalAlign(mn.label[9], "center")  

		mn.edit[1] = guiCreateEdit(0.02, 0.79, 0.26, 0.07, "", true, mn.window[1])
		mn.edit[2] = guiCreateEdit(0.45, 0.52, 0.26, 0.07, "", true, mn.window[1])

		mn.checkbox[1] = guiCreateCheckBox(0.02, 0.89, 0.50, 0.05, "Evde doğmayı aktifleştir", false, true, mn.window[1])  
		
		setManagementGui(id); 
		
		showCursor (true);
	end	
end
addEvent ("housing.management", true);
addEventHandler ("housing.management", root, createManagementMenu);

function setManagementGui(id)
	if isElement (mn.window[1]) and houses[id] then 
		for i, v in pairs (mn.button) do 
			if isElement (v) then 
				v:setEnabled(true);
			end	
		end
		for i, v in pairs (mn.edit) do 
			v:setEnabled (true);
		end	
		
		mn.checkbox[1]:setEnabled(true);
		
		local name = getHouseData (id, "name") or "Yok";
		local bought_price = getHouseData (id, "bought_price") or getHouseData (id, "sale_price");	
		local sale = getHouseData (id, "for_sale");
		local sale_price = getHouseData (id, "sale_price");	
		local isOwner = localPlayer:getData ("ID") == getHouseData (id, "owner");
		local locked = getHouseData (id, "locked");
		
		if not sale then 
			guiSetEnabled (mn.button[4], false);
		end	
		
		if isOwner then 
			mn.button[4]:setEnabled (false);
			mn.button[5]:setEnabled(false);
			if sale then 
				mn.button[1]:setText ("Satışı durdur");
			else
				mn.button[1]:setText ("Satışa çıkar")
			end	
			if locked then 
				mn.button[10]:setText ("Kilidi Aç");
			else
				mn.button[10]:setText ("Kilitle");
			end	
			if spawnInHouse == id then 
				guiCheckBoxSetSelected (mn.checkbox[1], true);
			end	
		else	
			mn.button[1]:setEnabled (false);
			mn.button[2]:setEnabled (false);
			mn.button[7]:setEnabled (false);
			mn.edit[1]:setEnabled(false);
			mn.button[10]:setEnabled(false)
			mn.checkbox[1]:setEnabled(false);
		end	
		mn.label[4]:setText (name);
		mn.label[6]:setText ("₺"..bought_price);
		mn.label[8]:setText ("₺"..sale_price);
	end	
end
addEvent ("housing.refreshmanagement", true);
addEventHandler ("housing.refreshmanagement", root, setManagementGui);	

addEvent ("housing.managementadmin", true);
addEventHandler ("housing.managementadmin", root, 
	function (isAdmin)
		if isAdmin == true then 
			if isElement (mn.window[1]) then 
				mn.button[6] = guiCreateButton(0.74, 0.35, 0.20, 0.06, "Sil", true, mn.window[1]);
			end	
		end
	end
);	

function toggleOffersWindow ()
	if isElement (mn.window[2]) then 
		mn.window[2]:destroy();
		return
	end	
	mn.window[2] = guiCreateWindow(0.67, 0.33, 0.19, 0.38, "Teklifler", true)

	mn.gridlist[1] = guiCreateGridList(0.03, 0.07, 0.91, 0.80, true, mn.window[2])
	guiGridListAddColumn(mn.gridlist[1], "Oyuncu", 0.4)
	guiGridListAddColumn(mn.gridlist[1], "Teklif", 0.45)
	mn.button[8] = guiCreateButton(0.04, 0.90, 0.26, 0.07, "Onayla", true, mn.window[2])
	mn.button[9] = guiCreateButton(0.70, 0.89, 0.26, 0.08, "Reddet", true, mn.window[2])  	
	loadOffers();
end

function loadOffers ()
	if isElement (mn.window[2]) then 
		guiGridListClear (mn.gridlist[1]);
		local offers = getHouseData(getHouseFromLabel(), "offers");
		if type (offers) == "table" then 
			for i, v in pairs (offers) do 
				local row = guiGridListAddRow (mn.gridlist[1]);
				guiGridListSetItemText (mn.gridlist[1], row, 1, v.name, false, false);
				guiGridListSetItemText (mn.gridlist[1], row, 2, "₺"..v.offer, false, false);
				guiGridListSetItemData (mn.gridlist[1], row, 1, i);
			end	
		end
	end	
end	

function getHouseFromLabel ()
	if isElement (mn.label[1]) then 
		local text = mn.label[1]:getText();
		text = string.gsub (text, "ID: ", "");
		return tonumber (text);
	end
end	

addEventHandler ("onClientGUIClick", root, 
	function ()
		if source == mn.button[1] then 
			if mn.button[1]:getText () == "Satışa çıkar" then 
				exports.mtatr_hud:createDialogBox ("set_sale", "Question", "Evi satılığa çıkarmak istediğinizden emin misiniz?");
			else
				triggerServerEvent ("housing.setforsale", localPlayer, getHouseFromLabel());				
			end	
		elseif source == mn.button[2] then 
			exports.mtatr_hud:createDialogBox ("sell", "Question", "Evi satmak istediğinizden emin misiniz?")			
		elseif source == mn.button[3] then 
			local id = getHouseFromLabel ();
			triggerServerEvent ("housing.enter", localPlayer, id);
		elseif source == mn.button[4] then 
			exports.mtatr_hud:createDialogBox ("buy", "Question", "Bu evi satın almak istiyor musunuz?");
		elseif source == mn.button[5] then 
			local id = getHouseFromLabel ();
			if tonumber (getHouseData (id, "owner")) then 
				exports.mtatr_hud:createDialogBox ("offer", "Question", "Teklif vermek istiyor musunuz?");
			end	
		elseif source == mn.button[6] then 
			exports.mtatr_hud:createDialogBox ("delete_h", "Question", "Evi silmek istediğinizden emin misiniz?");
		elseif source == mn.button[7] then 
			toggleOffersWindow();
		elseif source == mn.button[8] then 
			exports.mtatr_hud:createDialogBox ("accept_o", "Question", "Teklifi kabul etmek istediğinizden emin misiniz?");
		elseif source == mn.button[9] then 
			exports.mtatr_hud:createDialogBox ("decline_o", "Question", "Bu teklifi geri çevirmek istediğinizden emin misiniz?");
		elseif source == mn.button[10] then 
			local id = getHouseFromLabel();
			triggerServerEvent ("housing.lock", localPlayer, id);
		elseif source == mn.checkbox[1] then 
			local sel = guiCheckBoxGetSelected (source);
			local spawnNode = xmlLoadFile ("config/options.xml");
			if not spawnNode then
				spawnNode = xmlCreateFile ("config/options.xml", "options");
			end	
			local child = xmlNodeGetChildren (spawnNode, 0) or xmlCreateChild (spawnNode, "spawn");
			if child then 
				xmlNodeSetValue (child, tostring (sel == true and getHouseFromLabel()));
				spawnInHouse = getHouseFromLabel();
				xmlSaveFile (spawnNode);
			end	
			triggerServerEvent ("housing.setspawnin", localPlayer, spawnInHouse)
		end
	end
);	

addEvent ("onDialogBoxAccepted");

addEventHandler ("onDialogBoxAccepted", root, 
	function (id)
		if id == "set_sale" then 
			local price = mn.edit[1]:getText();
			if price ~= "" then 
				local id_ = getHouseFromLabel ();
				triggerServerEvent ("housing.setforsale", localPlayer, id_, tonumber (price));
			end
		elseif id == "sell" then 
			local id_ = getHouseFromLabel ();
			triggerServerEvent ("housing.sell", localPlayer, id_);	
		elseif id == "buy" then 
			local id_ = getHouseFromLabel ();
			triggerServerEvent ("housing.buyhouse", localPlayer, id_);		
		elseif id == "offer" then 
			local price = mn.edit[2]:getText();
			if price ~= "" then 
				local id_ = getHouseFromLabel ();
				if tonumber (price) then 
					triggerServerEvent ("housing.offer", localPlayer, id_, tonumber (price));
				end	
			end
		elseif id == "delete_h" then 
			local id_ = getHouseFromLabel ();
			deleteHouse (id_);
		elseif id == "accept_o" then 
			local item = guiGridListGetSelectedItem (mn.gridlist[1]);
			if item ~= -1 then 
				local player_id = guiGridListGetItemData (mn.gridlist[1], item, 1);
				local id_ = getHouseFromLabel();
				triggerServerEvent ("housing.reactoffer", localPlayer, tonumber (player_id), tonumber (id_), true);
			end	
		elseif id == "decline_o" then 	
			local item = guiGridListGetSelectedItem (mn.gridlist[1]);
			if item ~= -1 then 
				local player_id = guiGridListGetItemData (mn.gridlist[1], item, 1);
				local id_ = getHouseFromLabel();
				triggerServerEvent ("housing.reactoffer", localPlayer, player_id, id_);
			end	
		end	
	end
);	

local blips = {};
bindKey ("o", "both",
	function (key, state)
		if state == "down" then 
			for pickup, id in pairs (pickups) do
				if getHouseData (id, "owner") ~= localPlayer:getData ("ID") then
					local blip_id = 32;
					if getHouseData (id, "for_sale") then 
						blip_id = 31;
					end	
					local x, y, z = getElementPosition (pickup);
					local blip = createBlip (x, y, z, blip_id, 2, 255, 0, 0, 0, 100);
					blips[blip] = true;
				end	
			end
		elseif state == "up" then 
			for blip in pairs (blips) do 
				if isElement (blip) then 
					blip:destroy();
					blip = nil;
				end	
			end
		end
	end
);