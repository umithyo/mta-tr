local show = false;
local tick = 0;
local alpha = 255;
local font = "default-bold";
local scale = 1.5;

setRadioChannel(0);
addEventHandler ("onClientPlayerRadioSwitch", localPlayer, 
	function ()
		show = true;
		tick = getTickCount() + 5000;
		cancelEvent();
		alpha = 255;
	end
);	

local ch = 1;
local cfg = getResourceConfig("url.xml");
local url = {{name = "Kapalı"}};
local radio;

do 
	for i, v in ipairs (xmlNodeGetChildren(cfg)) do 
		local name = xmlNodeGetAttribute(v, "name");
		local genre = xmlNodeGetAttribute(v, "genre");
		local url_ = xmlNodeGetAttribute(v, "url");
		table.insert (url, {name = name, genre = genre, url = url_});
	end
end	

bindKey ("radio_previous", "down", 
	function ()
		ch = ch + 1;
		if not url[ch] then 
			ch = 1;
		end
		playRadio();
	end
);	

bindKey ("radio_next", "down",
	function ()
		ch = ch - 1;
		if not url[ch] then 
			ch = #url;
		end
		playRadio();
	end
);	

function playRadio()
	if isElement (radio) then 
		radio:destroy();
	end
	local url_ = url[ch].url;
	if url_ then 
		radio = playSound(url_);
	else
		if isElement (radio) then 
			radio:destroy();
		end	
	end	
end	

local x, y 	= guiGetScreenSize()
local w		= y * 0.0489;

addEventHandler("onClientRender", root,
    function()
		if show then 
			if getTickCount() > tick then	
				if alpha-3 <= 0 then 
					show=false;
					return;
				end	
				alpha = alpha - 3;			
			end	
			local name = url[ch].name;
			local genre = url[ch].genre and " ("..url[ch].genre..")" or "";
			local text = (name..genre);
			-- dxDrawText(text, -1, - 1, - 1, w - 1, tocolor(0, 0, 0, alpha), scale, font, "center", "center");
			-- dxDrawText(text, 0 + 1, 0 - 1, x + 1, w - 1, tocolor(0, 0, 0, alpha), scale, font, "center", "center");
			-- dxDrawText(text, 0 - 1, 0 + 1, x - 1, w + 1, tocolor(0, 0, 0, alpha), scale, font, "center", "center");
			-- dxDrawText(text, 0 + 1, 0 + 1, x + 1, w + 1, tocolor(0, 0, 0, alpha), scale, font, "center", "center");
			dxDrawText(text, 0, y * 0.0000, x, w, tocolor(221, 157, 33, alpha), scale, font, "center", "center");
		end	
    end
)

addEventHandler ("onClientPlayerVehicleExit", root,
	function ()
		if source == localPlayer then 
			if isElement (radio) then 
				radio:destroy();
			end
		end
	end
);	

addEventHandler ("onClientPlayerWasted", localPlayer,
	function ()
		if isElement (radio) then 
			radio:destroy();
		end
	end
);	