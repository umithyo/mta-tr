--[[

<°))><

Public Services - Interiors. A lite (resource&fps-saving) interior script
(c) 2008 mabako network. All Rights reserved.

]]

local interiors = { }
local interiorFromCol = { }

function onResourceStart(res)
	local interiorEntries = getElementsByType ( "interior", getResourceRootElement(res) )
	
	for k,v in ipairs(interiorEntries) do
		
		local num = #interiors+1
		interiors[num] = { }
		interiors[num].Name = getElementData( v, "id" )
		interiors[num].GoTo = getElementData( v, "goto" )
		
		interiors[num].PosX = tonumber( getElementData( v, "posX" ) )
		interiors[num].PosY = tonumber( getElementData( v, "posY" ) )
		interiors[num].PosZ = tonumber( getElementData( v, "posZ" ) )
		interiors[num].Rotation = tonumber( getElementData( v, "rotation" ) )
		interiors[num].Interior = tonumber( getElementData( v, "interior" ) )
		interiors[num].Dimension = tonumber( getElementData( v, "dimension" ) )
		interiors[num].Marker = tonumber(  getElementData( v, "marker" ) )
		interiors[num].ToDimension = tonumber( getElementData( v, "todimension" ) )
		interiors[num].NoWeapons = tonumber( getElementData( v, "noweapons" ) )
		
		if( not interiors[num].Interior ) then interiors[num].Interior = 0 end
		if( not interiors[num].Dimension ) then interiors[num].Dimension = -1 end
		if( not interiors[num].ToDimension ) then interiors[num].ToDimension = -1 end
		
		if( interiors[num].PosX and interiors[num].PosY and interiors[num].PosZ and interiors[num].Rotation ) then
			interiors[num].Col = createColSphere ( interiors[num].PosX, interiors[num].PosY, interiors[num].PosZ, 1.5 )
			interiorFromCol[ interiors[num].Col ] = num
			
			setElementInterior ( interiors[num].Col, interiors[num].Interior )
			if( interiors[num].Dimension ~= -1 ) then
				setElementDimension ( interiors[num].Col, interiors[num].Dimension )
			end
		else
			if( interiors[num].Name ) then 
				outputDebugString( "Unable to create Interior \"" .. interiors[num].Name .. "\"" )
			else
				outputDebugString( "Unable to create Interior " .. tostring(num) )
			end
		end
	end
end

function getInteriorByName( source, name )
	for v = 1,#source,1 do
		if( source[v].Name == name ) then return v end
	end
	return false
end

function doPlayerInsideInterior( player, old, new, out )
	if( out == 1 ) then
		setElementDimension( player, interiors[new].Dimension )
	else
		setElementDimension( player, interiors[old].ToDimension )
	end
	
	setTimer ( setPlayerInsideInterior, 250, 1, player, old, new, out )
end

function setPlayerInsideInterior( player, old, new, out )

	
	setElementInterior( player, interiors[new].Interior )
	
	local x = interiors[new].PosX + 3*math.cos(math.rad(interiors[new].Rotation+90))
	local y = interiors[new].PosY + 3*math.sin(math.rad(interiors[new].Rotation+90))
	local z = interiors[new].PosZ + 1
	
	setElementPosition( player, x, y, z )
	setPedRotation( player, interiors[new].Rotation )

	toggleAllControls ( player, true )
	setTimer ( fadeCamera, 500, 1, player, true, 1.0 )
	
	if( interiors[new].NoWeapons ) then
		toggleControl( player, "fire", false )
		toggleControl( player, "aim_weapon", false )
		toggleControl( player, "next_weapon", false )
		toggleControl( player, "previous_weapon", false )
		setPedWeaponSlot( player, 0 )
		triggerClientEvent( player, "changeWeaponsEnabled", player, false )
	elseif( not interiors[new].NoWeapons and interiors[old].NoWeapons ) then
		toggleControl( player, "fire", true )
		toggleControl( player, "aim_weapon", true )
		toggleControl( player, "next_weapon", true )
		toggleControl( player, "previous_weapon", true )
		triggerClientEvent( player, "changeWeaponsEnabled", player, true )
	else
		triggerClientEvent( player, "changeWeaponsEnabled", player, true )
	end
end

function warpPlayer( player, old, new, out )
	toggleAllControls ( player, false, true, true )
	fadeCamera ( player, false, 1 )
	setTimer ( doPlayerInsideInterior, 1000, 1, player, old, new, out )
end

function onColShapeHit( hitPlayer, matching_dimension )
	if( getElementType( hitPlayer ) ~= "player" ) then return end -- not for Vehicles

	local old = interiorFromCol[ source ] -- Num is the marker the player enters
	if( not old ) then return end
	if( interiors[old].Dimension == -1 ) then
		matching_dimension = true
	end
	 
	if( 
		not matching_dimension
		or isPedInVehicle ( hitPlayer ) 
		or doesPedHaveJetPack ( hitPlayer )
		or not isPedOnGround ( hitPlayer ) 
		or getControlState ( hitPlayer, "aim_weapon" )		
	)
	then return end
	
	-- see if it's an entrance or exit marker
	if( not interiors[old].GoTo ) then -- exit
		for new = 1,#interiors,1 do 
			if( interiors[new].GoTo ) then
				if( interiors[new].GoTo == interiors[old].Name and interiors[new].ToDimension == getElementDimension( hitPlayer ) ) then
					warpPlayer( hitPlayer, old, new, 1 )
					return
				end
			end
		end
	else -- entrance
		for new = 1,#interiors,1 do 
			if( interiors[old].GoTo == interiors[new].Name ) then
				warpPlayer( hitPlayer, old, new, 0 )
				return
			end
		end
	end
end

addEventHandler( "onResourceStart", getResourceRootElement(getThisResource()), onResourceStart)
addEventHandler( "onColShapeHit", getResourceRootElement(getThisResource()), onColShapeHit )

function requestServicesInteriorMarkers( )
	for num = 1,#interiors,1 do
		triggerClientEvent( source, "recieveServicesInteriorMarkers", source, interiors[num].PosX, interiors[num].PosY, interiors[num].PosZ, interiors[num].Marker, interiors[num].Interior, interiors[num].Dimension )
	end
end

addEvent( "requestServicesInteriorMarkers", true )
addEventHandler( "requestServicesInteriorMarkers", getRootElement(), requestServicesInteriorMarkers )
