local MAIN_VELOCITY = 40;

addEventHandler("onResourceStart", resourceRoot,
    function()
		exports.mtatr_civ:construct("Otobüs Şoförü", "", 2258.37, 2055.82, 10.82, 125, 125, 255, {});
		
		local XMLBusLocations = xmlLoadFile ( "bus_routes.xml" )
		if ( not XMLBusLocations ) then
			local XMLBusLocations = xmlCreateFile ( "bus_routes.xml", "bus_routes" )
			xmlSaveFile ( XMLBusLocations )
		end
		
		local bus_locations = xmlNodeGetChildren(XMLBusLocations)
        busLocations = {}
        for i,node in ipairs(bus_locations) do
			busLocations[i] = {}
			local routes = xmlNodeGetChildren(node)
			for is,subNode in ipairs(routes) do
				busLocations[i][is] = {}
				busLocations[i][is]["x"] = xmlNodeGetAttribute ( subNode, "posX" )
				busLocations[i][is]["y"] = xmlNodeGetAttribute ( subNode, "posY" )
				busLocations[i][is]["z"] = xmlNodeGetAttribute ( subNode, "posZ" )
				busLocations[i][is]["r"] = xmlNodeGetAttribute ( subNode, "rot" )
			end
        end
        xmlUnloadFile ( XMLBusLocations )
    end
)

local rootElement = getRootElement()
local busses = { [431] = true, [437] = true }

function getNewBusLocation(thePlayer, ID)
	if #busLocations[getElementData( thePlayer, "busroute")] < ID then
		ID = 1;
		setElementData( thePlayer, "busData", 1 )
	end
	local x,y,z = busLocations[getElementData( thePlayer, "busroute")][ID]["x"], 
		busLocations[getElementData( thePlayer, "busroute")][ID]["y"], 
		busLocations[getElementData( thePlayer, "busroute")][ID]["z"]
	triggerClientEvent( thePlayer, "bus_set_location", thePlayer, x, y, z )
	local distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(thePlayer));
	local deadline = calculateDeadline(distance);	
	triggerClientEvent (thePlayer, "busdriver.onstart", thePlayer, deadline*60*1000);
	return x, y, z
end
function onVehicleEnter(thePlayer, seat, jacked)
	if isElement( thePlayer ) then
		if getElementType( thePlayer ) == "player" and getElementData(thePlayer, "inmission") == "Otobüs Şoförü" then
			if seat == 0 and busses[getElementModel( source )] then
				local x,y,z = 0,0,0
				setElementData( thePlayer, "busroute", math.random( #busLocations ))
				if not getElementData( thePlayer, "busData" ) then
					x,y,z = getNewBusLocation( thePlayer, 1 )
					setElementData( thePlayer, "busData", 1 )
				else
					x,y,z = getNewBusLocation( thePlayer, getElementData( thePlayer, "busData" ))
				end
				outputChatBox( "Otobüsü ilk durağa götür.", thePlayer, 0, 255, 0 )
			end
		end
	end
end
addEventHandler( "onVehicleEnter", rootElement, onVehicleEnter )

addEvent("bus_finish",true)
addEventHandler("bus_finish",rootElement,
function()
	if not isPedInVehicle(client) then return end
	if not busses[getElementModel(getPedOccupiedVehicle(client))] then return end
	local money = math.random(125, 900);
	local fine = math.floor(money - (money*(1-(getElementHealth(getPedOccupiedVehicle( client ))/1000))))
	exports.database:givePlayerMoney(client,fine,"Mission: Otobüs Şoförü")
	if (money - fine) > 0 then
		exports.database:takePlayerMoney ( client, (money - fine), "Mission: Otobüs Şoförü" )
		if (money - fine) > 20 then
			outputChatBox( tostring(money - fine).."₺ otobüs hasarından dolayı kesildi!", client, 255, 0, 0 )
		end
	end
	if #busLocations[getElementData( client, "busroute")] == tonumber(getElementData(client,"busData")) then
		setElementData( client, "busData", 1 )
	else
		setElementData(client, "busData", tonumber( getElementData( client, "busData" ))+1 )
	end
	getNewBusLocation( client, tonumber( getElementData( client, "busData" )))
end)

addEvent ("onPlayerJoinMission");
addEventHandler ("onPlayerJoinMission", root,
	function (mission)
		if mission == "Otobüs Şoförü" then 
			local vehicle = exports.mtatr_civ:createVehicle(431, 2258.37, 2055.82, 10.82, 0, 0, 180);
			exports.mtatr_civ:assignPlayerVehicle(source, vehicle, true);
			setElementModel(source, 253);
			warpPedIntoVehicle(source, vehicle);
		end
	end
);	

addEvent ("onPlayerLeaveMission");
addEventHandler ("onPlayerLeaveMission", root, 
	function(mission)
		if mission == "Otobüs Şoförü" then 
			triggerClientEvent (source, "busdriver.onstop", source);
		end
	end
);	

addEvent ("busdriver.elapsed", true);
addEventHandler ("busdriver.elapsed", root, 
	function ()
		exports.mtatr_civ:setPlayerMission (client, nil, "Süre doldu.");
	end
);	

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function calculateDeadline (distance)
	return math.round((distance/MAIN_VELOCITY)/10, 2);
end	