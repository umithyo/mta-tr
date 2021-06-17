local screenW, screenH = guiGetScreenSize()
local text, desc, r, g, b;
local tick = 0;
local alpha = 255;
local x = (screenW / 2) - (screenW * 0.3018 / 2);
local w = screenW * 0.6618;
local ty, th = screenH * 0.1067, screenH * 0.2656;
local dy, dh = screenH * 0.2678, screenH * 0.4500;

local function drawNotification()	
	if text and desc then 	
		dxDrawText(text, x - 1, ty -1, w -1, th -1, tocolor(0, 0, 0, alpha), 2.00, "pricedown", "center", "center", false, false, true, false, false);
		dxDrawText(text, x + 1, ty -1, w +1, th -1, tocolor(0, 0, 0, alpha), 2.00, "pricedown", "center", "center", false, false, true, false, false);
		dxDrawText(text, x - 1, ty +1, w -1, th +1, tocolor(0, 0, 0, alpha), 2.00, "pricedown", "center", "center", false, false, true, false, false)
		dxDrawText(text, x + 1, ty +1, w +1, th +1, tocolor(0, 0, 0, alpha), 2.00, "pricedown", "center", "center", false, false, true, false, false);
		dxDrawText(text, x, ty, w, th, tocolor(r, g, b, alpha), 2.00, "pricedown", "center", "center", false, false, true, false, false);
		
		dxDrawText(desc, x - 1, dy -1, w -1, dh -1, tocolor(0, 0, 0, alpha), 2.00, "default", "center", "top", false, true, false, false, false)
		dxDrawText(desc, x + 1, dy -1, w +1, dh -1, tocolor(0, 0, 0, alpha), 2.00, "default", "center", "top", false, true, false, false, false)
		dxDrawText(desc, x - 1, dy +1, w -1, dh +1, tocolor(0, 0, 0, alpha), 2.00, "default", "center", "top", false, true, false, false, false)
		dxDrawText(desc, x + 1, dy +1, w +1, dh +1, tocolor(0, 0, 0, alpha), 2.00, "default", "center", "top", false, true, false, false, false)
		dxDrawText(desc, x, dy, w, dh, tocolor(r, g, b, alpha), 2.00, "default", "center", "top", false, true, false, false, false)
		
		if getTickCount () > tick then 
			alpha = alpha - 15;
			if alpha <= 0 then 
				alpha = 0;
				removeEventHandler ("onClientRender", root, drawNotification);
				text, desc, r, g, b = nil, nil, nil, nil, nil;
			end
		end		
	end	
end

function output (t, d, _r, _g, _b)
	text  = t;
	desc  = d;
	r	  = _r;
	g 	  = _g;
	b  	  = _b;
	tick  = getTickCount () + (#text * 75) + (#desc * 65);
	alpha = 255;
	removeEventHandler ("onClientRender", root, drawNotification);
	addEventHandler("onClientRender", root, drawNotification);
end
addEvent ("civ.output", true);
addEventHandler ("civ.output", root, output);	