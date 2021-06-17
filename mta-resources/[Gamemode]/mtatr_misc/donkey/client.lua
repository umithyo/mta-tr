local isdonkey = false;

addEventHandler("onClientClick", root, function(button, state, x, y)
    if isPlayerMapVisible() then
        if button == "left" then
            if state == "down" or state == "up" then
                if isdonkey then
                    local minX, minY, maxX, maxY = getPlayerMapBoundingBox()
                    if ((x >= minX and x <= maxX) and (y >= minY and y <= maxY)) then
                        local msx, msy = -(minX - maxX), -(minY - maxY)
                        local x = 6000 * ((x - minX) / msx) - 3000
                        local y = 3000 - 6000 * ((y - minY) / msy)
                        local mX, mY, mZ = getElementPosition(localPlayer)
                        local z = getGroundPosition(mX, mY, 5000) or 40
                        setElementPosition(localPlayer, x, y, z + 1)
                        if isPedInVehicle(localPlayer) then
                            local veh = getPedOccupiedVehicle(localPlayer)
                            setElementPosition(veh, x, y, z + 1)
                        end
                    end
                end
            else
                return
            end
        end
    end
end)

addEvent("donkey.showcursor", true)
addEventHandler("donkey.showcursor", root, function()
    if isPlayerMapVisible() then
        showCursor(not isCursorShowing());
        isdonkey = isCursorShowing();
    else
        showCursor(false);
    end
end);

local mapmarker;

addEventHandler("onClientDoubleClick", root, function(button, x, y)
    if isPlayerMapVisible() then
        if button == "left" then
            if isElement(mapmarker) then
                mapmarker:destroy();
                return;
            end
            local minX, minY, maxX, maxY = getPlayerMapBoundingBox()
            if ((x >= minX and x <= maxX) and (y >= minY and y <= maxY)) then
                local msx, msy = -(minX - maxX), -(minY - maxY)
                local x = 6000 * ((x - minX) / msx) - 3000
                local y = 3000 - 6000 * ((y - minY) / msy)
                local mX, mY, mZ = getElementPosition(localPlayer)
                local z = getGroundPosition(mX, mY, 5000) or 40
                mapmarker = createBlip(x, y, z, 41);
            end
        end
    end
end);

bindKey("k", "down", function()
    if isPlayerMapVisible() then
        showCursor(not isCursorShowing());
    else
        showCursor(false);
    end
end);
