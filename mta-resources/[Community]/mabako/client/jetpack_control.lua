--[[

<°))><

Public Services - Jetpack Control
Copyright (c) 2008 mabako network. All Rights reserved.

]]

local jMenu = nil
local jImage = nil
local jBar = nil
local jText = nil
local _local = getLocalPlayer()
local x, y = guiGetScreenSize()
local jetpackVeloMultiplier = 10
local jetpackMaxFuel = 1000

function toggleJetpackWindow( state )
	if( not getElementData( _local, "jetpackFuel" ) ) then
		guiSetVisible( jMenu, false )
		guiSetVisible( jImage, false )
		guiSetVisible( jBar, false )
		guiSetVisible( jText, false )
	elseif( tonumber( getElementData( _local, "jetpackFuel" ) ) > 0 ) then
		guiSetVisible( jMenu, state )
		guiSetVisible( jImage, state )
		guiSetVisible( jBar, state )
		guiSetVisible( jText, state )
	else
		guiSetVisible( jMenu, false )
		guiSetVisible( jImage, false )
		guiSetVisible( jBar, false )
		guiSetVisible( jText, false )
	end
end

function updateFuel( )
	if( not getElementData( _local, "jetpackFuel" ) ) then return end

	local currentFuel = tonumber( getElementData( _local, "jetpackFuel" ) )
	if( (getElementInterior( _local ) > 0 and guiGetVisible( jMenu ) ) or currentFuel == 0 ) then
		toggleJetpackWindow( false )
	elseif( getElementInterior( _local ) == 0 and not guiGetVisible( jMenu ) ) then
		toggleJetpackWindow( true )
	end

	if( doesPedHaveJetPack( _local ) ) then
		if( not isPedOnGround( _local ))  then
			if( currentFuel > 0 ) then
				local veloX, veloY, veloZ = getElementVelocity( _local )
				if( not veloX ) then return end
				if( veloZ < 0 ) then veloZ = 0 end -- literally going down is ignored, since you dont need fuel for that

				currentFuel = currentFuel - getDistanceBetweenPoints3D( veloX, veloY, veloZ, 0, 0, 0 ) * jetpackVeloMultiplier

				if( currentFuel < 1 ) then currentFuel = 0 end

				if( currentFuel == 0 ) then
					-- down, down, down
					toggleControl( "sprint", false )
					setPedControlState( localPlayer, "jump", true )

					outputChatBox( "Your JetPack ran out of fuel!", 255, 255, 0 )
				end

				setElementData( _local, "jetpackFuel", currentFuel )
			end
		else
			if( currentFuel == 0 ) then
				triggerServerEvent( "forceJetpackRemove", _local )
			end
		end
	end

	local shownValue = math.floor(currentFuel/jetpackMaxFuel*100)
	if( guiGetText( jText ) ~= shownValue .. "%" ) then
		guiProgressBarSetProgress( jBar, shownValue )
		guiSetText( jText, shownValue .. "%" )
	end
end

function onClientResourceStart( )
	jMenu = guiCreateWindow( x - 130, y - 140, 120, 120, "Jetpack      ", false ) -- Titles are NOT in the center
	guiWindowSetMovable( jMenu, false )
	guiWindowSetSizable( jMenu, false )

	jImage = guiCreateStaticImage( x - 102, y - 125, 64, 64, "images/ammu/JETPACK.png", false, nil )
	jBar = guiCreateProgressBar( x - 125, y - 58, 100, 10, false, nil )
	jText = guiCreateLabel( x - 125, y - 45, 100, 15, "", false )
	guiLabelSetVerticalAlign( jText, "center" )
	guiLabelSetHorizontalAlign( jText, "center" )

	if( not getElementData( _local, "jetpackFuel" ) ) then
		toggleJetpackWindow( false )
	elseif( tonumber( getElementData( _local, "jetpackFuel" ) ) < 1 ) then
		toggleJetpackWindow( false )
	elseif( getElementInterior( _local ) == 0 )  then
		toggleJetpackWindow( true )
	else
		toggleJetpackWindow( false )
	end

	setTimer( updateFuel, 2000, 0 )
end

function onClientResourceStop( )
	guiSetVisible( jMenu, false )
	destroyElement( jMenu )
end


addEvent( "changeJetpackOptions", true )
addEventHandler( "changeJetpackOptions", getRootElement(), function( a, b )
		jetpackVeloMultiplier = a
		jetpackMaxFuel = b
	end
)
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), onClientResourceStart)
addEventHandler( "onClientResourceStop", getResourceRootElement(getThisResource()), onClientResourceStop)

addEventHandler( "onClientGUIClick", getResourceRootElement(getThisResource()), function()
	if( source == jMenu ) then
		guiBringToFront( jImage )
		guiBringToFront( jBar )
		guiBringToFront( jText )
	end
end)

addCommandHandler("mabako-services", function()
	outputChatBox( "mabako-services > #FFFFFFJetpacks 1.0", 0, 255, 0, true )
end, false )
