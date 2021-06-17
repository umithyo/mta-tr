local missions = {
	{
		name     = "Black Export",
		resource = "mtatr_blackexport",
		start    = "startBlackExport", 
		stop     = "stopBlackExport",
		timeout  = 6, 
		args     = {}
	},
};

local missions_info    = {};
local missions_index   = 1; 
local missions_timeout = 60;

local function mission_start (mission)
	for i, v in pairs (missions_info) do 
		if isTimer (v) then 
			killTimer (v);
		end
	end	
	Timer (
		function ()
			mission_inc ();
			missions_cycle();
		end,
	missions_timeout*60*1000, 1);
end
addEvent ("onMissionFinished");
addEventHandler ("onMissionFinished", root, mission_start);	
	
function missions_cycle ()
	for i, v in pairs (missions_info) do 
		if isTimer (v) then 
			killTimer (v);
		end
	end
	local time = 1000;
	if eventName == "onResourceStart" then 
		-- time = 10*60*1000;
	end	
	setTimer (
		function ()
			local current = missions[missions_index];
			local available = call (getResourceFromName (current.resource), current.start, unpack (current.args));
			if available then 
				local _index = missions_index;
				missions_info[missions_index] = setTimer (
					function (ind) 
						call (getResourceFromName (current.resource), current.stop);
						missions_info[ind] = nil;
					end,
				current.timeout * 60 * 1000, 1, _index);	
			else
				mission_inc();
				missions_cycle();
			end	
		end,
	time, 1);	
end
addEventHandler ("onResourceStart", resourceRoot, missions_cycle);

addEventHandler ("onResourceStop", root, 
	function (res)
		if res == getThisResource() then 
			for i, v in ipairs (missions) do
				call(getResourceFromName (v.resource), v.stop);
			end
		end	
	end
);	

function getMissionTimerDetails (mission)
	local index = table_find (missions, "name", mission);
	local timer = missions_info[index];
	if timer then 
		if isTimer (timer) then 
			return getTimerDetails (timer);
		end
	end
	return false;
end	

function mission_inc ()
	missions_index = missions_index + 1;
	if not missions[missions_index] then 
		missions_index = 1;
	end	
end	