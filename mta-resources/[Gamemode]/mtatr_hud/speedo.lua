local width, height = guiGetScreenSize()
local relativity = height / 100 * 30
-- this function draws the speedo on every render, in case the player is in a vehicle
function drawSpeedo()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and not isPlayerMapVisible() then

		local driver = getVehicleOccupant(vehicle)
		
		dxDrawImage(width - (375 / 265) * relativity, height - (265 / 265) * relativity, (375 / 265) * relativity, (265 / 265) * relativity, "images/speedo.png")

		local velX, velY, velZ = getElementVelocity(vehicle)
		local actualspeed = (velX^2 + velY^2 + velZ^2)^(0.5) 
		local kmh = actualspeed * 180
		local rotationsPerMinute = 2 
		local offsetRotation = 8 / 1.055555
		local rotation = (kmh-6) / 1.055555 - offsetRotation
		if rotation > 300 then
			rotation = 300
		end

		dxDrawImage(width - (259 / 265) * relativity, height - (262 / 265) * relativity, (250 / 265) * relativity, (250 / 265) * relativity, "images/speedNeedle.png", rotation, (1 / 265) * relativity, (3 / 265) * relativity)
		dxDrawImage(width - (159 / 265) * relativity, height - (157 / 265) * relativity, (51 / 265) * relativity, (46 / 265) * relativity, "images/speedPin.png")
	elseif not isPedInVehicle(localPlayer) then
		removeEventHandler("onClientRender",root, drawSpeedo)
	end
end


-- this function is executed when the local player enters a vehicle
function onVehicleEnter(enteredBy)
	if enteredBy == localPlayer then
		addEventHandler("onClientRender", root, drawSpeedo)		
	end
end

addEventHandler("onClientVehicleEnter", root, onVehicleEnter)
