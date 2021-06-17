local edit = {
	bound = false,
	font =  "default",--dxCreateFont("font/AppleGaramond.ttf", 12),	
	-- guifont = guiCreateFont ("font/AppleGaramond.ttf", 12),
	state = {
		idle = {
			colour = tocolor (255, 255, 255, 255);
		},
		onenter = {
			colour = tocolor (255, 222, 100, 255);
		},
	},	
};

local editboxes = {};

local function findInTable (value)
	return value;
end


function _checkForWidth(editbox)
   --[[ if (dxGetTextWidth(editbox:getText()) > (editboxes[editbox].w - 17)) then
       -- editbox:setText(editboxes[editbox]._old_text);
	   editboxes[editbox]._new_text = string.gsub (editbox:getText(), editboxes[editbox]._old_text, "");
    else
        editboxes[editbox]._old_text = editbox:getText();
		editboxes[editbox].visualText = editbox:getText();
    end]]
end

function edit.onDraw()
	for i, v in pairs (editboxes) do 
		if isElement (i) then 
			if guiGetVisible (i) then 
				addOutlines (v.x, v.y, v.w, v.h, edit.state[v.state].colour, 1);
				dxDrawRectangle (v.x, v.y, v.w, v.h, tocolor (55, 55, 55, 165), false);
				local selection_start, selection_length = tonumber(i:getProperty("SelectionStart")), tonumber(i:getProperty("SelectionLength"));
			
				--[[local carx = v.x + ( selection_start * 6) + ( dxGetTextWidth (i:getText():sub(guiEditGetCaretIndex(i), guiEditGetCaretIndex(i) + caret)))
 				dxDrawLine(carx , v.y, carx, v.y + v.h, tocolor(121, 231, 23, 255), 2, true)]]--
				if (selection_length > 0) then
					local selection_x, selection_width;
					local text = i:getText();
					if v.masked then 
						text = string.rep ("*", #guiGetText(i));
					end	
					if (selection_start == 0) then
						local selection_text = text:sub(1, selection_length);
						selection_x = v.x + 6
						selection_width = dxGetTextWidth(selection_text);
					else
						local pre_text = text:sub(1, selection_start);
						local selection_text = text:sub(selection_start + 1, selection_length + selection_start);
						selection_x = v.x + 6 + dxGetTextWidth(pre_text);
						selection_width = dxGetTextWidth(selection_text);
					end
					if(dxGetTextWidth(v.visualText) > (v.w - 17)) then
						selection_width = dxGetTextWidth (v.visualText);
					end	
					dxDrawRectangle(selection_x, v.y + 1, selection_width, v.h - 2, v.selection.colour, false);
				end
				
				--[[if v.caret ~= selection_start then 
					if v.caret < selection_start then 
						v.caret_dir = true;
					else
						v.caret_dir = false;
					end	
					v.caret = selection_start;
				end]]	
				
				if #i:getText() == 0 then 
					v.index = false;
					v._old_text = i:getText();
					v.visualText = i:getText();
				end	
				
				if dxGetTextWidth (v.visualText) > v.w - 17 then  		 
					local n_text = string.gsub (i:getText(), v._old_text, "");
					n_text = v._old_text:sub(-#v._old_text + selection_start)..n_text;	
					v.visualText = n_text;
					v.index = true;	
				else 
					if not v.index then 
						v._old_text = i:getText();
						v.visualText = i:getText();
					end	
				end	
		
				if v.masked then 
					dxDrawText (string.rep ("*", #v.visualText or ""), v.x + 6 , v.y, v.w + v.x, v.h + v.y, tocolor (255, 255, 255, 255), 1.0, "default", "left", "center", true, false);	
				else
					dxDrawText (v.visualText or "", v.x + 6, v.y, v.w + v.x, v.h + v.y, tocolor (255, 255, 255, 255), 1.0, edit.font, "left", "center", true, false);
				end	
			end
		end	
	end	
end
addEventHandler ("onClientRender", root, edit.onDraw);

function edit.initialize (element)
	addEventHandler ("onClientGUIClick", element, 
		function ()
			if source == element then 
				edit.selected = element;
			end
		end
	);
	addEventHandler ("onClientMouseEnter", element, 
		function ()
			if source == element then 
				editboxes[findInTable (element)].state = "onenter";
			end
		end
	);	
	addEventHandler ("onClientMouseLeave", element, 
		function ()
			if source == element then 
				editboxes[findInTable (element)].state = "idle";
			end
		end
	);
	addEventHandler ("onClientGUIChanged", element, 
		function ()
			if source == element then 
				_checkForWidth(element);
			end
		end
	);	
	
	addEventHandler ("onClientGUIBlur", element, 
		function ()
			if source == element then 
				editboxes[findInTable (element)].selection.colour = tocolor (55, 55, 55, 153);
			end
		end
	);	
	addEventHandler ("onClientGUIFocus", element, 
		function ()
			if source == element then 
				editboxes[findInTable (element)].selection.colour = tocolor(56, 70, 239, 153)
			end
		end
	);	
	
	--guiEditSetMaxLength (element, 24);
end	
_guiEditSetMasked = guiEditSetMasked
function guiEditSetMasked (edit, bool)
	if edit and editboxes[edit] then 
		editboxes[edit].masked = bool;
		_guiEditSetMasked (edit, bool);
	end
end	

_guiCreateEdit = guiCreateEdit;

function guiCreateEdit (x, y, w, h, text, rel, parent)
	local EditElement = _guiCreateEdit (x, y, w, h, text, true, parent);
	guiBringToFront (EditElement)
	guiSetInputMode "no_binds_when_editing"
	local x, y = guiGetAbsolutePosition (EditElement);
	local _x, _y = guiGetParentSize (EditElement);
	guiSetAlpha (EditElement, 0);
	EditElement:setProperty ("AlwaysOnTop", "true");
	--guiSetFont (EditElement, edit.guifont);
	edit.initialize(EditElement);
	
	editboxes[EditElement] = {
		x = x,
		y = y,
		w = w* _x - 7,
		h = h* _y,
		characters = {""},
		masked = false,
		state = "idle",
		_old_text = text or "",	
		index = false,
		caret = 0,
		caret_dir = false,
		visualText = text or "",
		selection = {
			colour = tocolor (55, 55, 55, 153);
		},
	}
	
	if sourceResource then 
		if type (sourceResource) == "userdata" then  
			addEventHandler ("onClientResourceStop", getResourceRootElement (sourceResource), 
				function ()
					editboxes[findInTable (EditElement)] = nil;
					if isElement (EditElement) then 
						EditElement:destroy();
					end	
				end
			, false)
		end	
	end	
	return EditElement
end

guiSetInputMode ("no_binds_when_editing");
 