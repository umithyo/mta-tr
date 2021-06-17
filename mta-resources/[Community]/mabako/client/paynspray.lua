--[[

<°))><

Public Services - Pay'N'Spray
(c) 2008 mabako network. All Rights reserved.

]]

local cols = { }
local checkTimer = nil
local _local = getLocalPlayer()
local isLocalCol = {}


function isPositionInColShape( colsh, x0, y0, z0, x1, y1, z1 )
	for v = 1,#cols,1 do
		if( cols[v].Col == colsh ) then

			if( x0 >= cols[v].A
				and y0 >= cols[v].B
				and z0 >= cols[v].C
				and x1 <= cols[v].A+cols[v].D 
				and y1 <= cols[v].B+cols[v].E
				and z1 <= cols[v].C+cols[v].F )
			then
				return true
			end
			
		end
	end
	return false
end

function PayNSprayCheck( colsh )
	local vehicle = getPedOccupiedVehicle ( _local )
	if( not vehicle ) then return end
	if( getVehicleController( vehicle ) ~= _local ) then return end
	
	if( getElementHealth( vehicle ) == 1000 ) then return end
	
	local g,h,i = getElementVelocity ( vehicle )
	if( g ~= 0 or h ~= 0 or i ~= 0 ) then return end
	
	local a,b,c,d,e,f = getElementBoundingBox( vehicle )
	local x,y,z = getElementPosition( vehicle )
	if( isPositionInColShape( colsh, x+a,y+b,z,x+d,y+e,z+f ) ) then
		if( checkTimer ) then
			triggerServerEvent( "requestRespray", _local )
			killTimer( checkTimer )
			checkTimer = nil
		end
	end
end


function onClientColShapeHitY( element, dimension )
	if( element ~= _local ) then return end
	if( not isLocalCol[ source ] ) then return end

	if( checkTimer ) then
		killTimer( checkTimer )
	end
	checkTimer = setTimer( PayNSprayCheck, 200, 0, source )
end

function onClientColShapeLeaveY( element, dimension )
	if( element ~= _local ) then return end
	if( not isLocalCol[ element ] ) then return end
	if( checkTimer ) then
		killTimer( checkTimer )
	end
	checkTimer = nil
end

function recieveServicesColShapes( a, b, c, d, e, f )
	local num = #cols+1

	cols[num] = { }
	cols[num].Col = createColCuboid( a, b, c, d, e, f )
	cols[num].Blip = nil
	cols[num].A = a
	cols[num].B = b
	cols[num].C = c
	cols[num].D = d
	cols[num].E = e
	cols[num].F = f
	
	isLocalCol[ cols[num].Col ] = 1
	
	addEventHandler( "onClientColShapeHit", cols[num].Col, onClientColShapeHitY )
	addEventHandler( "onClientColShapeLeave", cols[num].Col, onClientColShapeLeaveY )
end

function checkBlipStreamInOut( )
	local x,y,z = getElementPosition( _local )
	for v = 1,#cols,1 do
		if( getDistanceBetweenPoints2D( x, y, cols[v].A+cols[v].D/2, cols[v].B+cols[v].E/2 ) > 250 ) then
			if( cols[v].Blip ~= nil ) then
				destroyElement( cols[v].Blip )
				cols[v].Blip = nil
			end
		else
			if( cols[v].Blip == nil ) then
				cols[v].Blip = createBlip ( cols[v].A+cols[v].D/2, cols[v].B+cols[v].E/2, cols[v].C, 63, 2, 255, 255, 255, 255 )
			end
		end
	end
end

function onClientResourceStart( )
	setTimer( triggerServerEvent, 2500, 1, "requestServicesColShapes", _local )
	setTimer( checkBlipStreamInOut, 500, 0 )
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), onClientResourceStart)
addEvent("recieveServicesColShapes", true)
addEventHandler("recieveServicesColShapes", getRootElement(), recieveServicesColShapes)

addCommandHandler("mabako-services", function() 
	outputChatBox( "mabako-services > #FFFFFFPay'N'Sprays 1.2", 0, 255, 0, true )
end, false )