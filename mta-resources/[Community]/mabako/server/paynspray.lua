--[[

<°))><

Public Services - Pay'N'Spray
(c) 2008 mabako network. All Rights reserved.

]]

function givePlayerMoney (...)
	return exports.database:givePlayerMoney (...);
end

function takePlayerMoney (...)
	return exports.database:takePlayerMoney (...);
end	

function setPlayerMoney (...)
	return exports.database:setPlayerMoney (...);
end	

_giveWeapon=giveWeapon;
function giveWeapon(...)
	local args = {...};
	local player = args[1];
	_giveWeapon(...);
	exports.mtatr_accounts:saveWeapons(player);
end	

local paynsprayCosts = get( "PayNSprayCosts" )
local disallowedVehicles = get("DisallowedVehicles")
local vehicleColors = { }

local paynsprays = { }

function fileReadLine( file )
	local buffer = ""
	local tmp
	repeat
		tmp = fileRead( file, 1 ) or nil
		if tmp and tmp ~= "\r" and tmp ~= "\n" then
			buffer = buffer .. tmp
		end
	until not tmp or tmp == "\n" or tmp == ""
	
	return buffer
end

function onResourceStart(res)
	-- load the Garages...
	local garageElements = getElementsByType ( "garage", getResourceRootElement(res) )
	
	for k,v in ipairs(garageElements) do
		local garage_type = tonumber( getElementData( v, "garageType" ) )
		if( garage_type == 5 ) then -- 5 = Pay'N'Sprays
			local num = #paynsprays+1
			paynsprays[num] = { }
			paynsprays[num].Name = getElementData( v, "name" )
			paynsprays[num].lowerLeftFrontX = tonumber( getElementData( v, "lowerLeftFrontX" ) )
			paynsprays[num].lowerLeftFrontY = tonumber( getElementData( v, "lowerLeftFrontY" ) )
			paynsprays[num].lowerLeftFrontZ = tonumber( getElementData( v, "lowerLeftFrontZ" ) )
			paynsprays[num].lowerRightFrontX = tonumber( getElementData( v, "lowerRightFrontX" ) )
			paynsprays[num].lowerRightFrontY = tonumber( getElementData( v, "lowerRightFrontY" ) )
			paynsprays[num].upperLeftRearX = tonumber( getElementData( v, "upperLeftRearX" ) )
			paynsprays[num].upperLeftRearY = tonumber( getElementData( v, "upperLeftRearY" ) )
			paynsprays[num].upperLeftRearZ = tonumber( getElementData( v, "upperLeftRearZ" ) )
			
			paynsprays[num].smallestX = math.min( paynsprays[num].lowerLeftFrontX, paynsprays[num].lowerRightFrontX, paynsprays[num].upperLeftRearX )
			paynsprays[num].width = math.max( paynsprays[num].lowerLeftFrontX, paynsprays[num].lowerRightFrontX, paynsprays[num].upperLeftRearX ) - paynsprays[num].smallestX
			
			paynsprays[num].smallestY = math.min( paynsprays[num].lowerLeftFrontY, paynsprays[num].lowerRightFrontY, paynsprays[num].upperLeftRearY )
			paynsprays[num].depth = math.max( paynsprays[num].lowerLeftFrontY, paynsprays[num].lowerRightFrontY, paynsprays[num].upperLeftRearY ) - paynsprays[num].smallestY
			
			paynsprays[num].smallestZ = math.min( paynsprays[num].lowerLeftFrontZ, paynsprays[num].upperLeftRearZ )
			paynsprays[num].height = math.max( paynsprays[num].lowerLeftFrontZ, paynsprays[num].upperLeftRearZ ) - paynsprays[num].smallestZ
		end
	end
	
	-- We need a list of random colors to assign, so let's have a look at the server's vehiclecolors.conf
	local file = fileOpen( "data/vehiclecolors.conf", true )
	while not fileIsEOF( file ) do
		local line = fileReadLine( file )
		if #line > 0 and line:sub( 1, 1 ) ~= "#" then
			local model = tonumber( gettok( line, 1, string.byte(' ') ) )
			if not vehicleColors[ model ] then
				vehicleColors[ model ] = { }
			end
			vehicleColors[ model ][ #vehicleColors[ model ] + 1 ] = {
				tonumber( gettok( line, 2, string.byte(' ') ) ),
				tonumber( gettok( line, 3, string.byte(' ') ) ) or nil,
				tonumber( gettok( line, 4, string.byte(' ') ) ) or nil,
				tonumber( gettok( line, 5, string.byte(' ') ) ) or nil
			}
		end
	end
	fileClose( file )
end

addEventHandler( "onResourceStart", getResourceRootElement(getThisResource()), onResourceStart)


function requestServicesColShapes( )
	for num = 1,#paynsprays,1 do
		triggerClientEvent( source, "recieveServicesColShapes", source, paynsprays[num].smallestX, paynsprays[num].smallestY, paynsprays[num].smallestZ, paynsprays[num].width, paynsprays[num].depth, paynsprays[num].height )
	end
end

addEvent( "onPayNSpray", false )
addEvent( "onPayNSprayFix", false )
function requestRespray() 
	if( getPlayerMoney( source ) >= paynsprayCosts ) then
		local EventCanceled = false
		local vehicle = getPedOccupiedVehicle ( source )
		
		-- you can use cancelEvent() to cancel this.
		EventCanceled = triggerEvent ( "onPayNSpray", getRootElement(), vehicle, source )
		if( EventCanceled == false ) then return end

		
		for v = 1,#disallowedVehicles,1 do
			if( disallowedVehicles[v] == getElementModel( vehicle ) ) then 
				outputChatBox( "I don't touch that shit!", source, 255, 255, 0 )
				return 
			end
		end

		local bWasDamaged = getElementHealth(vehicle) < 1000
		
		toggleAllControls( source, false, true, true )
		setElementHealth( vehicle, 1000 ) -- prevent the car from "accidently" exploding before we resprayed
		fadeCamera(source, false, 1 )
		
		setTimer( function (s,v) 
			takePlayerMoney( s, paynsprayCosts, "Pay n Spray" )
			

			fixVehicle( v )
			
			local a, b, c, d = getVehicleColor( v )
			local model = getElementModel( v )
			if vehicleColors[ model ] then
				local newColorSet = { }
				if #vehicleColors[ model ] > 1 then
					repeat
						newColorSet = vehicleColors[ model ][ math.random( 1, #vehicleColors[ model ] ) ]
					until not( newColorSet[ 1 ] == a and (not newColorSet[ 2 ] or newColorSet[ 2 ] == b) and (not newColorSet[ 3 ] or newColorSet[ 3 ] == c) and (not newColorSet[ 4 ] or newColorSet[ 4 ] == d) )
				else
					newColorSet = vehicleColors[ model ][ 1 ]
				end
				
				if newColorSet[ 2 ] then b = newColorSet[ 2 ] end
				if newColorSet[ 3 ] then c = newColorSet[ 3 ] end
				if newColorSet[ 4 ] then d = newColorSet[ 4 ] end
				setVehicleColor( v, newColorSet[ 1 ], b, c, d )
			end
			
			fadeCamera(s, true, 1 )
			
			setTimer( toggleAllControls, 1000, 1, s, true, true, true )

			local action = "boyandı"
			if bWasDamaged then
				action = "tamir edildi ve " .. action
			end
			
			outputChatBox( "Aracın " .. action .. "! Fiyat: $" .. paynsprayCosts .. ".", s, 0, 255, 0 )
			triggerEvent( "onPayNSprayFix", getRootElement(), v, s )
			
			end, 1000, 1, source, vehicle )
	else
		outputChatBox( "Yeterli paran yok! ($" .. paynsprayCosts .. ")", source, 255, 255, 0 )
	end
end

addEvent("requestServicesColShapes", true)
addEventHandler( "requestServicesColShapes", getRootElement(), requestServicesColShapes)
addEvent("requestRespray", true)
addEventHandler( "requestRespray", getRootElement(), requestRespray )
