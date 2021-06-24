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
	{
		name 			= "Yarış",
		friendly_name 	= "Race",
		prefix 			= "race",
		map_prefix		= "race_",
		resource		= "mtatr_race",
		message 		= {msg= "Bayrağa ulaş, yarışı kazan!", color = {237, 172, 17}},
		start			= "startEvent",
		run				= "runEvent",
		stop			= "stopEvent",
		details 		= "getMapDetails",
		timeout 		= 20,
		args 			= {},
		repetitive 		= false,
	},
	{
		name 			= "TDM",
		prefix 			= "tdm",
		map_prefix		= "arena_",
		resource		= "mtatr_tdmevent",
		message 		= {msg= "Karşı takımı temizle, etkinliği kazan!", color = {200, 19, 19}},
		start			= "startEvent",
		stop			= "stopEvent",
		run				= "runEvent",
		details 		= "getMapDetails",
		timeout 		= 10,
		args 			= {},
		repetitive 		= false,
	},
	-- {
		-- name 			=
		-- prefix 			=
		-- resource		=
		-- message 		= {msg= , color = {}},
		-- start			=
		-- stop			=
		-- details 		=
		-- timeout 		=
		-- args 			= {},
		-- repetitive 		=
	-- },
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

function getEventIdFromName(name)
	for i, v in ipairs (events) do
		if v.name == name then
			return i;
		end
	end
	return false;
end

local events_index	    = 1;
local events_timeleft   = nil;
local events_info	    = {};
local event_active 		= false;
local event_min_players = 1;

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
	event_inc ();
	event_active 	= false;
	triggerLatentClientEvent (root, "events.getevents", resourceRoot, getEvents(), event_active);
	setGameType"GÜNLÜK ETKİNLİKLER GÖREVLER VE DAHA FAZLASI";
end
addEvent ("onEventFinished");
addEventHandler ("onEventFinished", root, event_start);

function cycleEvent (event, ...)
	if event_active then
		stopEvent (event_active);
	end
	local situation = #getElementsByType"player" >= event_min_players;
	if situation then
		notificated = {};
		if eventName == "onResourceStart" then
			local time = 3000;
			setTimer (cycleEvent, time, 1);
			return
		end
		if getEventIdFromName (event) then
			events_index = getEventIdFromName (event);
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

		call (resource, start, ...);

		setGameType ("Event: "..name);

		local r, g, b = unpack(color);
		output (name.. "\netkinliği başladı!", call (resource, details).."\n"..message, root, r, g, b);
		outputChatBox ("#ffffff/eventgir "..exports.mtatr_utils:RGBToHex (r, g, b).."yazarak katılabilirsiniz!", root, r, g, b, true);

		event_active = name;

		triggerLatentClientEvent (root, "events.getevents", resourceRoot, getEvents(), event_active);
	end
end
-- addEventHandler ("onResourceStart", resourceRoot, events_cycle);

function stopEvent (event)
	local event = event;
	if not getEventIdFromName (event) then
		return false, "Geçersiz işlem. Lütfen durdurmak istediğiniz eventi seçiniz.";
	end
	local _index 	= getEventIdFromName (event);
	local current  	= events[_index];
	local resource 	= getResourceFromName (current.resource);
	local stop 	  	= current.stop;
	call (resource, stop);
	if isTimer (events_info[_index]) then
		events_info[_index]:destroy();
	end
	events_info[_index] = nil;
	triggerLatentClientEvent (root, "events.getevents", resourceRoot, getEvents(), event_active);
end

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
				events_info[ind]	= nil;
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
	if exports.mtatr_civ:getPlayerMission(player) then
		return false, "Evente girmek için görevden çıkmanız gerekiyor (/gorevcik)", "dm";
	end
	if player:getDimension() ~= 0 or player:getInterior() ~= 0 then
		return false, "Evente girmek için dışarıda olmanız gerekiyor.", "dm";
	end
	if getElementData (player, "inpvp") then
		return false, "TDM'deyken etkinliğe katılamazsınız.", "dm";
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

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root,
	function()
		if event_active then
			local cond = canPlayerJoinEvent (source);
			if cond then
				outputChatBox (event_active.. " etkinliği şuan aktif! ffffff/eventgir #ffff00 yazıp girebilirsiniz.", source, 255, 225, 2, true);
			end
		end
		triggerLatentClientEvent (source, "events.getevents", source, getEvents(), event_active);
	end
);

function getEvents()
	return events;
end

addEvent ("events.sendevents", true);
addEventHandler ("events.sendevents", root,
	function ()
		local maps = {};
		for i, v in ipairs (events) do
			if v.map_prefix then
				maps[v.name] = {};
				for _, map in ipairs (getResources()) do
					if map:getName():find(v.map_prefix) then
						table.insert(maps[v.name], map:getName());
					end
				end
			end
		end
		triggerLatentClientEvent (client, "events.getevents", client, getEvents(), event_active, maps);
	end
);

addEvent ("admin.forcestartevent", true);
addEventHandler ("admin.forcestartevent", root,
	function (event)
		if event_active == event then
			local current  = events[events_index];
			call(getResourceFromName(current.resource), current.run);
		end
	end
);

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		for i, v in ipairs (getResources()) do
			if getResourceInfo (v, "type") == "event" then
				if getResourceState (v) ~= "running" then
					startResource (v, true);
					return;
				end
				restartResource(v, true);
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
