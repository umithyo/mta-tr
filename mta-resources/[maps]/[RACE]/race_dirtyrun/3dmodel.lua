local objects = getElementsByType ( "object", resourceRoot ) 
for theKey,object in ipairs(objects) do 
	local id = getElementModel(object)
	local x,y,z = getElementPosition(object)
	local rx,ry,rz = getElementRotation(object)
	local scale = getObjectScale(object)
	objLowLOD = createObject ( id, x,y,z,rx,ry,rz,true )
	setObjectScale(objLowLOD, scale)
	setLowLODElement ( object, objLowLOD )
	engineSetModelLODDistance ( id, 3000 )
	setElementStreamable ( object , false)
end
