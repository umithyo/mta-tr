--[[

<°))><

Public Services - Interiors
(c) 2008 mabako network. All Rights reserved.

]]

local _local = getLocalPlayer()
local markers = { }
local markerFromCol = { }

function recieveServicesInteriorMarkers( x,y,z,marker_type,i,d )
	local num = #markers+1

	markers[num] = { }
	markers[num].X = x
	markers[num].Y = y
	markers[num].Z = z + 2.0
	markers[num].MType = marker_type
	markers[num].Marker = nil
	markers[num].Dimension = d
	markers[num].Blip = nil
	
	createBlip( markers[num].X, markers[num].Y, markers[num].Z, markers[num].MType, 1, 255, 255, 255, 255, 0, 600);
	
	markers[num].Col = createColTube ( x, y, z-100, 600, z+100 )
	setElementInterior( markers[num].Col, i )
	if( d ~= -1 ) then
		setElementDimension( markers[num].Col, d )
	end
	markerFromCol[ markers[num].Col ] = num
	
	addEventHandler( "onClientColShapeHit", markers[num].Col, onClientColShapeHit )
	addEventHandler( "onClientColShapeLeave", markers[num].Col, onClientColShapeLeave )
end

function onClientColShapeHit( hitElement, matching_dimension )
	if( hitElement ~= _local ) then return end
	
	local num = markerFromCol[ source ]
	if( num == nil ) then return end
	if( markers[num].Dimension >= 0 ) then
		matching_dimension = true
		setElementDimension( source, getElementDimension( _local ) )
	end
	
	if( not matching_dimension ) then return end

	if( markers[num].Blip == nil and markers[num].MType ~= nil ) then
		-- markers[num].Blip = createBlip( markers[num].X, markers[num].Y, markers[num].Z, markers[num].MType, 1, 255, 255, 255, 255 )
		-- setElementParent( markers[num].Blip, markers[num].Col )
		-- setElementDimension( markers[num].Blip, getElementDimension( _local ) )
	end
	if( markers[num].Marker == nil ) then
		markers[num].Marker = createMarker( markers[num].X, markers[num].Y, markers[num].Z, "arrow", 2, 120, 255, 255, 200 )
		setElementParent( markers[num].Marker, markers[num].Col )
		setElementDimension( markers[num].Marker, getElementDimension( _local ) )
	end
end

function onClientColShapeLeave( hitElement, matching_dimension )
	if( hitElement ~= _local ) then return end
	
	local num = markerFromCol[ source ]
	if( num == nil ) then return end
	if( markers[num].Blip ~= nil and markers[num].MType ~= nil ) then
		destroyElement( markers[num].Blip )
		markers[num].Blip = nil
	end
	if( markers[num].Marker ~= nil ) then
		destroyElement( markers[num].Marker )
		markers[num].Marker = nil
	end
end


function onClientResourceStart( )
	setTimer( triggerServerEvent, 2500, 1, "requestServicesInteriorMarkers", _local )
end

addEvent( "recieveServicesInteriorMarkers", true )
addEventHandler( "recieveServicesInteriorMarkers", getRootElement(), recieveServicesInteriorMarkers )
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), onClientResourceStart)

addCommandHandler("mabako-services", function() 
	outputChatBox( "mabako-services > #FFFFFFInteriors 1.0", 0, 255, 0, true )
end, false )