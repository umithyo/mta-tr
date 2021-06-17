addEvent ("onClientPlayerChangeGamemode", true);
addEventHandler ("onClientPlayerChangeGamemode", root,
	function (mode)
		if mode == "TDM" then 
			guiSetVisible(duel.window[1], true);
			showCursor(true);
			exports.mtatr_civ:toggleHUD(false);
		end
	end
);	

addEvent ("onClientPlayerRequestPVPList", true);
addEventHandler ("onClientPlayerRequestPVPList", root,
	function(list)
		if list then 
			rooms=list;
			buildRooms(rooms);
			if guiGetVisible(duel.window[2]) then 
				loadGrid(duel.gridlist[3], current);
			end	
		end	
	end
);	

addEvent ("onClientPlayerLeaveGamemode", true);
addEventHandler("onClientPlayerLeaveGamemode", root, 
	function ()
		current=nil;
		rooms={};
		players={};
		for _, wnd in pairs (duel.window) do 
			wnd:setVisible(false);
		end
		showCursor(false);
		setCameraInterior(0);
	end
);	

addEvent ("onClientPlayerJoinRoom", true);
addEventHandler ("onClientPlayerJoinRoom", root,
	function (room, isStarter)
		buildRoom(room, isStarter);
		current = room;
		local id;
		for i, v in ipairs (rooms) do 
			if v.id == room then 
				id=i
			end
		end
		local map=rooms[id].map;
		local type = rooms[id].type;
		if not map then return; end		
		local angle;
		local int;
		if type == "PVP" then 
			angle=PVP_MAP[map].angle;
			int=PVP_MAP[map].int or 0;
		else
			angle=TDM_MAP[map].angle;
			int=TDM_MAP[map].int or 0;
		end	
		if angle then
			setCameraInterior(int)
			setCameraMatrix(unpack(angle));
		end
	end
);

addEvent ("onClientPlayerLeaveRoom", true);
addEventHandler ("onClientPlayerLeaveRoom", root, 
	function ()
		current= nil;
		if guiGetVisible(duel.window[2]) then
			duel.window[2]:setVisible(false);
		end	
	end
);	

addEvent ("onClientPlayerStartDuelling", true);
addEventHandler ("onClientPlayerStartDuelling", root, 
	function ()
		for _, wnd in pairs (duel.window) do 
			wnd:setVisible(false);
		end
		showCursor(false);
	end
);	