_guiCreateWindow = guiCreateWindow
local windows = {};
local dx_window = {
	font = "default",--dxCreateFont( "font/buttonsfont.ttf", 11),
	bg = "back.png",
};
screenW, screenH = guiGetScreenSize();

function guiCreateWindow (x, y, w, h, title, relative, parent, _type)
	local WindowElement = guiCreateStaticImage (x, y, w, h, "blank.png", relative, parent);
	local x, y = guiGetAbsolutePosition (WindowElement);
	local _w, _h = guiGetParentSize (WindowElement) or w, h;
	if relative then 
		_w, _h = guiGetScreenSize();
		_w = w * _w;
		_h = h * _h;
	end	
	local layer, image;
	local color;
	if _type then 
		image = ":"..getResourceName(sourceResource).."/".._type.image;
		layer = type (_type.layer) == "string" and ":"..getResourceName(sourceResource).."/".._type.layer or _type.layer;
		color = _type.colour;
	end	
	windows[WindowElement] = {
		title = title,
		x = x, 
		y = y,
		w = _w,
		h = _h,
		layer = layer,
		image = image,
		colour = color
	};
	
	if sourceResource then
		if type (sourceResource) == "userdata" then 
			addEventHandler("onClientResourceStop", getResourceRootElement (sourceResource),
				function(res)	
					if isElement(WindowElement) then 
						destroyElement(WindowElement); 
					end	
				end,
			false)	
		end	
	end
	
	return WindowElement;
end

function dx_window.render ()
	for window, properties in pairs (windows) do 
		if isElement (window) then 
			if guiGetVisible (window) then 
				local r, g, b, a = 0, 0, 0, 255;
				if properties.colour then 
					r, g, b, a = unpack (properties.colour);
				end	
				if not properties.image then 
					dxDrawImage (properties.x, properties.y, properties.w, properties.h, dx_window.bg);
				else
					dxDrawImage (properties.x, properties.y, properties.w, properties.h, properties.image);
				end	
				if properties.title ~= "" then 
					if not properties.layer then 
						dxDrawImage (properties.x, properties.y, properties.w, dxGetFontHeight (getScale(1.0), dx_window.font) + 5, "layer.png");
					elseif type (properties.layer) == "string" then 
						dxDrawImage (properties.x, properties.y, properties.w, dxGetFontHeight (getScale(1.0), dx_window.font) + 5, properties.layer);
					end	
				end	
				
				dxDrawText (properties.title, properties.x, properties.y, properties.w + properties.x, properties.y + dxGetFontHeight (getScale(1.0), dx_window.font) + 5, tocolor (r, g, b, a), getScale (1.0), dx_window.font, "center", "center", true, true);
			end
		end
	end	
end

addEventHandler ("onClientRender", root, dx_window.render);

function dxWindowSetText (window, text)
	if windows[window] then 
		windows[window].title = tostring (text);
	end	
end