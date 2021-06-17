function getPlayerFromSerial ( serial ) 
	assert ( type ( serial ) == "string" and #serial == 32, "getPlayerFromSerial - invalid serial" ) 
	for index, player in ipairs ( getElementsByType ( "player" ) ) do  
		if ( getPlayerSerial ( player ) == serial ) then  
			return player      
		end   
	end    
	return false
end

function getPedWeapons(ped)
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=0, 12 do
			local wep = getPedWeapon(ped, i)
			local ammo = getPedTotalAmmo (ped, i);
			if wep and wep ~= 0 and ammo ~= 0 then
				table.insert(playerWeapons, {id = wep, ammo = ammo});
			end
		end
	else
		return false
	end
	return playerWeapons
end

function findPlayer (name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end