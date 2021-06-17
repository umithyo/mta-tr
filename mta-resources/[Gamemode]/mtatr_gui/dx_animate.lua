function drawAnimatedText (text, x, y, w, h, colour, alpha, font, xalign, yalign, scale, shadow, outline)
	if shadow and outline then 
		dxDrawText(text, x - 1, y - 1, w - 1, h - 1, tocolor(0, 0, 0, alpha),scale, font, xalign, yalign, false, false, false, false, false)
		dxDrawText(text, x + 1, y - 1, w + 1, h - 1, tocolor(0, 0, 0, alpha),scale, font, xalign, yalign, false, false, false, false, false)
		dxDrawText(text, x - 1, y + 1, w - 1, h + 1, tocolor(0, 0, 0, alpha),scale, font, xalign, yalign, false, false, false, false, false)
		dxDrawText(text, x + 1, y + 1, w + 1, h + 1, tocolor(0, 0, 0, alpha), scale, font, xalign, yalign, false, false, false, false, false)
	end	
	dxDrawText(text, x, y, w, h, tocolor (colour.r, colour.g, colour.b, alpha),scale, font, xalign, yalign, false, false, false, false, false)
end	

function dxDrawAnimatedText (text, x, y, w, h, endx, endy, endw, endh, animateending, colour, progress, length, remove, type, scale, font, xalign, yalign, shadow, outline)
	local remove_ = remove or true
	local progress = progress or 3
	local length = length or 250
	local colour = colour or {r = 255, g = 255, b = 255}
	
	begin = getTickCount () + progress * 1000
	start = getTickCount ()
	
	local function remove ()
		local rate = (getTickCount () - start) / ((length) )
		local alpha = interpolateBetween (255, 0, 0, 0, 0, 0, rate, "Linear")
		local _x, _y = endx, endy
		local _w, _h = endw, endh
		if animateending then 
			_w, _h = interpolateBetween (endw, endh, 0, w, h, 0, rate, type or "Linear")
			_x, _y = interpolateBetween (endx, endy, 0, x, y, 0, rate, type or "Linear")
		end	
		drawAnimatedText (text, _x, _y, _w, _h, colour, alpha, font or "default", xalign or "center", yalign or "center" , scale or 1.0, shadow or true, outline or true)
		if alpha <= 0 then 
			removeEventHandler ("onClientRender", root, remove)
		end
	end	
	
	local function draw ()
		local rate = (getTickCount () - start) / ((length) )
		local _x, _y = interpolateBetween (x, y, 0, endx, endy, 0, rate, type or "Linear")
		local _w, _h = interpolateBetween (w, h, 0, endw, endh, 0, rate, type or "Linear")
		local alpha = interpolateBetween (0, 0, 0, 255, 0, 0, rate, "Linear")
		if begin <= getTickCount () then 
			start = getTickCount ()
			removeEventHandler ("onClientRender", root, draw)
			if remove_ then 
				addEventHandler ("onClientRender", root, remove)
			end
		end	
		drawAnimatedText (text, _x, _y, _w, _h, colour, alpha, font or "default", xalign or "center", yalign or "center" , scale or 1.0, shadow or true, outline or true)
	end
	addEventHandler ("onClientRender", root, draw)
end	
