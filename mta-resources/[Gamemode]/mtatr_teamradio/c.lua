KEY = "num_7";

local screenW, screenH = guiGetScreenSize()
addEvent ("menu.onSendMessage", true);
local properties = {x = screenW * 0.0000, y = screenH * 0.3278, w = screenW * 0.2076, h = screenH * 0.3589};
local options = {mode = "main"};
local menu = {};

function getCurrentMenu ()
	if options.mode == "main" then
		return list.main;
	elseif options.mode == "sub" then
		return  list.sub[options.key];
	end
	return 	false
end

function sendMessage (key)
	local key = tonumber (key);
	local msg = list.sub[options.key][key];
	triggerServerEvent ("menu.onSendMessage", localPlayer, key, msg);
end

addEventHandler ("menu.onSendMessage", root,
	function (key, msg)
		if key then
			playSound ("radio/"..list.sub[options.key][key][2]..".wav");
		end
	end
)

function menu.key (key, por)
	if por then
		if options.mode == "main" then
			if list.main[tonumber (key)] then
				options.key = tonumber (key);
				options.mode = "sub";
			end
		else
			if list.sub[tonumber (options.key)][tonumber(key)] then
				sendMessage(key);
				options.mode = "main"
				removeEventHandler("onClientRender", root, drawMenu);
				removeEventHandler ("onClientKey", root, menu.key);
			end
		end
	end
end


function drawMenu()
	if getCurrentMenu() then
		for i, v in ipairs (getCurrentMenu()) do
			dxDrawText(i.."-"..v[1], properties.x, (properties.y ) + ((i - 1) * 25) , properties.w, properties.h , tocolor(235, 223, 189, 255), 1.30, "default-bold", "left", "top", false, false, false, false, false);
		end
	end
end

bindKey (KEY, "down",
	function (key, state)
		if state == "down" then
			if options.active then
				options.mode = "main"
				removeEventHandler("onClientRender", root, drawMenu);
				removeEventHandler ("onClientKey", root, menu.key);
				options.active = false;
			else
				if isElement (getPlayerTeam(localPlayer)) then
					addEventHandler("onClientRender", root, drawMenu);
					addEventHandler ("onClientKey", root, menu.key);
					options.active = true;
				end
			end
		end
	end
);

bindKey ("backspace", "down",
	function (_, state)
		if state == "down" then
			if options.active then
				options.mode = "main";
			end
		end
	end
);
