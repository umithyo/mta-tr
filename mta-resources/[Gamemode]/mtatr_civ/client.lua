local sx, sy = guiGetScreenSize()
local text;
local tick = 0;
local alpha = 255;
local x = (sx - 899) / 2;
local y = (sy - 315) / 2;
local w = ((sx - 899) / 2) + 899;
local h = ( (sy - 315) / 2) + 315;

local function drawNotification()	
	if text then 
		dxDrawText("Görev Tamamlandı\n"..text, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, alpha), 3.00, "pricedown", "center", "top", false, false, false, true, false)
		dxDrawText("Görev Tamamlandı\n#ffffff"..text, x, y, w, h, tocolor(246, 187, 8, alpha), 3.00, "pricedown", "center", "top", false, false, false, true, false)
		if getTickCount () > tick then 
			alpha = alpha - 15;
			if alpha <= 0 then 
				alpha = 0;
				removeEventHandler ("onClientRender", root, drawNotification);
				text = nil;
			end
		end	
	end	
end

function notificate (money, exp)
	text = "+"..money.."₺ +"..exp.." exp";
	tick = getTickCount ()+5000;
	alpha = 255;
	addEventHandler("onClientRender", root, drawNotification);
	playFX ("accomplished.mp3");
end
addEvent ("civ.notificate", true);
addEventHandler ("civ.notificate", root, notificate);

function playFX (fx)
	return playSound ("files/sounds/"..fx);
end	
addEvent ("civ.playfx", true);
addEventHandler ("civ.playfx", root, playFX);	

addEvent ("onClientPlayerLeaveJob", true);