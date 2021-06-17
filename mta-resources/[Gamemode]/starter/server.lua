notToStart = {
	votemanager = true,
	admin2 = true,
	webbrowser = true,
	acpanel = true,
	mapcycler = true,
	editor = true,
	editor_gui = true,
	editor_main = true,
	freecam = true,
	move_cursor = true,
	move_freecam = true,
	move_keyboard = true,
	msgbox = true,
	tooltip = true,
	database = true,
	editor_dump = true,
	superman = true,
	editor_test = true,
	gps = true,
	easytext = true,
	deathpickups = true,
	traffic = true,
	mtatr_deathmatches = true,
	mtatr_mode = true,
	mtatr_jobs = true,
	interiors = true,
	irc = true,
	helpmanager = true,
	mtatr_bounty = true,
};

local events = {
	"arena_",
	"dmevent_",
	"ptp_",
	"editor",
	"mtatr_civ",
	"race_",
	"shader_",
};

do
	for i, v in ipairs (getResources()) do
		for _, event in ipairs (events) do
			if getResourceName(v):find (event) then
				notToStart[getResourceName(v)] = true;
			end
		end
		if getResourceInfo (v, "type") == "mission" then
			notToStart[getResourceName(v)] = true;
		end
	end
end

local ordered = {
    "admin",
    "killmessages",
	"mtatr_civ",
	"mtatr_scoreboard"
};

function startResources ()
	for i, v in ipairs (ordered) do
		if getResourceState (getResourceFromName (v)) ~= "running" then
			startResource (getResourceFromName (v), true);
		end
	end
	for i, v in ipairs (getResources()) do
		if not notToStart [getResourceName(v)] and getResourceState (v) ~= "running" and getResourceName(v):find("mtatr") then
			startResource (v, true);
		end
	end
	setGameType ("GÜNLÜK ETKİNLİKLER GÖREVLER VE DAHA FAZLASI");
end
