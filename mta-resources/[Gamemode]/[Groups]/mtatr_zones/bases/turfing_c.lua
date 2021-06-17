local screenW, screenH = guiGetScreenSize()
local sec = ""
local tick = 0;
local r, g, b = 255, 255, 255;
local marker_tick = getTickCount();

function drawTurfing()
	if sec <= 30*1000 then 
		r, g, b = 255, 0, 0;
	end	
	dxDrawImage(screenW * 0.4632, screenH * 0.0000, screenW * 0.0951, screenH * 0.0322, "files/turf_rectangle.png", 0, 0, 0, tocolor(255, 0, 0, 71), false)
	dxDrawText(totime (sec/1000), screenW * 0.4632, screenH * 0.0000, screenW * 0.5597, screenH * 0.0322, tocolor(r, g, b, 255), 1.00, "pricedown", "center", "center", false, false, false, false, false)
	dxDrawImage(screenW * 0.4951, screenH * 0.0367, screenW * 0.0299, screenH * 0.0456, "files/flag.png", 0, 0, 0, tocolor(255, 255, 255, 255), false);
end

function setSeconds ()
	if getTickCount () - tick >= 1000 then 
		tick = getTickCount ();
		sec = sec - 1000;
	end	
end	

addEvent ("onTeamStartTurfing", true);
addEventHandler("onTeamStartTurfing", root, 
	function (seconds)
		sec = seconds;
		tick = getTickCount();
		addEventHandler("onClientRender", root, drawTurfing);
		removeEventHandler("onClientRender", root, setSeconds);
		addEventHandler("onClientRender", root, setSeconds);
	end
);	

addEvent ("onTeamStopTurfing", true);
addEventHandler ("onTeamStopTurfing", root, 
	function (_type)
		if _type ~= 1 then 
			sec = "";
			r, g, b = 255, 255, 255;
			removeEventHandler("onClientRender", root, setSeconds);
		end	
		removeEventHandler("onClientRender", root, drawTurfing);
	end
);	

function totime(timestamp)
	timestamp = timestamp - (math.floor(timestamp/3600) * 3600)
	local mins = math.floor(timestamp/60)
	if mins < 10 then mins	= "0"..mins end
	timestamp = timestamp - (math.floor(timestamp/60) * 60)
	local secs = math.floor(timestamp)
	if secs < 10 then secs	= "0"..secs end
	return mins..":"..secs
end

local bases = {};
function drawBaseInfo()
	if localPlayer:getDimension () == 0 and localPlayer:getInterior() == 0 then 
		if not isPlayerMapVisible () then 
			local owner, online, level, base, marker = unpack (bases);
			dxDrawText("Sahibi: "..owner, screenW * 0.2236, screenH * 0.7822, screenW * 0.3312, screenH * 0.8033, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
			dxDrawText("Online: "..online, screenW * 0.2236, screenH * 0.8278, screenW * 0.3312, screenH * 0.8489, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
			-- dxDrawText("Level: "..level, screenW * 0.2236, screenH * 0.8722, screenW * 0.3312, screenH * 0.8933, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
			dxDrawText("Turf: "..base, screenW * 0.2236, screenH * 0.8722, screenW * 0.3312, screenH * 0.8933, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		end	
	else
		removeEventHandler ("onClientRender", root, drawBaseInfo);
	end	
end

addEvent ("onPlayerEntersABase", true);
addEventHandler ("onPlayerEntersABase", root, 
	function (owner, online, level, base, show)
		bases = {owner, online, level, base};
		if show == nil then 
			removeEventHandler("onClientRender", root, drawTurfing);
			addEventHandler("onClientRender", root, drawBaseInfo);
		end	
	end
);	

addEvent ("onPlayerLeaveABase", true);
addEventHandler ("onPlayerLeaveABase", root, 
	function ()
		bases = nil;
		removeEventHandler ("onClientRender", root, drawBaseInfo);
	end
);	