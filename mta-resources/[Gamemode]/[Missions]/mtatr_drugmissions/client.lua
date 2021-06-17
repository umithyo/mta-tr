addEvent ("drugm.onstart", true);
addEventHandler ("drugm.onstart", root, 
	function (time)
		local x = guiGetScreenSize();
		missiontimer = exports.missiontimer:createMissionTimer (time, 0, nil, x/2, 15, true);
	end
);	

addEvent ("drugm.onstop", true);
addEventHandler ("drugm.onstop", root, 
	function ()
		if isElement (missiontimer) then 
			missiontimer:destroy();
		end	
	end
);	

addEvent ("onClientMissionTimerElapsed");
addEventHandler ("onClientMissionTimerElapsed", root, 
	function ()
		if source == missiontimer then 
			source:destroy();
			triggerServerEvent ("drugm.elapsed", localPlayer);
		end	
	end
);	

addEvent ("onClientPlayerJoinMission", true);
addEventHandler ("onClientPlayerJoinMission", root, 
	function (mission)
		if mission == "Uyuşturucu Kaçakçısı" then 
			cutscene();
		end	
	end
);	