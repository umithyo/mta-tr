local KEY = "5";

function getPointFromDistanceRotation(x, y, distance, angle)
 
    local angle = -math.rad(270 - angle);
 
    local directionX = math.cos(angle) * distance;
    local directionY = math.sin(angle) * distance;
 
    return x + directionX, y + directionY;
 
end

local rampZOffset, rampZRotOffset = 0.8, 180 --Offset from the center of the ramp to the bottom, approximate.
--This function is execued when the resource starts, it binds the key.
local function resourceStart()
	bindKey(KEY, "down", sendRampRequest)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart)
	
--This function is executed when the local player wants a fucking ramp.
function sendRampRequest()
	local localVehicle = getPedOccupiedVehicle(localPlayer)
	if not localVehicle or getVehicleController(localVehicle) ~= localPlayer then
		return
	end

	local vehicleX, vehicleY, vehicleZ = getElementPosition(localVehicle)
	local vehicleRotX, vehicleRotY, vehicleRotZ	= getElementRotation(localVehicle)
	local vehicleVelX, vehicleVelY, vehicleVelZ = getElementVelocity(localVehicle)
	local rampDistance = (((vehicleVelX^2 + vehicleVelY^2 + vehicleVelZ^2)^(0.5))*50)--Create a ramp 1 seconds away from the player
	if rampDistance > 45 then
		rampDistance = 45
	end
	if rampDistance < 15 then
		rampDistance = 15
	end

	local rampX, rampY = getPointFromDistanceRotation(vehicleX, vehicleY, rampDistance, vehicleRotZ)
	
	--Find the lowest point
	local groundLevel, waterLevel = getGroundPosition(rampX, rampY, vehicleZ), getWaterLevel(vehicleX, vehicleY, vehicleZ)
	local basePosition
	if waterLevel and waterLevel > groundLevel then
		basePosition = waterLevel
	else
		basePosition = groundLevel
	end
	--If the base position and the vehicle position is greater than 1 meter plus the distance from the vehicle's center to base, then we are NOT using the base position.
	--Otherwise, we are.
	local vehicleCenterToBase, rampZ = getElementDistanceFromCentreOfMassToBaseOfModel(localVehicle)
	if (basePosition < (vehicleZ - (vehicleCenterToBase + 1))) then
		rampZ = vehicleZ
	else
		if basePosition == waterLevel then --Use a slightly lower ramp
			rampZ = (basePosition + (rampZOffset / 2))
		end
		if basePosition == groundLevel then
			basePosition = getGroundPosition(rampX, rampY, vehicleZ)
			rampZ = (basePosition + rampZOffset)
		end
	end
	
	local rampRotZ = getAngleBetweenPoints(rampX, rampY, vehicleX, vehicleY)
	local rampRotZ = (rampRotZ + rampZRotOffset) --Fix for the model facing the opposite direction by default.
	
	triggerServerEvent(getResourceName(resource)..":onClientRequestRamp", localPlayer, rampX, rampY, rampZ, 0, 0, rampRotZ)
end

--Triggered when the server informs the client to make a certain ramp impossible to collide with, used to prevent abuse.
addEvent(getResourceName(resource)..":onRampCreated", true)
local function ghostRamp(newRamp)
	if getElementData(newRamp, "creator") ~= localPlayer then
		setElementCollisionsEnabled(newRamp, false)
		setElementAlpha(newRamp, 180)
	end
end
addEventHandler(getResourceName(resource)..":onRampCreated", resourceRoot, ghostRamp)

function getAngleBetweenPoints(x1, y1, x2, y2)
	local angle = -math.deg(math.atan2(x2 - x1, y2 - y1))
	if angle < 0 then
		angle = angle + 360
	end
	return angle
end
