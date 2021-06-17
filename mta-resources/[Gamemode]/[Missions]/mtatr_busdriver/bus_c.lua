createObject(1257,2364.2000000,1992.9000000,11.1000000,0.0000000,0.0000000,0.0000000) --object(bustopm) (1)
createObject(1257,2364.3999000,2105.8000000,11.1000000,0.0000000,0.0000000,0.0000000) --object(bustopm) (2)
createObject(1257,2265.1001000,2156.2000000,11.1000000,0.0000000,0.0000000,90.0000000) --object(bustopm) (3)
createObject(1257,2159.1001000,2181.2000000,11.1000000,0.0000000,0.0000000,0.0000000) --object(bustopm) (4)
createObject(1257,2196.6001000,2322.7000000,11.1000000,0.0000000,0.0000000,322.0000000) --object(bustopm) (5)
createObject(1257,2294.0000000,2388.1001000,11.1000000,0.0000000,0.0000000,359.9980000) --object(bustopm) (6)
createObject(1257,2374.1001000,2480.3999000,11.1000000,0.0000000,0.0000000,359.9950000) --object(bustopm) (7)
createObject(1257,2361.5000000,2720.0000000,11.1000000,0.0000000,0.0000000,87.9950000) --object(bustopm) (8)
createObject(1257,2160.7000000,2780.2000000,11.1000000,0.0000000,0.0000000,89.9900000) --object(bustopm) (9)
createObject(1257,2079.3000000,2659.5000000,11.1000000,0.0000000,0.0000000,181.9890000) --object(bustopm) (10)
createObject(1257,1961.7000000,2400.8999000,11.1000000,0.0000000,0.0000000,91.9890000) --object(bustopm) (11)
createObject(1257,1920.1000000,2210.2000000,11.1000000,0.0000000,0.0000000,179.9830000) --object(bustopm) (12)
createObject(1257,1878.2000000,2054.8999000,11.1000000,0.0000000,0.0000000,80.0000000) --object(bustopm) (13)
createObject(1257,1640.4000000,1817.2000000,11.1000000,0.0000000,0.0000000,179.9970000) --object(bustopm) (14)
createObject(1257,1727.1000000,1616.6000000,10.1000000,2.0000000,0.0000000,163.9950000) --object(bustopm) (15)
createObject(1257,1699.4000000,1125.8000000,11.1000000,0.0000000,0.0000000,270.0000000) --object(bustopm) (16)
createObject(1257,1901.3000000,1086.1000000,11.1000000,0.0000000,0.0000000,270.0000000) --object(bustopm) (17)
createObject(1257,2035.5000000,1023.7000000,11.1000000,0.0000000,0.0000000,180.0000000) --object(bustopm) (18)
createObject(1257,2132.3999000,965.7999900,11.1000000,0.0000000,0.0000000,269.9950000) --object(bustopm) (19)
createObject(1257,2309.3000000,965.7999900,11.1000000,0.0000000,0.0000000,269.9890000) --object(bustopm) (20)
createObject(1257,2354.5000000,1115.0000000,11.1000000,0.0000000,0.0000000,1.9890000) --object(bustopm) (21)
createObject(1257,2434.6001000,1230.8000000,11.1000000,0.0000000,0.0000000,1.9890000) --object(bustopm) (22)
createObject(1257,2434.6001000,1417.8000000,11.1000000,0.0000000,0.0000000,1.9890000) --object(bustopm) (23)
createObject(1257,2434.6001000,1571.6000000,11.1000000,0.0000000,0.0000000,1.9890000) --object(bustopm) (24)
createObject(1257,2334.7000000,1634.8000000,11.1000000,0.0000000,0.0000000,1.9890000) --object(bustopm) (25)
createObject(1257,2392.0000000,1706.5000000,11.1000000,0.0000000,0.0000000,269.9890000) --object(bustopm) (26)
createObject(1257,2513.8999000,1852.3000000,11.1000000,0.0000000,0.0000000,357.9840000) --object(bustopm) (27)
createObject(1257,2465.3000000,1979.9000000,11.1000000,0.0000000,0.0000000,89.9790000) --object(bustopm) (28)

local client = getLocalPlayer( )
local rootElement = getRootElement()
marker = {}
blip = {}


addEvent("bus_set_location",true)
addEventHandler("bus_set_location",rootElement,
function (x, y, z)
	if isElement(marker[localPlayer]) then destroyElement(marker[localPlayer]) end
	if isElement(blip[localPlayer]) then destroyElement(blip[localPlayer]) end
	marker[localPlayer] = createMarker( x, y, z-2, "cylinder", 4, 255, 255, 255, 30 )
	blip[localPlayer] = createBlipAttachedTo( marker[localPlayer], 41, 1, 0, 0, 0, 255, 5, 1200000 )
	addEventHandler( "onClientMarkerHit", marker[localPlayer], onBusStopHit )
end)

function onBusStopHit( hitPlayer )
	if not hitPlayer == localPlayer then return end
	veh = getPedOccupiedVehicle ( localPlayer )
	speedx, speedy, speedz = getElementVelocity ( veh )
	actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
	kmh = actualspeed * 180
	if isElement( marker[localPlayer] ) and kmh < 50 then
		if isElement(blip[localPlayer]) then destroyElement(blip[localPlayer]) end
		setPedControlState( localPlayer, "handbrake", true )
		setTimer( setPedControlState, 3000, 1, localPlayer, "handbrake", false )
		removeEventHandler( "onClientMarkerHit", marker[localPlayer], onBusStopHit )
		destroyElement(marker[localPlayer])
		triggerServerEvent("bus_finish",localPlayer,localPlayer)
	elseif kmh > 49 then
		outputChatBox( "Çok hızlı gidiyorsun!", 255, 0, 0 )
	end
end

addEventHandler("onClientVehicleExit",rootElement,
function (thePlayer,seat)
	if thePlayer == localPlayer and seat == 0 then
		if isElement( marker[thePlayer] ) then
			removeEventHandler("onClientMarkerHit",marker[thePlayer],onBusStopHit)
			destroyElement(marker[thePlayer])
		end
		if isElement( blip[thePlayer] ) then
			destroyElement(blip[thePlayer])
		end
	end
	if isElement(blip[thePlayer]) then destroyElement(blip[thePlayer]) end
end)
addEvent("onClientVehicleHide",true)
addEventHandler("onClientVehicleHide",rootElement,
function ()
	local thePlayer = localPlayer
		if isElement( marker[thePlayer] ) then
			removeEventHandler("onClientMarkerHit",marker[thePlayer],onBusStopHit)
			destroyElement(marker[thePlayer])
		end
		if isElement( blip[thePlayer] ) then
			destroyElement(blip[thePlayer])
		end
	if isElement(blip[thePlayer]) then destroyElement(blip[thePlayer]) end
end)

addEvent ("busdriver.onstart", true);
addEventHandler ("busdriver.onstart", root,
	function (time)
		if isElement (missiontimer) then
			exports.missiontimer:setMissionTimerTime(missiontimer, time);
			return;
		end
		local x = guiGetScreenSize();
		missiontimer = exports.missiontimer:createMissionTimer (time, 0, nil, x/2, 15, true);
	end
);

addEvent ("busdriver.onstop", true);
addEventHandler ("busdriver.onstop", root,
	function ()
		if isElement (missiontimer) then
			missiontimer:destroy();
		end
	end
);

addEvent ("onClientMissionTimerElapsed");
addEventHandler ("onClientMissionTimerElapsed", root,
	function ()
		if source == missiontimer then
			source:destroy();
			triggerServerEvent ("busdriver.elapsed", localPlayer);
		end
	end
);
