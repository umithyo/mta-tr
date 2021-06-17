local screenW, screenH = guiGetScreenSize();

addCommandHandler ("grup", 
	function ()
		triggerServerEvent ("onPlayerRequestGroupMenu", localPlayer);
	end
);

if HOTKEY then
	bindKey (HOTKEY, "down", function () triggerServerEvent ("onPlayerRequestGroupMenu", localPlayer); end);
end	

addEvent ("onServerRespondGroupMenu", true);
addEventHandler ("onServerRespondGroupMenu", root,
	function (isInGang, state, fee, level)
		if state == false then 
			destroyCreationWindow();
			destroyGroupWindow();
			destroyInviteMenu();
		end	
		if not isInGang then 
			if state == true then 
				makeCreationWindowVisible(fee, level);
				return;
			end	
			if state == nil then 
				toggleCreationWindow(fee, level);
			end	
		else
			if state == true then 
				makeGroupWindowVisible();
				return;
			end	
			if state == nil then 
				toggleGroupWindow();
			end	
		end
	end
);

addEvent ("groups:getInfo", true);
addEventHandler ("groups:getInfo", root, 
	function (tbl, rank)
		if tbl then 
			loadMembers(tbl);
			aclSetGui (rank);
		end
	end
);	

gr = {
    gridlist = {},
    window = {},
    button = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        gr.window[1] = guiCreateWindow((screenW - 506) / 2, (screenH - 349) / 2, 506, 349, "Grup ("..HOTKEY..")", false)
        guiWindowSetSizable(gr.window[1], false)
		guiSetVisible (gr.window[1], false);

        gr.gridlist[1] = guiCreateGridList(0.25, 0.11, 0.73, 0.75, true, gr.window[1])
        guiGridListAddColumn(gr.gridlist[1], "Üye", 0.3)
        guiGridListAddColumn(gr.gridlist[1], "Rank", 0.3)
		guiGridListAddColumn(gr.gridlist[1], "Giriş Tarihi", 0.3)
        gr.button[1] = guiCreateButton(0.02, 0.11, 0.21, 0.09, "Grubu Sil", true, gr.window[1])
        gr.button[2] = guiCreateButton(0.02, 0.23, 0.21, 0.09, "Davet Et", true, gr.window[1])
        gr.button[3] = guiCreateButton(0.25, 0.89, 0.18, 0.07, "Şutla", true, gr.window[1])
        gr.button[4] = guiCreateButton(0.53, 0.89, 0.18, 0.07, "Rank Yükselt", true, gr.window[1])
        gr.button[5] = guiCreateButton(0.78, 0.89, 0.18, 0.07, "Rank Düşür", true, gr.window[1])
        gr.button[6] = guiCreateButton(0.02, 0.35, 0.21, 0.09, "İsim Değiştir", true, gr.window[1])
		gr.button[10] = guiCreateButton (.02, .47, .21, .09, "Tag Değiştir", true, gr.window[1])
        gr.button[7] = guiCreateButton(0.02, 0.59, 0.21, 0.09, "Renk Değiştir", true, gr.window[1])
		gr.button[8] = guiCreateButton (.02, .71, .21, .09, "Ayrıl", true, gr.window[1]);
		gr.button[9] = guiCreateButton (.02, .89, .21, .09, "Devret", true, gr.window[1]);
		
		for i, v in pairs (gr.button) do
			addEventHandler ("onClientGUIClick", v, guiConf, false);
		end
		
		triggerServerEvent ("groups:requestInfo", resourceRoot);
		
		guiSetInputMode ("no_binds_when_editing");
    end
);

function makeGroupWindowVisible ()
	guiSetVisible (gr.window[1], true);
	showCursor (true);
	guiSetInputMode ("no_binds_when_editing");
end

function destroyGroupWindow()
	guiSetVisible (gr.window[1], false);
	showCursor (false);
end

function toggleGroupWindow ()
	guiSetVisible (gr.window[1], not guiGetVisible (gr.window[1]));
	showCursor (guiGetVisible (gr.window[1]));
	if not guiGetVisible (gr.window[1]) then
		closePicker ("clanColor");
		closePicker ("createColor")
		destroyInviteMenu();
		destroyDialogBox();
	end
	guiSetInputMode ("no_binds_when_editing");
end

function loadMembers (members)
	local item = guiGridListGetSelectedItem (gr.gridlist[1]);
	if members then
		guiGridListClear (gr.gridlist[1]);
		for i, v in ipairs (members) do
			local row = guiGridListAddRow (gr.gridlist[1]);
			local d, m, y = todate (v.time);
			local time = d.."/"..m.."/"..y;
			guiGridListSetItemText (gr.gridlist[1], row, 1, v.name, false, false);
			guiGridListSetItemText (gr.gridlist[1], row, 2, v.rank or "yükleniyor...", false, false);
			guiGridListSetItemText (gr.gridlist[1], row, 3, time, false, false);
			guiGridListSetItemData (gr.gridlist[1], row, 1, v.member);
			if v.isActive then
				for k = 1, 3 do
					guiGridListSetItemColor (gr.gridlist[1], row, k, 100, 255, 50);
				end
			else
				for k = 1, 3 do
					guiGridListSetItemColor (gr.gridlist[1], row, k, 100, 100, 100);
				end
			end
		end
		guiGridListSetSelectedItem (gr.gridlist[1], item, 1);
	end
end

function guiConf ()
	if source == gr.button[1] then
		createDialogBox("Lütfen şifrenizi giriniz.");
	elseif source == gr.button[2] then
		createInviteMenu();
	elseif source == gr.button[3] then 
		local item = guiGridListGetSelectedItem (gr.gridlist[1]);
		if item == -1 then return; end
		local player = guiGridListGetItemData (gr.gridlist[1], item, 1);
		triggerServerEvent ("groups:kick", localPlayer, player);
	elseif source == gr.button[4] then
		local item = guiGridListGetSelectedItem (gr.gridlist[1]);
		if item == -1 then return; end
		local player = guiGridListGetItemData (gr.gridlist[1], item, 1);
		triggerServerEvent ("groups:promote", localPlayer, player);
	elseif source == gr.button[5] then
		local item = guiGridListGetSelectedItem (gr.gridlist[1]);
		if item == -1 then return; end
		local player = guiGridListGetItemData (gr.gridlist[1], item, 1);
		triggerServerEvent ("groups:demote", localPlayer, player);
	elseif source == gr.button[6] then
		createDialogBox("Lütfen yeni ismi giriniz.");
	elseif source == gr.button[7] then
		local r, g, b = getPlayerNametagColor(localPlayer);
		openPicker ("clanColor", {r, g, b}, "Bir renk seçin.");
	elseif source == gr.button[8] then
		triggerServerEvent ("groups:leave", localPlayer);
	elseif source == gr.button[9] then 
		local item = guiGridListGetSelectedItem (gr.gridlist[1]);
		if item == -1 then return; end
		local player = guiGridListGetItemData (gr.gridlist[1], item, 1);
		triggerServerEvent ("groups:transfer", localPlayer, player);
	elseif source == gr.button[10] then 
		createDialogBox("Lütfen yeni tagi giriniz.");
	end
end

addEvent ("groups:onClientDialogBoxAccept");
addEventHandler ("groups:onClientDialogBoxAccept", root,
	function (id, text)
		if id == "Lütfen şifrenizi giriniz." then
			local pass = text;
			triggerServerEvent ("groups:delete", localPlayer, pass);
		elseif id == "Lütfen yeni ismi giriniz." then
			triggerServerEvent ("groups:change_name", localPlayer, text);
		elseif id == "Clan İsmi" then 
			local name = text;
			if name ~= "Clan İsmi" and name ~= "" then 
				triggerServerEvent ("onPlayerRequestClanCreation", localPlayer, name);
			end	
		elseif id == "Lütfen yeni tagi giriniz." then 		
			triggerServerEvent ("groups:change_tag", localPlayer, text);
		end
	end
);

addEvent ("onColorPickerOK");
addEventHandler ("onColorPickerOK", root,
	function (id, _, r, g, b)
		if id == "clanColor" then
			triggerServerEvent ("groups:color", localPlayer, r, g, b);
		elseif id == "createColor" then 
			cr.colour = {r, g, b};
		end
	end
);

--UTIL--
dg = {
    button = {},
    window = {},
    edit = {},
	box = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        dg.window[1] = guiCreateWindow((screenW - 350) / 2, (screenH - 100) / 2, 350, 100, "", false)
        guiWindowSetSizable(dg.window[1], false)
		guiSetVisible (dg.window[1], false);

        dg.edit[1] = guiCreateEdit(0.04, 0.36, 0.92, 0.22, "", true, dg.window[1])
        dg.button[1] = guiCreateButton(0.35, 0.71, 0.30, 0.19, "Onayla", true, dg.window[1])
		addEventHandler ("onClientGUIClick", dg.button[1],
			function ()
				triggerEvent ("groups:onClientDialogBoxAccept", source, dg.window[1]:getText(), dg.edit[1]:getText());
				dg.window[1]:setVisible(false);
			end,
		false);
    end
)

function createDialogBox (id)
	dg.window[1]:setText(id);
	guiSetVisible (dg.window[1], true);
	guiBringToFront (dg.window[1], true);
	guiSetInputMode ("no_binds_when_editing");
end

function guiGetDialogBoxText ()
	return dg.edit[1];
end	

function destroyDialogBox()
	dg.window[1]:setVisible(false);
end	


inv = {
    gridlist = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
        inv.gridlist[1] = guiCreateGridList(screenW - 400 - 10, (screenH - 349) / 2, 400, 349, false)
        guiGridListAddColumn(inv.gridlist[1], "Oyuncu (çift tıklayın)", 0.9)
		guiSetVisible (inv.gridlist[1], false);
		addEventHandler ("onClientGUIDoubleClick", inv.gridlist[1],
			function ()
				local item = guiGridListGetSelectedItem (source);
				if item == -1 then return; end
				local player = Player (guiGridListGetItemText (source, item, 1));
				if not isElement (player) then return; end
				triggerServerEvent ("groups:invite", localPlayer, player);
				source:setVisible(false);
			end
		);
    end
)

function createInviteMenu ()
	guiSetVisible (inv.gridlist[1], not (guiGetVisible (inv.gridlist[1])));
	guiGridListClear (inv.gridlist[1]);
	local state;
	for i, v in ipairs (getElementsByType"player") do
		if v ~= localPlayer or state then
			local row = guiGridListAddRow (inv.gridlist[1]);
			local r, g, b = getPlayerNametagColor (v);
			guiGridListSetItemText (inv.gridlist[1], row, 1, v:getName(), false, false);
			guiGridListSetItemColor (inv.gridlist[1], row, 1, r, g, b);
		end
	end
end

function destroyInviteMenu ()
	inv.gridlist[1]:setVisible(false);
end