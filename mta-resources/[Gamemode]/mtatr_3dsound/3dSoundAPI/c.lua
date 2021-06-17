addEvent("core:onServerRequest3DSound", true);

function create3DSound ( ... )
	local x, y, z, path, owner, looped, distance, dim, int = unpack(arg);
	local clientSound3D = playSound3D (path, x, y, z, looped);
	addEventHandler("onClientSoundStopped", clientSound3D,
		function()
			clientSound3D:destroy();
		end
	)
	setSoundMaxDistance(clientSound3D, (distance or 50));
	local dim, int = dim or 0, int or 0;
	clientSound3D:setDimension(dim);
	clientSound3D:setInterior(int);
	if (owner and isElement(owner) ) then
		attachElements(clientSound3D, owner);
		
		local function destroyCreatedSound ()
			if (isElement(clientSound3D) ) then
				clientSound3D:destroy();
			end
		end
		
		if getElementType(owner) == "player" then
			addEventHandler("onClientPlayerQuit", owner, destroyCreatedSound);
			addEventHandler("onClientElementDestroy", clientSound3D,
				function()
					removeEventHandler("onClientPlayerQuit", owner, destroyCreatedSound);
				end
			);
		else
			addEventHandler("onClientElementDestroy", owner, destroyCreatedSound);
			addEventHandler("onClientElementDestroy", clientSound3D,
				function()
					removeEventHandler("onClientElementDestroy", owner, destroyCreatedSound);				
				end
			);		
		end
	end
end
addEventHandler("core:onServerRequest3DSound", root, create3DSound);

function createShared3DSound (x, y, z, path, owner, looped, distance, dim, int)
	triggerServerEvent("core:onClientRequestGlobal3DSound", (owner or localPlayer), x, y, z, path, owner, looped, distance, dim, int) ;
end

function create3DOwnerSound (path, owner, looped, distance, dim, int)
	triggerServerEvent("core:onClientRequestGlobal3DSound", (owner or localPlayer), 0, 0, 0, path, owner, looped, distance, dim, int) ;
end