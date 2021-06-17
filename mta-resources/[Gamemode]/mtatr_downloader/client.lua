mods			= nil;
mods_ordered 	= nil;
queue 			= {};
enabled 		= {};
occupied 		= {};
config 			= nil;
HOTKEY 			= "F3";
bg_loaders 		= {};
local first		= false;
local exists 	= {};

function table.find (tbl, index, value)
	for i, v in pairs (tbl) do 
		if v[index] == value then 
			return i;
		end
	end
	return false;
end	

dl = {
    gridlist = {},
    window = {},
    button = {}
};

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
        dl.window[1] = guiCreateWindow((screenW - 582) / 2, (screenH - 474) / 2, 582, 474, "Mod Yöneticisi ("..HOTKEY..")", false)
        guiWindowSetSizable(dl.window[1], false)
		guiSetVisible (dl.window[1], false);
		
        dl.gridlist[1] = guiCreateGridList(0.02, 0.06, 0.97, 0.85, true, dl.window[1])
        guiGridListAddColumn(dl.gridlist[1], "Mod", 0.25)
        guiGridListAddColumn(dl.gridlist[1], "Orijinal", 0.25)
        guiGridListAddColumn(dl.gridlist[1], "Boyut", 0.2)
        guiGridListAddColumn(dl.gridlist[1], "Durum", 0.2)
        dl.button[1] = guiCreateButton(0.02, 0.94, 0.20, 0.04, "Aktif/Deaktif", true, dl.window[1])
        dl.button[2] = guiCreateButton(0.32, 0.94, 0.20, 0.04, "Hepsini Aktif Et", true, dl.window[1])
        dl.button[3] = guiCreateButton(0.62, 0.94, 0.20, 0.04, "Hepsini Deaktif Et", true, dl.window[1])
        dl.button[4] = guiCreateButton(0.87, 0.94, 0.11, 0.04, "Kapat", true, dl.window[1])    
		
		for i, v in pairs (dl.button) do 
			addEventHandler ("onClientGUIClick", v, guiConf);
		end	
		
		config = xmlLoadFile ("@save.xml", "mods")
		if not config then 
			config = xmlCreateFile ("@save.xml", "mods");
			first = true;
		end	
		for i, v in ipairs (xmlNodeGetChildren (config)) do 
			local prefix = xmlNodeGetAttribute(v, "name");
			local isEnabled = xmlNodeGetAttribute(v, "enabled") == "true";
			enabled[prefix] = isEnabled;
		end	
		
		triggerServerEvent ("onClientRequestList", resourceRoot);
    end
)

addEvent ("onClientDownloadList", true);
addEventHandler ("onClientDownloadList", root,
	function (tbl, tbl2)
		if tbl then 
			mods = tbl;
			mods_ordered = tbl2;
			loadList ();
			for i, v in ipairs (mods) do 
				toggleMod (v, enabled[v.name] == true);
				if v.background then 
					table.insert (bg_loaders, v);
					if not enabled[v.name] and first == true then 
						toggleMod (v, true, true);
					end	
				end	
			end	
		end	
	end
);

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function loadList ()
	local gr = dl.gridlist[1];
	local item = guiGridListGetSelectedItem (gr)
	guiGridListClear (gr)
	local types = {vehicle = "Araç", skin = "Skin", weapon = "Silah"};
	if next (mods) then
		for type, tbl in pairs (mods_ordered) do
			local catrow = guiGridListAddRow (gr);
			guiGridListSetItemText (gr, catrow, 1, types[type], true, false);
			for i, v in ipairs (tbl) do
				
				local name = v.name;
				local original = "-";
				if type == "vehicle" then
					original = getVehicleNameFromModel (v.model);
				elseif type == "weapon" then 
					original = getWeaponNameFromID (getWeaponIDFromModel(v.model));
				end
				local size = math.round (v.size, 2).." MB";
				local txd = v.txd;
				local status = "Aktif Değil";
				local r, g, b = 255, 0, 0;
				if enabled[name] then
					status = "Aktif";
					r, g, b = 0, 255, 0;
				end

				local row = guiGridListAddRow (gr);
				guiGridListSetItemText (gr, row, 1, name, false, false);
				guiGridListSetItemText (gr, row, 2, original, false, false);
				guiGridListSetItemText (gr, row, 3, size, false, false);
				guiGridListSetItemText (gr, row, 4, status, false, false);
				guiGridListSetItemData (gr, row, 1, table.find(mods, "txd", txd));
				for k = 1, 4 do
					guiGridListSetItemColor (gr, row, k, r, g, b);
				end
			end
		end
		guiGridListSetSelectedItem (gr, item, 1);
	end
end

addCommandHandler ("mods",
	function ()
		guiSetVisible (dl.window[1], not guiGetVisible (dl.window[1]));
		showCursor (guiGetVisible (dl.window[1]));
	end
);

if HOTKEY then
	bindKey (HOTKEY, "down", "mods");
end

function guiConf ()
	if source == dl.button[4] then
		guiSetVisible (dl.window[1], not guiGetVisible (dl.window[1]));
		showCursor (guiGetVisible (dl.window[1]));
	elseif source == dl.button[1] then
		local gr = dl.gridlist[1];
		local item = guiGridListGetSelectedItem(gr);
		if item ~= -1 then
			local name = guiGridListGetItemText (gr, item, 1);
			local index = table.find(mods, "name", name);
			local data = mods[index];
			toggleMod (data);
		end
	elseif source == dl.button[2] then
		for i, v in ipairs (mods) do
			toggleMod (v, true);
		end
	elseif source == dl.button[3] then
		for i, v in ipairs (mods) do
			toggleMod (v, false);
		end
	end
end

function toggleMod (data, state, notif)
	if data then
		local dff = data.dff;
		local txd = data.txd;
		if queue[dff] then
			exports.mtatr_hud:dm ("Bu dosya zaten indiriliyor. Lütfen Bekleyin...", 200, 0, 0);
			return;
		end
		if not dff or not txd then return; end
		if not ( fileExists (dff) or fileExists (txd) ) then
			if state == false then return false; end
			downloadFile (txd);
			downloadFile (dff);
			if not notif then 
				exports.mtatr_hud:dm ("Dosya indiriliyor, lütfen bekleyin...", 0, 255, 0);
			end	
			if not fileExists (txd) then
				queue[txd] = true;
			end
			if not fileExists (dff) then
				queue[dff] = true;
			end
			return;
		end
		if ( fileExists (dff) and fileExists (txd) ) then
			if enabled[data.name] and state ~= true then
				engineRestoreModel (data.model);
				enabled[data.name] = false;
				occupied[data.model] = false;
			else
				if (state == true or state == nil and not enabled[data.name]) then
					if fileExists (dff) then
						downloadFile (dff);
						downloadFile (txd);
						if occupied[data.model] then 
							exports.mtatr_hud:dm ("Bu modele başka bir mod yüklenmiş. Modu deaktif edip tekrar deneyiniz.", 205, 0, 0);
							return;
						end	
						local txd_ = engineLoadTXD (data.txd);
						if txd_ then
							engineImportTXD (txd_, data.model);
						end
						local dff_ = engineLoadDFF (data.dff);
						if dff_ then
							engineReplaceModel (dff_, data.model);
							enabled[data.name] = true;
							occupied[data.model] = true;
							exists[data.name] = true;
							tick = getTickCount () + 2000;
						end
					end
				end
			end
			saveData(data.name, enabled[data.name]==true);			
			loadList();
		end	
	end
end

addEventHandler ("onClientFileDownloadComplete", root,
	function (name, success)
		if ( source == resourceRoot ) then
			if success then 
				local method = "txd";
				if name:find (".dff") then 
					method = "dff";
				end	
				if queue[name] then
					if method == "dff" and fileExists (name) then 
						local index = table.find (mods, method, name);
						local data = mods[index];
						queue[name] = nil;
						toggleMod (data, true);
						loadList();
						exports.mtatr_hud:dm ("Mod başarıyla indirildi. ("..data.name..")", 0, 255, 0);
					end	
				end
			else
				outputChatBox ("Mod indirilirken bir hata oluştu.", 255, 0, 0);
			end	
		end	
	end
);	

local x, y		= guiGetScreenSize();
local h 		= 32;
local rot		= 0;

function drawLoader ()
	if not bg_loaders then return; end
	if next (bg_loaders) then
		rot = rot + 1;
		local count = 0;
		for _ in pairs (exists) do 
			count = count + 1;
		end
		
		local progress = count.."/"..#bg_loaders.." (%"..math.ceil((count/#bg_loaders)*100)..")";
		
		if count >= #bg_loaders then 
			if getTickCount() > tick then 
				removeEventHandler ("onClientRender", root, drawLoader);
				return;
			end	
		end
		
		-- local rx, ry, rw, rh = 0, y-h, x/10, h;
		-- dxDrawImage (rx + 3, ry-4, 42, 42, "icon.png", rot, 0, 0);
		-- addOutlines (rx, ry, rw, rh, tocolor (150, 150, 150, 75), 2);
		-- dxDrawRectangle(rx, ry, rw, rh, tocolor(0, 0, 0, 125), false);
		-- dxDrawText (progress, rx + 42, ry, rw, (y-h) + h, tocolor(255, 255, 255, 255), 1.00, "default", "center", "center");
	end	
end
addEventHandler ("onClientRender", root, drawLoader);

function addOutlines(x, y, width, height, lineColor, lineSize, postGUI)
    dxDrawLine(x - 1, (y - lineSize), x - 1, y + height + (lineSize - 1), lineColor, lineSize, postGUI); --left 
    dxDrawLine(x + width, (y) - 1, (x) - 1, (y) - 1, lineColor, lineSize, postGUI); -- top
    dxDrawLine((x) - 1, y + height, x + width, y + height, lineColor, lineSize, postGUI); -- bottom
    dxDrawLine(x + width, y - lineSize, x + width, y + height + (lineSize - 1), lineColor, lineSize, postGUI); -- right
end

function saveData (name, val)
	if config then 
		local found = false;
		for i, v in ipairs (xmlNodeGetChildren (config)) do 
			if xmlNodeGetAttribute (v, "name") == name then 
				found = true;
				xmlNodeSetAttribute (v, "enabled", tostring (val));
			end	
		end	
		if found == false then 
			local child = xmlCreateChild (config, "mod");
			xmlNodeSetAttribute (child, "name", name);
			xmlNodeSetAttribute (child, "enabled", tostring (val));
		end	
		xmlSaveFile (config);
	end	
end