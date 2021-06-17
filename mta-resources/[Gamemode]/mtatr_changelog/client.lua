LIMIT = 3;

cg = {
    button = {},
    window = {},
    label = {}
};

local config = xmlLoadFile ("@seen_chg.xml") or xmlCreateFile ("@seen_chg.xml", "changelog");
local seen = {};

for i, v in ipairs (xmlNodeGetChildren(config)) do 
	local value = xmlNodeGetValue(v);
	seen[tostring (value)] = true;
end	

local data = {};

addEvent ("updates:getUpdates", true);
addEventHandler("updates:getUpdates", root,
    function (tbl)
		if tbl then 
			for i, v in ipairs (tbl) do 
				data[tostring(v.date)] = v;
			end
		end	
		showChangeLog();		
    end
);

addEventHandler ("onClientResourceStart", resourceRoot, 
	function ()
		triggerServerEvent ("updates:getUpdates", localPlayer);
	end
);	

function showChangeLog()
	if isElement (cg.window[1]) then return; end
	local chg = {};
	for i, v in pairs (data) do 
		if not seen[i] then 
			table.insert(chg, v);
		end
	end
	table.sort (chg, function(a, b) return a.date > b.date; end);
	if LIMIT then 
		local dummy_tbl = {};
		for i, v in ipairs (chg) do 
			if i <= LIMIT then 
				table.insert (dummy_tbl, v);
			end
		end	
		chg = dummy_tbl;
	end	
	if #chg == 0 then return; end	
	local screenW, screenH = guiGetScreenSize()
	cg.window[1] = guiCreateWindow((screenW - 532) / 2, (screenH - 379) / 2, 532, 379, "Duyuru", false)
	guiWindowSetSizable(cg.window[1], false)
	guiSetAlpha(cg.window[1], 1.00)
	
	cg.label[1] = guiCreateLabel(0.02, 0.06, 0.98, 0.07, chg[1].head, true, cg.window[1])
	guiSetFont(cg.label[1], "default-bold-small")
	guiLabelSetColor(cg.label[1], 33, 201, 221)
	guiLabelSetHorizontalAlign(cg.label[1], "center", false)
	guiLabelSetVerticalAlign(cg.label[1], "center")
	cg.label[2] = guiCreateLabel(0.02, 0.14, 0.98, 0.77, chg[1].log, true, cg.window[1])
	guiLabelSetHorizontalAlign(cg.label[2], "left", true)
	guiSetFont(cg.label[2], "default-bold-small")
	cg.button[1] = guiCreateButton(0.44, 0.92, 0.13, 0.05, "Kapat", true, cg.window[1])
	guiSetProperty(cg.button[1], "NormalTextColour", "FFFE0000")  
	addEventHandler ("onClientGUIClick", cg.button[1], 
		function ()
			cg.window[1]:destroy(); 
			showCursor(false);
			if #chg > 0 then 
				showChangeLog();
			end	
		end, 
	false);
	showCursor(true);
	if not seen[tostring (chg[1].date)] then 
		xmlNodeSetValue(xmlCreateChild(config, "log"), chg[1].date);
	end
	xmlSaveFile (config);
	seen[tostring (chg[1].date)] = true;
end