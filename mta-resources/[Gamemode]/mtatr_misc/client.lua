setMinuteDuration(60000)
setTime(getRealTime().hour, getRealTime().minute)

local damage_sounds = {};

local function count ()
	local counter = 0;
	for _ in pairs (damage_sounds) do
		counter = counter + 1;
	end
	return counter;
end

local function playDamageSound ()
	if count() < 2 then 
		local sound = playSFX("genrl", 52, 12, false);
		damage_sounds[sound] = true;
		setTimer (
			function (s)					
				damage_sounds[s] = nil;
			end, 
		100, 1, sound);
	end	
end	

addEvent ("misc.playDamageSound", true)
addEventHandler ("misc.playDamageSound", root, 
	function ()
		playDamageSound();
	end
)	

addEventHandler ("onClientVehicleDamage", root, 
	function (attacker)
		if attacker == localPlayer then 		
			playDamageSound();	
		end	
	end
)	

local screenW, screenH = guiGetScreenSize();

local dmg = {
	blockedweapons = {
		[18] = true,
		[37] = true,
	},
	tick = getTickCount (),
	alpha = 0,
}
addEventHandler ("onClientPlayerDamage", root, 
	function (attacker, weapon)
		if source == localPlayer then 
			if not localPlayer:getData"indm" then return; end
			if not dmg.drawing then 
				addEventHandler ("onClientPreRender", root, dmg.draw)
				dmg.drawing = true
				if dmg.blockedweapons[weapon] then 
					dmg.tick = getTickCount() + 150
					setTimer (
						function ()
							dmg.fade = true
						end, 
					250, 1)	
					return
				end	
				setTimer (
					function ()
						dmg.fade = true
					end, 
				150, 1)	
			end	
		end	
	end
)	

function dmg.draw ()
	if getTickCount() >= dmg.tick then 	
		if not dmg.fade then 
			dmg.alpha = 50
		end	
		if dmg.fade then 
			dmg.alpha = dmg.alpha - 12
			if dmg.alpha <= 0 then 
				dmg.drawing = false;
				dmg.fade = false;
				removeEventHandler ("onClientPreRender", root, dmg.draw)
				dmg.alpha = 0
			end
		end	
		dxDrawRectangle(screenW * 0, screenH * 0, screenW * 1, screenH * 1, tocolor(254, 1, 1, dmg.alpha), false)
	end	
end	

function handleMinimize()
    setElementData(localPlayer, "AFK", true)
end
addEventHandler( "onClientMinimize", root, handleMinimize )

function handleRestore( didClearRenderTargets )
    setElementData(localPlayer, "AFK", false)
	if isTimer(timer) then resetTimer(timer) else timer = setTimer(handleMinimize,60000,1) end
end
addEventHandler("onClientRestore",root,handleRestore)
addEventHandler("onClientKey",root,handleRestore)

function onResourceStart()
    setElementData(localPlayer, "AFK", false)
	timer = setTimer(handleMinimize,60000,1)
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)

local messages = {};
addEventHandler ("onClientRender", root, 
	function ()
		local sx, Sy = guiGetScreenSize ( )
		if getElementData (localPlayer, "loggedin") and getElementData (localPlayer, "current.char") then 
			if not playerExp then playerExp = getElementData (localPlayer, "char.exp"); end
			if not tonumber (playerExp) then playerExp = 0; end
			if not playerMoney then playerMoney = getPlayerMoney(); end
			if not playerMoney then playerMoney = 0 end
			local tick = getTickCount()
			if ( playerMoney ~= getPlayerMoney() ) then
				local pM = getPlayerMoney()
				if ( pM > playerMoney ) then
					local diff = pM - playerMoney
					table.insert ( messages, { diff, true, tick + 5000, 180 } )
				else
					local diff = playerMoney - pM
					table.insert ( messages, { diff, false, tick + 5000, 180 } )
				end
				playerMoney = pM
			end
			
			if ( playerExp ~= getElementData (localPlayer, "char.exp") ) then
				local pM = getElementData (localPlayer, "char.exp") or 0
				if ( pM > playerExp ) then
					local diff = pM - playerExp
					table.insert ( messages, { math.ceil(diff), true, tick + 5000, 180, true } )
				else
					local diff = playerExp - pM
					table.insert ( messages, { math.ceil(diff), false, tick + 5000, 180, true } )
				end
				playerExp = pM
			end
			
			if ( #messages > 4 ) then
				table.remove ( messages, 1 )
			end
			
			for index, data in ipairs ( messages ) do
				local v1 = data[1]
				local v2 = data[2]
				local v3 = data[3]
				local v4 = data[4]
				local exper = data[5]
				sy = Sy*0.95
				if (isPedInVehicle(localPlayer)) then sy = sy*0.7 end
				if ( v2 ) then
					local r,g,b = 0,255,0
					local ind = "₺";
					if exper then 
						r,g,b = 255,223,75;
						ind = " EXP";
					end
					dxDrawText ( "+ "..convertNumber ( v1 )..ind, (sx*0.95), (sy*0.95)-(index*25), (sx*0.95), (sy*0.95)-(index*25), tocolor ( r, g, b, v4+75 ), 2, "default", "right", "bottom", false, false, false, true, true)
				else
					local r,g,b = 255,0,0
					local ind = "₺";
					if exper then
						r,g,b = 255,223,75;
						ind = " EXP";
					end
					dxDrawText ( "- "..convertNumber ( v1 )..ind, (sx*0.95), (sy*0.95)-(index*25), (sx*0.95), (sy*0.95)-(index*25), tocolor ( r, g, b, v4+75 ), 2, 'default', "right", "bottom", false, false, false, true, true)
				end
				
				if ( tick >= v3 ) then
					messages[index][4] = v4-2
					if ( v4 <= 25 ) then
						table.remove ( messages, index )
					end
				end
			end
		end	
	end
);	

function convertNumber ( number )  
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end