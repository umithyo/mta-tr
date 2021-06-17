local rampRoot = createElement("rampRoot", "rampRoot")

--Executed when a client sends a ramp request, it creates the ramp.
local function createRamp(rX, rY, rZ, rRotX, rRotY, rRotZ)
	if client and source ~= client then return end
	
	--Check for existing ramps made by this player
	local allRamps = getElementChildren(rampRoot)
	if type(allRamps) == "table" and #allRamps > 0 then
		for i,v in ipairs(allRamps) do
			if getElementData(v, "creator") == source then
				killTimer(getElementData(v, "timer"))
				destroyElement(v)
			end
		end
	end
		
	local newRamp = createObject(1655, rX, rY, rZ, rRotX, rRotY, rRotZ)
	setElementParent(newRamp, rampRoot)
	setElementData(newRamp, "creator", source)
	local deletionTimer = setTimer(destroyElement, 5000, 1, newRamp)
	setElementData(newRamp, "timer", deletionTimer, false)
	triggerClientEvent(getResourceName(resource)..":onRampCreated", resourceRoot, newRamp)
end
addEvent(getResourceName(resource)..":onClientRequestRamp", true)
addEventHandler(getResourceName(resource)..":onClientRequestRamp", root, createRamp)

--Executed when a player leaves, this deletes the players ramps.
local function playerQuit()
	local allRamps = getElementChildren(rampRoot)
	if type(allRamps) == "table" and #allRamps > 0 then
		for i,v in ipairs(allRamps) do
			if getElementData(v, "creator") == source then
				killTimer(getElementData(v, "timer"))
				destroyElement(v)
			end
		end
	end
end
addEventHandler("onPlayerQuit", root, playerQuit)