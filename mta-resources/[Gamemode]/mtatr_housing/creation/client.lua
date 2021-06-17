local screenW, screenH = guiGetScreenSize();
local in_preview = false;

cr = {
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
	objects = {},
	interiors = {},
	stored_pos = {},
	stored_item = {},
};

addEventHandler ("onClientResourceStart", resourceRoot, 
	function ()
		cr.window[1] = guiCreateWindow(screenW - 358 - 10, (screenH - 360) / 2, 358, 360, "Ev Oluştur", false);
		guiWindowSetSizable(cr.window[1], false);
		guiSetVisible (cr.window[1], false);
		
		cr.gridlist[1] = guiCreateGridList(0.03, 0.06, 0.56, 0.85, true, cr.window[1])
		guiGridListAddColumn(cr.gridlist[1], "Interior", 0.9)
		cr.button[1] = guiCreateButton(0.19, 0.93, 0.25, 0.05, "Önizle", true, cr.window[1])
		guiSetProperty(cr.button[1], "NormalTextColour", "FFAAAAAA")
		cr.edit[1] = guiCreateEdit(0.64, 0.06, 0.32, 0.07, "Fiyat", true, cr.window[1])
		cr.label[1] = guiCreateLabel(0.46, 0.91, 0.51, 0.06, "RMB: Gizle", true, cr.window[1])
		guiSetFont(cr.label[1], "default-small")
		guiLabelSetHorizontalAlign(cr.label[1], "right", false)
		guiLabelSetVerticalAlign(cr.label[1], "center")
		cr.label[2] = guiCreateLabel (.6, .12, .4, .06, "~~~DIŞARI~~~", true, cr.window[1]);
		cr.button[2] = guiCreateButton(0.64, 0.19, 0.32, 0.06, "Pickup", true, cr.window[1])
		guiSetProperty(cr.button[2], "NormalTextColour", "FFAAAAAA")
		cr.button[4] = guiCreateButton(0.64, 0.28, 0.32, 0.06, "Çıkış noktası", true, cr.window[1])
		guiSetProperty(cr.button[4], "NormalTextColour", "FFAAAAAA")
		cr.button[8] = guiCreateButton(0.64, 0.37, 0.32, 0.06, "Çıkış rotasyonu", true, cr.window[1])
		guiSetProperty(cr.button[8], "NormalTextColour", "FFAAAAAA")	
		
		cr.label[3] = guiCreateLabel (.6, .46, .4, .06, "~~~INTERIOR~~~", true, cr.window[1]);
		cr.button[3] = guiCreateButton(0.64, 0.53, 0.32, 0.06, "Spawn noktası", true, cr.window[1])
		guiSetProperty(cr.button[3], "NormalTextColour", "FFAAAAAA")
		cr.button[7] = guiCreateButton(0.64, 0.62, 0.32, 0.06, "Interior marker", true, cr.window[1])
		guiSetProperty(cr.button[7], "NormalTextColour", "FFAAAAAA")
		cr.button[9] = guiCreateButton(0.64, 0.71, 0.32, 0.06, "Interior rotasyonu", true, cr.window[1])
		guiSetProperty(cr.button[9], "NormalTextColour", "FFAAAAAA")		
		cr.button[5] = guiCreateButton(0.62, 0.85, 0.16, 0.05, "Oluştur", true, cr.window[1])
		guiSetProperty(cr.button[5], "NormalTextColour", "FFAAAAAA")
		cr.button[6] = guiCreateButton(0.80, 0.85, 0.16, 0.05, "Kapat", true, cr.window[1])
		guiSetProperty(cr.button[6], "NormalTextColour", "FFAAAAAA") 
		
		guiSetFont (cr.label[2], "default-bold-small");
		guiLabelSetVerticalAlign(cr.label[2], "center")
		guiLabelSetHorizontalAlign(cr.label[2], "center", false)

		guiSetFont (cr.label[3], "default-bold-small");
		guiLabelSetVerticalAlign(cr.label[3], "center")
		guiLabelSetHorizontalAlign(cr.label[3], "center", false)		
		
		addEventHandler ("onClientGUIFocus", cr.edit[1], function () source:setText(""); end, false);
		addEventHandler ("onClientGUIChanged", cr.edit[1], 
			function () 		
				local text = guiGetText (source);
				if #text > 0 then 
					if text:match("%d+") then 
						guiSetText (source, text:match("%d+"));
					else
						source:setText("");
					end	
				end	
			end
		, false);	
		
		local intNode = xmlLoadFile ("config/interiors.xml");
		for i, v in ipairs (xmlNodeGetChildren (intNode)) do 
			local name = xmlNodeGetAttribute (v, "name");
			cr.interiors[name] = {
				xmlNodeGetAttribute (v, "posX"),
				xmlNodeGetAttribute (v, "posY"),
				xmlNodeGetAttribute (v, "posZ"),
				xmlNodeGetAttribute (v, "world"),
				xmlNodeGetAttribute (v, "dimension")
			};
			local row = guiGridListAddRow (cr.gridlist[1]);
			guiGridListSetItemText (cr.gridlist[1], row, 1, name, false, false);
		end
		
		local spawnNode = xmlLoadFile ("config/options.xml");
		if spawnNode then 
			local child = xmlNodeGetChildren (spawnNode, 0);
			if child then 
				spawnInHouse = tonumber (xmlNodeGetValue (child));
				triggerServerEvent ("housing.setspawnin", localPlayer, spawnInHouse);
			end	
		end			
	end
);	

addEvent ("housing.spawn_enabled", true);
addEventHandler ("housing.spawn_enabled", root, 
	function ()
		triggerServerEvent ("housing.setspawnin", localPlayer, spawnInHouse);
	end
);	

local function toggleCursor (key, state)
	showCursor (state == "up");
end	

function toggleCreationMenu ()
	guiSetVisible (cr.window[1], not guiGetVisible (cr.window[1]));
	showCursor (guiGetVisible (cr.window[1]));
	if guiGetVisible (cr.window[1]) then 
		bindKey ("mouse2", "both", toggleCursor);
	else
		clearHouseGUI();
	end	
end	
addEvent ("housing.creationmenu", true);
addEventHandler ("housing.creationmenu", root, toggleCreationMenu);

local offsetAmount = 0.030;
local totalOffsetAmount = 0;

function onCursorMove(cursorX, cursorY)
	if not guiGetVisible (cr.window[1]) or placed then
		return
	end
    if (cr.tempObj and isElement(cr.tempObj)) then
        if (isCursorShowing()) then
            local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
            local px, py, pz = getCameraMatrix()
            local dist = getElementType (cr.tempObj) == "marker" and 2 or 1;
			if getElementType (cr.tempObj) == "marker" then 
				if getMarkerType (cr.tempObj) == "cylinder" then 
					dist = 0
				end
			end	
            local hit, x, y, z, elementHit = processLineOfSight(px, py, pz, worldx, worldy, worldz, true, true, false, true, true, false, false, false)
            if (hit) then
                local px, py, pz = getElementPosition(localPlayer)
                local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
                setElementPosition(cr.tempObj, x, y, (z + dist + totalOffsetAmount));
			else
				setElementPosition(cr.tempObj, worldx, worldy, (worldz + dist + totalOffsetAmount));
            end
        end
    end
end
addEventHandler("onClientCursorMove", root, onCursorMove)

function toggleOffsets(key, state)
    if (state == "up") then
        offsetType = nil
        return
    end
    if (key == "arrow_u") then
        offsetType = "up"
    elseif (key == "arrow_d") then
        offsetType = "down"
    end
end
bindKey("arrow_u", "both", toggleOffsets)
bindKey("arrow_d", "both", toggleOffsets)


function clientPreRender()
    if (offsetType and cr.tempObj and isElement(cr.tempObj)) then
        local addition = 0
        if (getKeyState("lalt")) then
            addition = offsetAmount*100
        end
        local x, y, z = getElementPosition(cr.tempObj)
        if (offsetType == "up") then
            setElementPosition(cr.tempObj, x, y, z + offsetAmount + addition)
            totalOffsetAmount = totalOffsetAmount + offsetAmount + addition
        elseif (offsetType == "down") then
            setElementPosition(cr.tempObj, x, y, z - offsetAmount - addition)
            totalOffsetAmount = totalOffsetAmount - offsetAmount - addition
        end
    end
end
addEventHandler("onClientPreRender", root, clientPreRender)

local function placeObject (key)
	unbindKey ("mouse1", "down", placeObject);
	placed = true;
end

local function createTempObj (type)
	totalOffsetAmount = 0;
	if type == "pickup" then 
		if isElement ( cr.objects.pickup ) then 
			cr.objects.pickup:destroy();
		end	
		cr.objects.pickup = createPickup (0, 0, 0, 3, 1273);
		cr.tempObj = cr.objects.pickup;
	elseif type == "exit_marker" then 
		if isElement (cr.objects.exit) then 
			cr.objects.exit:destroy();
		end	
		cr.objects.exit = createMarker (0, 0, 0, "cylinder", 1.0, 215, 125, 125);
		cr.tempObj = cr.objects.exit;
	elseif type == "spawn_marker" then 
		if isElement (cr.objects.spawn) then 
			cr.objects.spawn:destroy();
		end	
		cr.objects.spawn = createMarker (0, 0, 0, "cylinder", 1.0, 125, 125, 125);
		cr.tempObj = cr.objects.spawn; 
	elseif type == "marker" then 
		if isElement (cr.objects.marker) then 
			cr.objects.marker:destroy();
		end	
		cr.objects.marker = createMarker (0, 0, 0, "arrow", 2.0, 125, 215, 125);
		cr.tempObj = cr.objects.marker; 
	elseif type == "exit_rotation" then 
		if isElement (cr.objects.exrot) then 
			cr.objects.exrot:destroy();
		end	
		cr.objects.exrot = createMarker (0, 0, 0, "cylinder", 1.0, 125, 125, 215);
		cr.tempObj = cr.objects.exrot; 
	elseif type == "enter_rotation" then
		if isElement (cr.objects.enrot) then 
			cr.objects.enrot:destroy();
		end	
		cr.objects.enrot = createMarker (0, 0, 0, "cylinder", 1.0, 215, 215, 125);
		cr.tempObj = cr.objects.enrot; 
	end
	if isElement (cr.tempObj) then 
		cr.tempObj:setDimension (localPlayer:getDimension());
		cr.tempObj:setInterior (localPlayer:getInterior());
	end	
	bindKey ("mouse1", "down", placeObject);
	placed = false;
end

function clearHouseGUI ()
	for i, v in pairs (cr.objects) do 
		if isElement (v) then 
			v:destroy();
		end
	end
	if isElement (cr.tempObj) then 
		cr.tempObj:destroy();
	end
	showCursor (false);
	guiSetVisible (cr.window[1], false);
	unbindKey ("mouse2", "both", toggleCursor);
	removeEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
	setPlayerBack ();
end
addEvent ("housing.closemenu", true);
addEventHandler ("housing.closemenu", root, clearHouseGUI);

function setPlayerBack ()
	if next (cr.stored_pos) then 
		local x, y, z, dim, int = unpack (cr.stored_pos);
		localPlayer:setPosition(x, y, z);
		localPlayer:setDimension (dim);
		localPlayer:setInterior (int);
		in_preview = false;
	end	
end

local function storePos ()
	local px, py, pz = getElementPosition (localPlayer);
	local dim = localPlayer:getDimension ();
	local interior = localPlayer:getInterior ();
	cr.stored_pos = {px, py, pz, dim, interior};
end
	
addEventHandler ("onClientGUIClick", root, 
	function ()
		if source == cr.button[2] then 
			createTempObj ("pickup");
		elseif source == cr.button[3] then 
			createTempObj ("spawn_marker");
		elseif source == cr.button[4] then 
			createTempObj ("exit_marker");
		elseif source == cr.button[7] then 
			createTempObj ("marker");
		elseif source == cr.button[8] then 
			createTempObj ("exit_rotation")
		elseif source == cr.button[9] then 
			createTempObj ("enter_rotation");
		elseif source == cr.button[6] then 
			clearHouseGUI();
		elseif source == cr.button[5] then 
			createHouse ();
		elseif source == cr.button[1] then 
			local item = guiGridListGetSelectedItem (cr.gridlist[1]);
			if not in_preview or item ~= cr.stored_item then 			
				if item ~= -1 then 
					local name = guiGridListGetItemText (cr.gridlist[1], item, 1);
					if cr.interiors[name] then 				
						
						if not in_preview then 
							storePos();
							addEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
						end	
						cr.stored_item = item;
						local x, y, z, int, dim = unpack (cr.interiors[name]); 
						localPlayer:setDimension (dim or 150);
						localPlayer:setInterior(int);
						localPlayer:setPosition (x, y, z+1);
						in_preview = true;
					end
				end	
			else
				removeEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
				setPlayerBack ();
			end	
		end	
	end
);	

function createHouse ()
	local price = cr.edit[1]:getText();
	if price == "" or price == 0 or not tonumber (price) then dm ("Invalid price!", 255, 0, 0); return end
	local name = guiGridListGetSelectedItem (cr.gridlist[1]) ~= -1 and guiGridListGetItemText (cr.gridlist[1], guiGridListGetSelectedItem (cr.gridlist[1]), 1);
	if not name or not cr.interiors[name] then dm ("Geçersiz interior.", 255, 0, 0); return end
	local _,_,_, int, dim = unpack (cr.interiors[name]);
	if not int then dm ("Invalid interior.", 255, 0, 0); return end
	if isElement (cr.objects.spawn) and isElement (cr.objects.exit) and isElement (cr.objects.pickup) and isElement (cr.objects.marker) and isElement (cr.objects.exrot) and isElement (cr.objects.enrot) then 
		local spawnx, spawny, spawnz = getElementPosition (cr.objects.spawn);
		local exitx, exity, exitz = getElementPosition (cr.objects.exit);
		local pickupx, pickupy, pickupz = getElementPosition (cr.objects.pickup);
		local markerx, markery, markerz = getElementPosition (cr.objects.marker);
		local rot = {};
		local ex_x, ex_y, ex_z = getElementPosition (cr.objects.exrot);
		local en_x, en_y, en_z = getElementPosition (cr.objects.enrot)
		rot.exit = {ex_x, ex_y, ex_z + 1};
		rot.enter = {en_x, en_y, en_z + 1};
		triggerServerEvent ("housing.createhouse", localPlayer, int, price, spawnx, spawny, spawnz, exitx, exity, exitz, pickupx, pickupy, pickupz, markerx, markery, markerz, rot, dim);
	else
		dm ("Bütün ev malzemelerini yerleştirdiğinizden emin olun. (pickup, marker, spawn noktası)", 255, 0, 0);
	end	
end	