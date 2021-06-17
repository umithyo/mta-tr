cr = {
    button = {},
    window = {},
    edit = {},
	gridlist = {},
	label = {},
}
addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()

        cr.window[1] = guiCreateWindow((screenW - 365) / 2, (screenH - 245) / 2, 365, 245, "Clan ("..HOTKEY..")", false)
        guiWindowSetSizable(cr.window[1], false)

        cr.label[1] = guiCreateLabel(0.03, 0.09, 0.94, 0.10, "", true, cr.window[1])
        cr.label[2] = guiCreateLabel(0.04, 0.27, 0.17, 0.09, "İsim:", true, cr.window[1])
        cr.label[3] = guiCreateLabel(0.04, 0.48, 0.17, 0.09, "Tag:", true, cr.window[1])
        cr.edit[1] = guiCreateEdit(0.20, 0.24, 0.76, 0.13, "", true, cr.window[1])
        cr.edit[2] = guiCreateEdit(0.20, 0.46, 0.76, 0.13, "", true, cr.window[1])
        cr.label[4] = guiCreateLabel(0.04, 0.71, 0.17, 0.09, "Renk: ", true, cr.window[1])
        cr.button.color = guiCreateButton(0.20, 0.71, 0.76, 0.09, "Seç", true, cr.window[1])
        cr.button[1] = guiCreateButton(0.06, 0.87, 0.19, 0.09, "Onayla", true, cr.window[1])
        cr.button[2] = guiCreateButton(0.77, 0.87, 0.19, 0.09, "Davetler", true, cr.window[1])  
		
        cr.window[2] = guiCreateWindow(0.63, 0.36, 0.21, 0.23, "Davetler", true)
        guiWindowSetSizable(cr.window[1], false)

        cr.gridlist[1] = guiCreateGridList(0.03, 0.11, 0.94, 0.74, true, cr.window[2])
        guiGridListAddColumn(cr.gridlist[1], "Clan İsmi", 0.9)
        cr.button[3] = guiCreateButton(0.04, 0.87, 0.23, 0.09, "onayla", true, cr.window[2])
        cr.button[4] = guiCreateButton(0.74, 0.87, 0.23, 0.09, "reddet", true, cr.window[2]) 
		
		guiSetVisible (cr.window[1], false); 
		guiSetVisible (cr.window[2], false); 
		
		addEventHandler ("onClientGUIClick", cr.button[1], 
			function ()
				local name = cr.edit[1]:getText();
				local tag = cr.edit[2]:getText();
				triggerServerEvent ("onPlayerRequestClanCreation", localPlayer, name, tag, cr.colour);
			end,
		false);	
		-- addEventHandler ("onClientGUIFocus", cr.edit[1], function () source:setText""; end, false);
		-- addEventHandler ("onClientGUIBlur", cr.edit[1], function () source:setText"Grup İsmi"; end, false);
		
		addEventHandler ("onClientGUIClick", cr.button[2], 
			function ()
				guiSetVisible (cr.window[2], not guiGetVisible (cr.window[2]));
			end,
		false);

		addEventHandler ("onClientGUIClick", cr.button[3], 
			function ()
				local item = guiGridListGetSelectedItem (cr.gridlist[1]);
				if item == -1 then return; end
				local group = guiGridListGetItemText (cr.gridlist[1], item, 1);
				triggerServerEvent ("groups:accept_invite", localPlayer, group);
			end,
		false);	
		
		addEventHandler ("onClientGUIClick", cr.button[4], 
			function ()
				local item = guiGridListGetSelectedItem (cr.gridlist[1]);
				if item == -1 then return; end
				local group = guiGridListGetItemText (cr.gridlist[1], item, 1);
				triggerServerEvent ("groups:decline_invite", localPlayer, group);
			end,
		false);	
		
		addEventHandler ("onClientGUIClick", cr.button.color, 
			function ()
				openPicker ("createColor", {255, 255, 255}, "Bir renk seçin.");
			end,
		false);
		
		for i, v in ipairs (getElementsByType"gui-gridlist") do 
			guiGridListSetSortingEnabled (v, false);
		end	
		
		guiSetInputMode ("no_binds_when_editing");
    end
)

function makeCreationWindowVisible(fee, level)
	guiSetVisible (cr.window[1], true);
	showCursor (true);
	guiSetInputMode ("no_binds_when_editing");
	cr.label[1]:setText ("Clan oluşturmak için gereken miktar: "..fee.." seviye: "..level);
end

function destroyCreationWindow ()
	for i, v in pairs (cr.window) do 
		guiSetVisible (v, false);
	end
	showCursor (false);
	closePicker ("createColor");
end

function toggleCreationWindow (fee, level)
	guiSetVisible (cr.window[1], not guiGetVisible (cr.window[1]));
	showCursor (guiGetVisible (cr.window[1]));
	cr.label[1]:setText ("Clan oluşturmak için gereken miktar: "..fee.." seviye: "..level);
	closePicker ("createColor");
	guiSetInputMode ("no_binds_when_editing");
end	

addEvent ("groups:requestInvitations", true);
addEventHandler ("groups:requestInvitations", root, 
	function (tbl)
		if tbl then 
			guiGridListClear (cr.gridlist[1]);
			for i, v in pairs (tbl) do 
				local row = guiGridListAddRow (cr.gridlist[1]);
				guiGridListSetItemText (cr.gridlist[1], row, 1, v.name, false, false);
				guiGridListSetItemColor (cr.gridlist[1], row, 1, unpack(v.color));
			end
		end
	end
);	