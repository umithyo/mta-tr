local d_box = {
	window = {},
};

local function nav_dbox (key, state, id)
	acceptDbox (id);
end

function createDialogBox (id, _type, text)
	if isDialogBoxActive() then return end
	if isElement (d_box.window[id]) then return end
	d_box.window[id] = guiCreateWindow(0.38, 0.39, 0.23, 0.16, "", true)
	d_box.window[id]:setProperty ("AlwaysOnTop", "True");
	
	local image = guiCreateStaticImage(0.05, 0.28, 0.21, 0.41, "images/".._type..".png", true, d_box.window[id])
	local label = guiCreateLabel(0.30, 0.28, 0.65, 0.40, text, true, d_box.window[id])
	guiLabelSetHorizontalAlign(label, "left", true)
	local button = {};
	if _type == "Question" then 
		button[7] = guiCreateButton(0.31, 0.77, 0.18, 0.14, "Evet", true, d_box.window[id])
		guiSetProperty(button[7], "NormalTextColour", "FFAAAAAA")
		addEventHandler ("onClientGUIClick", button[7], function () acceptDbox(id) end, false);
		button[8] = guiCreateButton(0.58, 0.77, 0.18, 0.14, "Hayır", true, d_box.window[id])
		guiSetProperty(button[8], "NormalTextColour", "FFAAAAAA") 
		addEventHandler ("onClientGUIClick", button[8], function () declineDbox(id) end, false);	
	else
		button[7] = guiCreateButton(0.37, 0.81, 0.25, 0.12, "Tamam", true, d_box.window[id])
		guiSetProperty(button[7], "NormalTextColour", "FFAAAAAA")   
		addEventHandler ("onClientGUIClick", button[7], function () acceptDbox(id) end, false);		
	end
	
	bindKey ("enter", "down", nav_dbox, id);
	bindKey ("num_enter", "down", nav_dbox, id);
end

function closeDialogBox (id)
	if isElement (d_box.window[id]) then 
		d_box.window[id]:destroy();
		d_box.window[id] = nil;
	end	
	local count = 0;
	for _ in pairs (d_box.window) do 
		count = count + 1;
	end
	if count == 0 then 
		unbindKey ("enter", "down", nav_dbox);
		unbindKey ("num_enter", "down", nav_dbox);
	end		
end

function acceptDbox (id)
	triggerEvent ("onDialogBoxAccepted", localPlayer, id);
	closeDialogBox(id)
end

function declineDbox (id)
	triggerEvent ("onDialogBoxDeclined", localPlayer, id);
	closeDialogBox(id);
end

function isDialogBoxActive ()
	for i, v in pairs (d_box.window) do 
		if isElement (v) then 
			return true;			
		end
	end
end	