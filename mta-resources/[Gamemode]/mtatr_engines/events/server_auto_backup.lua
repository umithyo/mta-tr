local events = {
	{
		message  		= {msg = "Ya başkanı öldür ya da koru... Tarafını seç!", color = {200, 254, 46}},
		prefix			= "ptp", -- FOR MAPPING
		friendly_name 	= "PTP",
		name     		= "Protect The President",
		resource 		= "mtatr_ptp",
		start    		= "startEvent",
		stop 			= "stopEvent",
		details			= "getMapDetails",
		timeout 		= 20,
		args	 		= {},
		repetitive 		= true,
	},
};

function getEventProperty (event, key)
	for i, v in ipairs (events) do
		if v.prefix == event then
			return v[key];
		end
	end
	return false;
end

function getEventId (event)
	for i, v in ipairs (events) do
		if v.prefix == event then
			return i;
		end
	end
	return false;
end

local events_notificate = 3;
local events_index	    = 1;
local events_timeout    = 30;
local events_timeleft   = nil;
local events_info	    = {};
local event_active 		= false;
local event_min_players = 1;
local notificated		= {};

local function event_inc ()
	events_index = events_index + 1;
	if not events[events_index] then
		events_index = 1;
	end
end

local function event_start (event)
	for i, v in pairs (events_info) do
		if isTimer (v) then
			killTimer (v);
		end
	end

	for i, v in ipairs (getElementsByType"player") do
		exports.mtatr_play:disableSpawnFor (v, false);
	end

	event_active 	= false;
	events_timeleft = Timer (
		function ()
			event_inc ();
			events_cycle ();
		end,
	events_timeout * 60 * 1000, 1);
end
addEvent ("onEventFinished");
addEventHandler ("onEventFinished", root, event_start);

function events_cycle ()
	local situation = #getElementsByType"player" >= event_min_players;
	if situation then
		notificated = {};
		if eventName == "onResourceStart" then
			local time = 3000;
			setTimer (events_cycle, time, 1);
			return
		end
		local current  = events[events_index];
		local message  = current.message.msg;
		local color    = current.message.color;
		local name	   = current.name;
		local resource = getResourceFromName (current.resource);
		local start	   = current.start;
		local stop 	   = current.stop;
		local timeout  = current.timeout;
		local args	   = current.args;
		local details  = current.details;
		local rep	   = current.repetitive;

		call (resource, start, unpack (args));

		local r, g, b = unpack(color);
		output (name.. "\netkinliği başladı!", call (resource, details).."\n"..message, root, r, g, b);
		outputChatBox ("#ffffff/eventgir "..exports.mtatr_utils:RGBToHex (r, g, b).."yazarak katılabilirsiniz!", root, r, g, b, true);

		event_active = name;
	end
end
addEventHandler ("onResourceStart", resourceRoot, events_cycle);

addEventHandler ("onResourceStop", root,
	function (res)
		for i, v in ipairs (events) do
			if res == getResourceFromName (v.resource) then
				event_start ();
			end
		end
	end
);

addEvent ("onEventRun");
addEventHandler ("onEventRun", root,
	function (event)
		local _index 	= getEventId (event);
		local current 	= events[_index];
		local resource 	= getResourceFromName (current.resource);
		local stop 	  	= current.stop;
		local timeout  	= current.timeout;
		events_info[_index] = setTimer (
			function (ind)
				call (resource, stop);
				events_info[ind] = nil;
			end,
		timeout * 60 * 1000, 1, _index);
	end
);

function getEventTimerDetails (event)
	local id = getEventId (event);
	local timer = events_info [id];
	if timer and isTimer (timer) then
		return getTimerDetails (timer);
	end
	return false;
end

function canPlayerJoinEvent (player)
	local cond, err, _type = exports[events[events_index].resource]:canPlayerJoinEvent(player);
	if not cond then
		return false, err, _type;
	end
	if exports.mtatr_deathmatches:isPlayerInDeathmatch (player) then
		return false, "Evente girmek için deathmatchten çıkmanız gerekiyor.";
	end
	if not exports.mtatr_accounts:isPlayerInGame (player) then
		return false, "Evente girmek için oyunda olmanız gerekiyor.", "dm";
	end
	if player:getDimension() ~= 0 or player:getInterior() ~= 0 then
		return false, "Evente girmek için dışarıda olmanız gerekiyor.", "dm";
	end
	return true;
end

addCommandHandler ("eventgir",
	function (player)
		if not event_active then
			if isTimer (events_timeleft) then
				local time = exports.mtatr_utils:totime (getTimerDetails (events_timeleft)/1000);
				local event = events_index + 1;
				if not events [event] then
					event = 1;
				end
				local eventName = events[event].name;
				local r, g, b   = unpack (events[event].message.color);
				outputChatBox ("Şuanda hiçbir etkinlik yok.", player, 255, 225, 2);
				outputChatBox (eventName..", "..time.. " dakika içinde başlayacak!", player, r, g, b);
			end
			return;
		end
		local canhe, err, _type = canPlayerJoinEvent (player);
		if not canhe then
			if _type == "dm" then
				exports.mtatr_hud:dm (err, player, 255, 0, 0);
			else
				outputChatBox (err, player, 255, 0, 0);
			end
			return;
		end
		exports[events[events_index].resource]:joinEvent(player);
		if events[events_index].repetitive then
			exports.mtatr_play:disableSpawnFor (player, true);
		end
	end
);

setTimer (
	function ()
		if isTimer (events_timeleft) then
			local time = getTimerDetails (events_timeleft);
			if time <= events_notificate * 60 * 1000 then
				local event = events_index + 1;
				if not events [event] then
					event = 1;
				end
				local eventName = events[event].name;
				local r, g, b   = unpack (events[event].message.color);
				for i, v in ipairs (getElementsByType"player") do
					if not notificated[v] then
						outputChatBox ("Yaklaşan etkinlik: ".. eventName.. " ("..events_notificate.." dakika)", v, r, g, b);
						notificated[v] = true;
					end
				end
			end
		end
	end,
1000, 0);

addEvent ("onPlayerCoreLogin");
addEventHandler ("onPlayerCoreLogin", root,
	function()
		if event_active then
			local cond = canPlayerJoinEvent (source);
			if cond then
				outputChatBox (event_active.. " etkinliği şuan aktif! ffffff/joinevent #ffff00 yazıp girebilirsiniz.", source, 255, 225, 2, true);
			end
		end
	end
);

--SETTINGS--
function getResourceSettings ( resource )
	if ( not resource ) then
		return false
	end

    local settingsTable = { }
    local name          = getResourceName ( resource )
    local meta          = xmlLoadFile     ( ":".. name .."/meta.xml" )
	if ( not meta ) then
		return false
	end

    local settings      = xmlFindChild    ( meta, "settings", 0 )
    if ( settings ) then
        for _, setting in ipairs ( xmlNodeGetChildren ( settings ) ) do
            local oldName      = xmlNodeGetAttribute ( setting, "name" )
            local temp         = string.gsub ( oldName, '[%*%#%@](.*)','%1' )
			temp 			   = string.gsub ( temp, name ..'%.(.*)','%1' )
			if not settingsTable[temp] then
				settingsTable[temp] = {};
			end
            settingsTable[temp] = {
				value 		= xmlNodeGetAttribute ( setting, "value" ),
				friendly	= xmlNodeGetAttribute ( setting, "friendlyname" ),
				accept		= xmlNodeGetAttribute ( setting, "accept" ),
				desc		= xmlNodeGetAttribute ( setting, "desc" ),
				group		= xmlNodeGetAttribute ( setting, "group" )
			};
		end
    end

    xmlUnloadFile ( meta )
    return settingsTable
end
