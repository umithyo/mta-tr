function guiGetAbsolutePosition(element)
	local x, y = guiGetPosition(element, false)
	
	if getElementType(element) == "gui-tab" then
		y = y + guiGetProperty(guiGetParent(element), "AbsoluteTabHeight")
	end	
	
	local parent = guiGetParent(element)
	
	while parent do
		local tempX, tempY = guiGetPosition(parent, false)
		
		x = x + tempX
		y = y + tempY
		
		if getElementType(parent) == "gui-tab" then
			y = y + guiGetProperty(guiGetParent(parent), "AbsoluteTabHeight")
		end
		
		parent = guiGetParent(parent)
	end
	
	return x, y
end

function guiGetParent(element)
	local parent = getElementParent(element)
	
	if parent then
		local t = getElementType(parent)
		
		if t and t:find('gui-...') and t ~= 'guiroot' then
			return parent
		end
	end
	
	return nil
end

function guiGetParentSize(element)
	local parent = guiGetParent(element)
	
	if parent then
		return guiGetSize(parent, false)
	else
		-- return guiGetScreenSize()
	end
end


function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if 
		type( sEventName ) == 'string' and 
		isElement( pElementAttachedTo ) and 
		type( func ) == 'function' 
	then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end
 
	return false
end

function addOutlines(x, y, width, height, lineColor, lineSize, postGUI)
    dxDrawLine(x - 1, (y - lineSize), x - 1, y + height + (lineSize - 1), lineColor, lineSize, postGUI); --left 
    dxDrawLine(x + width, (y) - 1, (x) - 1, (y) - 1, lineColor, lineSize, postGUI); -- top
    dxDrawLine((x) - 1, y + height, x + width, y + height, lineColor, lineSize, postGUI); -- bottom
    dxDrawLine(x + width, y - lineSize, x + width, y + height + (lineSize - 1), lineColor, lineSize, postGUI); -- right
end

addEvent ("onGuiVisibilityChange");
_guiSetVisible = guiSetVisible;
function guiSetVisible (...)
	triggerEvent ("onGuiVisibilityChange", ...);
	return _guiSetVisible (...);
end	

function getScale (scale)
	local def = 2060;
	local scalevalue = def / scale;
	local x, y = guiGetScreenSize ();
	if (x+y) > def then 
		return scale;
	end	
	scalevalue = (x + y) / scalevalue;
	return  scalevalue > 0.86 and scalevalue or 0.86; 
end	
function getAbsoluteX(xcoord)
	return screenWidth / 100 * xcoord
end

-- takes a float from 0 to 100 and returns the absolute y-position on the screen
-- higher or lower values are also possible, but will be out of the screen
function getAbsoluteY(ycoord)
	return screenHeight / 100 * ycoord
end

-- function guiSetAlpha(elem, alpha)
	-- if getElementType (elem) == "gui-staticimage" then 
		-- guiWindowSetAlpha (elem, alpha);
	-- elseif getElementType (elem) == "gui-label" then 
		-- guiButtonSetAlpha (elem, alpha);
	-- elseif getElementType (elem) == "gui-edit" then 
		-- guiEditSetAlpha (elem, alpha);
	-- end
-- end	