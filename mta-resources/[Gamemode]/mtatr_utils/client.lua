local player = localPlayer
addCommandHandler ("getpos",
	function(cmd, t)
		local posx,posy,posz = getElementPosition (localPlayer)
		local x,y,z = math.round (posx,2), math.round(posy,2), math.round(posz,2)
		local _, _, rot = getElementRotation(localPlayer)
		
		local pos = ("{"..x..", "..y..", "..z.."}")
		if t then 
			pos = ("{"..x..", "..y..", "..z..", "..math.round (rot, 2).. "}")
		end	
		if setClipboard (pos..",") then
			
			outputChatBox (pos.. " (sent to clipboard)".. " rot: "..math.round (rot, 2))
		end	
	end
)	
	
function outputCameraMatrix ()
	local x, y, z = player:getPosition()
	local a, b, c, d, e, f = getCameraMatrix()
	local a, b, c, d, e, f = math.round(a), math.round(b, 2), math.round(c, 2), math.round(d, 2), math.round(e, 2), math.round(f, 2)
	local s = ", "
	local matrix = a .. s .. b .. s .. c .. s .. d .. s .. e .. s .. f
	if setClipboard (matrix) then
		outputChatBox(getZoneName(x, y, z) ..", ".. matrix ..(" (sent to clipboard)") )
	end	
end
addCommandHandler("cameramatrix", outputCameraMatrix)
addCommandHandler("cmatrix", outputCameraMatrix)
addCommandHandler("cm", outputCameraMatrix)