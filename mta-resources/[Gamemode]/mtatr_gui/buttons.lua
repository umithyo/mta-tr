local screenW, screenH = guiGetScreenSize ()

local buttons = {};

local function findInTable (value)
	return value;
end

local button = {
	font = "default", --dxCreateFont ("files/font/AppleGaramond.ttf", 12),
	image = "button.png",
	-- sound = {entered = "sounds/entered.wav", clicked = "sounds/clicked.mp3"},
	default = {
		clicked = {
			colour = tocolor (255, 255, 255, 255)
		},
		onpoint = {
			colour = tocolor (255, 255, 255, 205)
		},
		onclick = {
			colour = tocolor (75, 75, 75, 255)
		},
	
		restored = {
			colour = tocolor (200, 200, 200, 255)
		},
		text = {
			colour = tocolor (0, 0, 0, 255),
			scale = getScale (1.0);
		},
	
	}
}

function button:initialize(element)
	if isElement (element) then 
		function button.onclick (b, s)
			if b == "left" and s == "down" then 
				if button.selected then 
					if isElement (button.selected) then 
						local t = getElementType(button.selected)	
						if t and t == "gui-label" then 
							if guiGetVisible (button.selected) then 
								if guiGetEnabled (button.selected) then 
									if not isButtonSticky (button.selected) then 
										buttons[findInTable (button.selected)].state = "onclick"
										-- playSound (button.sound.entered)
										button.selected = nil;
										removeEventHandler ("onClientClick", root, button.onclick)
									end	
								end	
							end
						end
					end	
				end	
			end
		end
		addEventHandler ("onClientMouseEnter", element, 
			function () 
				if not guiGetStickyButtonSelected (element) then 
					button.selected = element
					buttons[findInTable (element)].state = "onpoint"
					--playSound (button.sound.entered)
					if not isEventHandlerAdded ("onClientClick", root, button.onclick) then 
						addEventHandler ("onClientClick", root, button.onclick)
					end	
				end	
			end
		, false)		
		
		addEventHandler ("onClientMouseLeave", element, 
			function ()
				if not guiGetStickyButtonSelected(element) then 
					button.selected = nil 
					buttons[findInTable (element)].state = "restored"
					removeEventHandler ("onClientClick", root, button.onclick)
				else
					
				end	
			end
		, false)		
		
				
		addEventHandler ("onClientGUIClick", element, 
			function (btn, state)
				if btn == "left" then 
					if guiGetEnabled (element) then 
						if not isButtonSticky (element) then 
							buttons[findInTable (element)].state = "clicked"
						--	playSound (button.sound.clicked)
							button.selected = element
							removeEventHandler ("onClientClick", root, button.onclick)
							addEventHandler ("onClientClick", root, button.onclick)
						end	
					end	
				end	
			end
		, false)
	end	
end	

function button:getCount()
	return #buttons;
end	

function button:setVisible (button, visible)
	if button and isElement (button) then 
		if findInTable (button) then 
			if visible then 
			else
				buttons[button] = nil; 
			end
		end
	end
end
	
function drawButton ()
	for i, v in pairs (buttons) do
		if isElement (i) then 
			if guiGetVisible (i) then 
				local x, y, w, h, title = v.x, v.y, v.w, v.h, tostring (i:getText());
				if v.buttontype == "image" then 
					if guiGetEnabled (i) then 
						dxDrawImage (x, y, w, h, v.image, 0, 0, 0, v[v.state].colour, false);
						addOutlines (x, y, w, h, tocolor (200, 200, 200, 255), 1, false);
					else
						dxDrawImage (x, y, w, h, v.image, 0, 0, 0, tocolor (50, 50, 50, 255), false);
						addOutlines (x, y, w, h, tocolor (200, 200, 200, 255), 1, false);
					end	
				elseif v.buttontype == "rectangle" then 
					if not v.nooutline then 
						dxDrawLine(x - 1, y - 1, x - 1, y + h, tocolor (255, 255, 255, 255), 1);
						dxDrawLine(x + w, (y) - 1, (x) - 1, (y) - 1, tocolor (255, 255, 255, 255), 1);
						dxDrawLine((x) - 1, y + h, x + w, y + h, tocolor (255, 255, 255, 255), 1);
						dxDrawLine(x + w, y + h, x + w, (y) - 1, tocolor (255, 255, 255, 255), 1);
					end	
					dxDrawRectangle (x, y, w, h, v[v.state].colour, false);
					if v.header then 
						dxDrawImage (x, y, w/4, h, v.header, 0, 0, 0, tocolor (255, 255, 255, 255), false);
					end	
				end	
				--dxSetRenderTarget (v.render_target);
				if title ~= "" then 
					dxDrawText (title, x, y, x + w, y + h, v.text.colour, v.font == "default" and tonumber (getScale (v.text.scale)) or 1.00, v.font, v.xalign, v.yalign, false, true, false);
				end	
				--dxSetRenderTarget();
			end	
		end	
	end	
end	
addEventHandler ("onClientRender", root, drawButton)
_guiCreateButton = guiCreateButton;
function guiCreateButton (x, y, w, h, title, rel, parent, _type, img)
	local ButtonElement = guiCreateLabel (x, y, w, h, title, true, parent) 
	local x, y = guiGetAbsolutePosition (ButtonElement)
	local _x, _y = guiGetParentSize (ButtonElement)
	if not parent then 
		ButtonElement:setProperty("AlwaysOnTop", "True");
	end	
	guiSetAlpha (ButtonElement, 0)
	button:initialize(ButtonElement)
	guiBringToFront (ButtonElement)
	local image = button.image 
	local font = button.font
	local buttontype = "image";
	local clicked = button.default.clicked;
	local onpoint = button.default.onpoint;
	local onclick = button.default.onclick;
	local restored = button.default.restored;
	local text = button.default.text;
	local xalign = "center";
	local yalign = "center"
	
	if _type then
		if _type.type == "image" then 
			image = ":"..getResourceName(sourceResource).."/".._type.image;
			buttontype = "image";
		else
			buttontype = "rectangle";
			clicked = _type.clicked;
			onpoint = _type.onpoint;
			onclick = _type.onclick;
			restored = _type.restored;
			text = _type.text;
			xalign = _type.xalign;
			yalign = _type.yalign;
		end	
		font = _type.font;
	end	
	
	if img then 
		header = img;
	end	
	
	buttons[ButtonElement] = {
		state = "restored",
		x = x,
		y = y, 
		w = w*_x, 
		h = h*_y, 
		title = title,
		
		sticky = false,
		
		clicked = clicked,
		onpoint = onpoint,
		onclick = onclick,
		restored = restored,
		text = text,
		image = image,
		font = font,
		buttontype = buttontype,	
		header = header,
		xalign = xalign,
		yalign = yalign,
		render_target = dxCreateRenderTarget (w*_x, h*_y),
		
		parent = parent or nil,
	};
	
	if sourceResource then 
		if type (sourceResource) == "userdata" then  
			addEventHandler ("onClientResourceStop", getResourceRootElement (sourceResource), 
				function ()
					buttons[findInTable (ButtonElement)] = nil;
					if isElement (ButtonElement) then 
						ButtonElement:destroy();
					end	
				end
			, false)
		end	
	end	
	
	return ButtonElement
end

function guiSetButtonSticky (button, state)
	if buttons[button] then 
		buttons[button].sticky = state;
	end
end	

function isButtonSticky (button)
	if isElement (button) and buttons[button] then 
		return buttons[button].sticky;
	end
	return false;
end	

function guiGetStickyButtonState (button)
	if isButtonSticky (button) then 
		return buttons[button].state;
	end
end	

function guiGetStickyButtonSelected (button)
	if isButtonSticky (button) then 
		return buttons[button].state == "clicked";
	end
end	

function guiSetStickyButtonSelected (button, _state)
	if isButtonSticky (button) then 
		local state = _state == true and "clicked" or "restored";
		buttons[button].state =  state;
		button.selected = button;
	end
end	