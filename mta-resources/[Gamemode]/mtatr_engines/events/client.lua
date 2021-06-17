local screenW, screenH = guiGetScreenSize()

----------------------
-- TEAM STATUS BAR
----------------------

local teamsbar	= nil;
local x, y		= guiGetScreenSize();
local h 		= 28;
local xpos 		= x / 2;
local offset 	= 40;

local function findTeamInBar (team)
	if teamsbar then
		for i, v in pairs (teamsbar) do
			if type (v) == "table" then
				if v.text then
					if v.text == team then
						return i;
					end
				end
			end
		end
	end
	return false;
end

function showTeamsBar (state)
	if state == true then
		addEventHandler ("onClientRender", root, drawTeamBar);
	else
		removeEventHandler ("onClientRender", root, drawTeamBar);
		teamsbar = nil;
	end
end
addEvent ("engines.showteambar", true);
addEventHandler ("engines.showteambar", root, showTeamsBar);

function updateTeamsBar (info)
	teamsbar = info;
	teamsbar.time = teamsbar.time * 60 * 1000;
end
addEvent ("engines.updateteambar", true);
addEventHandler ("engines.updateteambar", root, updateTeamsBar);

function updateTeamsBarData (team, key, data)
	if key == "time" then
		data = data * 1000 * 60;
	end
	local team = findTeamInBar (team);
	if not team then return; end
	if not teamsbar[team] then return; end
	teamsbar[team][key] = data;
end
addEvent ("engines.updateteambardata", true);
addEventHandler ("engines.updateteambardata", root, updateTeamsBarData);

function startTeamsBarTimer ()
	teamsbar.timer = getTickCount () + 1000;
end
addEvent ("engines.startteamsbartimer", true);
addEventHandler ("engines.startteamsbartimer", root, startTeamsBarTimer);

local function getTeamDetails (team)
	local r, g, b = unpack (teamsbar[team].colour);
	return
	{
		text    = teamsbar[team].text,
		r		= r,
		g 		= g,
		b		= b,
		players = teamsbar[team].players,
		score 	= teamsbar[team].score,
		health  = teamsbar[team].health,
	};
end

function drawTeamBar ()
	if teamsbar then
		-- BACKGROUND
		dxDrawImage (0, y-h, x, h, "events/files/img/bg.png", 0, 0, 0, tocolor (255, 255, 255, 60), true);

		------------------------------------------

		-- TEAM 1
		local team1 = getTeamDetails ("team1");

		-- TEAM NAME
		dxDrawText(team1.text, 10, y, dxGetTextWidth (team1.text), y-h, tocolor(team1.r, team1.g, team1.b, 255), exports.mtatr_gui:getScale (.90), "bankgothic", "left", "center", false, false, true, false, false)

		--HEALTH
		dxDrawImage (x * 0.1868, y-h, 30, h, "events/files/img/health.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team1.health, x * 0.1868 + offset, y, dxGetTextWidth (team1.health), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);

		--PLAYERS
		dxDrawImage (x * 0.3025, y-h, 30, h, "events/files/img/players.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team1.players, x * 0.3025 + offset, y, dxGetTextWidth (team1.players), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);

		-- SCORE
		dxDrawImage (x * 0.3951, y-h, 30, h, "events/files/img/score.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team1.score, x * 0.3951 + offset, y, dxGetTextWidth (team1.score), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);

		------------------------------------------
		if teamsbar.timer then
			local tick = teamsbar.timer;
			if getTickCount () >= teamsbar.timer then
				teamsbar.time = teamsbar.time - 1000;
				teamsbar.timer = getTickCount () + 1000;
			end
		end


		-- TIME
		dxDrawImage (x/2, y-h, 30, h, "events/files/img/time.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (exports.mtatr_utils:totime (teamsbar.time/1000), (x/2) + (offset), y, dxGetTextWidth (teamsbar.time), y-h, tocolor (255, 255, 255, 255), .50, "bankgothic", "left", "center", false, false, true);

		------------------------------------------

		-- TEAM 2
		local team2 = getTeamDetails ("team2");

		-- TEAM NAME
		dxDrawText(team2.text, x * 0.8465, y, x, y-h, tocolor(team2.r, team2.g, team2.b, 255), exports.mtatr_gui:getScale (.90), "bankgothic", "right", "center", false, false, true, false, false)

		--HEALTH
		dxDrawImage (x * 0.7722, y-h, 30, h, "events/files/img/health.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team2.health, x * 0.7722 + offset, y, dxGetTextWidth (team2.health), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);

		--PLAYERS
		dxDrawImage (x * 0.6903, y-h, 30, h, "events/files/img/players.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team2.players, x * 0.6903 + offset, y, dxGetTextWidth (team2.players), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);

		-- SCORE
		dxDrawImage (x * 0.6003, y-h, 30, h, "events/files/img/score.png", 0, 0, 0, tocolor (255, 255, 255, 255), true);
		dxDrawText (team2.score, x * 0.6003 + offset, y, dxGetTextWidth (team2.score), y-h, tocolor (255, 255, 255, 255), .80, "bankgothic", "left", "center", false, false, true);
	end
end

----------------------
-- TEAM SELECTION MENU
----------------------

local event_selected_skin = 0;
local event_selected_team;
local event_teams = {};

local team_menu   = {
    button = {},
    window = {},
    label = {}
};

local def_teams	  = {
	{
		name 	= "OTO SEÇİM",
		colour 	= {224, 232, 240},
		desc 	= "Takımım otomatik seçilsin.",
		skins 	= {{model = 0, weapons = {}}},
	}
};

local function navigateTeamButtons ()
	if source == team_menu.button[1] then
		selectTeamSkin (event_selected_team, true);
	elseif source == team_menu.button[2] then
		selectTeamSkin (event_selected_team, false);
	end
end

local event_button = {
	type = "rectangle",
	font = "bankgothic",
	restored = {
		colour = tocolor (0, 0, 0, 175),
	},
	clicked = {
		colour = tocolor (13, 255, 57, 190),
	},
	onpoint = {
		colour = tocolor (13, 255, 57, 140),
	},
	onclick = {
		colour = tocolor (13, 255, 57, 180),
	},
	text = {
		colour = tocolor (255, 255, 255, 255),
		scale = .6,
	},
	xalign = "center",
	yalign = "center",
};

local function acceptTeam ()
	triggerServerEvent ("onClientPlayerAcceptsEventTeam", localPlayer, event_teams[event_selected_team].name, event_selected_skin);
end

function event_navigate (key, state, lod)
	if type (lod) == "boolean" then
		if not lod then
			triggerEvent ("onClientGUIClick", team_menu.button[1]);
		else
			triggerEvent ("onClientGUIClick", team_menu.button[2]);
		end
	elseif lod == "submit" then
		triggerEvent ("onClientGUIClick", team_menu.button[3]);
	end
end

local function findTeam (team)
	for i, v in ipairs (event_teams) do
		if v.name == team then
			return i;
		end
	end
	return false;
end

function createTeamSelectionMenu (eventName, weapon, dimension, ...)
	local args = {...};
	for i, v in ipairs (args) do
		table.insert (event_teams,
			{
				name 	= v.name,
				colour  = v.colour,
				skins 	= v.skins,
				desc 	= v.desc,
				players = v.players,
				weapon  = weapon,
			}
		);
	end

	for i, v in ipairs (def_teams) do
		table.insert (event_teams,
			{
				name 	= v.name,
				colour 	= v.colour,
				skins 	= v.skins,
				desc 	= v.desc,
				weapon  = weapon,
			}
		);
	end

	team_menu.window[1] = exports.mtatr_gui:guiCreateWindow(0.15, 0.29, 0.26, 0.45, eventName.." Takım Seçimi", true, nil, {image = "events/files/img/event_bg.png", layer = "events/files/img/event_layer.png", colour = {0, 0, 0, 255}}); --fill this up

	team_menu.button[1] = exports.mtatr_gui:guiCreateButton(0.79, 0.15, 0.10, 0.05, ">", true, team_menu.window[1], event_button)
	guiSetProperty(team_menu.button[1], "NormalTextColour", "FFAAAAAA")
	team_menu.button[2] = exports.mtatr_gui:guiCreateButton(0.08, 0.15, 0.10, 0.05, "<", true, team_menu.window[1], event_button)
	guiSetProperty(team_menu.button[2], "NormalTextColour", "FFAAAAAA")

	addEventHandler ("onClientGUIClick", team_menu.button[1], navigateTeamButtons, false);
	addEventHandler ("onClientGUIClick", team_menu.button[2], navigateTeamButtons, false);

	bindKey ("arrow_l", "down", event_navigate, true);
	bindKey ("arrow_r", "down", event_navigate, false);
	bindKey ("enter", "down", event_navigate, "submit");
	bindKey ("num_enter", "down", event_navigate, "submit");

	team_menu.button[3] = guiCreateButton(0.21, 0.07, 0.55, 0.22, "", true, team_menu.window[1]);
	guiSetAlpha (team_menu.button[3], 0);
	addEventHandler ("onClientGUIClick", team_menu.button[3], acceptTeam, false);

	team_menu.ped = createPed (0, 38.86, 2233.68, 126.37);
	setCameraMatrix (42, 2229.07, 127.09, 41.41, 2229.9, 127.07);

	setElementDimension (team_menu.ped, dimension);

	team_menu.ped:setRotation (0, 0, 212);

	-- SET CAMERA MATRIX
	selectTeam (1);
	selectTeamSkin (1, true, 1);

	addEventHandler("onClientRender", root, drawTeamMenu);

	--create gui
	--if the team got no skins more than one set set skin button invisible on click
	--if got no skins no show

	showCursor (true);
end
addEvent ("engines.createteammenu", true);
addEventHandler ("engines.createteammenu", root, createTeamSelectionMenu);

function updateTeamMenuData (team, key, data)
	if findTeam (team) then
		local team = findTeam (team);
		event_teams[team][key] = data;
	end
end
addEvent ("engines.updateteammenu", true);
addEventHandler ("engines.updateteammenu", root, updateTeamMenuData);

function clearTeamMenuData ()
	unbindKey ("arrow_l", "down", event_navigate, false);
	unbindKey ("arrow_r", "down", event_navigate, true);
	unbindKey ("enter", "down", event_navigate, "submit");
	unbindKey ("num_enter", "down", event_navigate, "submit");
	if isElement (team_menu.window[1]) then
		removeEventHandler ("onClientGUIClick", team_menu.button[1], navigateTeamButtons);
		removeEventHandler ("onClientGUIClick", team_menu.button[1], navigateTeamButtons);
		removeEventHandler ("onClientGUIClick", team_menu.button[3], acceptTeam);
	end
	removeEventHandler ("onClientRender", root, drawTeamMenu);

	if isElement (team_menu.window[1]) then
		destroyElement (team_menu.window[1]);
	end
	event_selected_skin = 1;
	event_selected_team = nil;
	team_menu   = {
		button = {},
		window = {},
		label = {}
	};
	event_teams = {};
end

function destroyTeamMenu (delay)
	local time = 50;
	if delay then
		time = delay;
	end
	setTimer (
		function ()
			if isElement (team_menu.ped) then
				team_menu.ped:destroy();
			end
			setCameraTarget (localPlayer);
			clearTeamMenuData ();
		end,
	time, 1);
	showCursor (false);
end
addEvent ("engines.destroyteammenu", true);
addEventHandler ("engines.destroyteammenu", root, destroyTeamMenu);

function selectTeam (t, _index)
	if event_teams[t] then
		event_selected_team = t;
		event_selected_skin = _index or 1;
		selectTeamSkin (t, true, event_selected_skin);
	else
		if t >= #event_teams then
			selectTeam (1);
		elseif t <= 0 then
			selectTeam (#event_teams);
			selectTeamSkin (#event_teams, true, #event_teams[#event_teams].skins);
		end
	end
end

function getCurrentSkinIndex (model)
	for i, v in ipairs (event_teams[event_selected_team].skins) do
		if v.model == model then
			return i;
		end
	end
	return false;
end

function selectTeamSkin (t, lor, _index) --team, left or right ==> if set to true it goes right else left
	if event_teams[t] then
		local team 	  = event_teams[t];
		local skins   = team.skins;

		if skins and next(skins) then
			local index = event_selected_skin + (lor and 1 or -1);
			if _index then
				index = _index;
			end
			if skins[index] then
				event_selected_skin = index;
				setElementModel (team_menu.ped, skins[index].model);
			else
				if index >= #skins then
					selectTeam (t+1);
				elseif index <= 0 then
					if event_teams[t-1] then
						selectTeam(t-1, #event_teams[t-1].skins);
					else
						selectTeam(#event_teams);
					end
				end
			end
		end
	end
end

function drawTeamMenu()
	local scale = exports.mtatr_gui:getScale (2.00);
	local team 	  = event_teams[event_selected_team];
	local name	  = team.name;
	local colour  = team.colour;
	local weapons = team.skins[event_selected_skin].weapons;
	local weapon  = team.weapon;
	local desc	  = team.desc;
	local r, g, b = unpack (colour);
	local players = team.players;
	local sk_name = team.skins[event_selected_skin].name and "("..team.skins[event_selected_skin].name..")" or "";

	dxDrawText(name.."\n"..sk_name, (screenW * 0.1972) - 1, (screenH * 0.3189) - 1, (screenW * 0.3542) - 1, (screenH * 0.4056) - 1, tocolor(0, 0, 0, 255), scale, "default", "center", "center", false, false, true, false, false)
	dxDrawText(name.."\n"..sk_name, (screenW * 0.1972) + 1, (screenH * 0.3189) - 1, (screenW * 0.3542) + 1, (screenH * 0.4056) - 1, tocolor(0, 0, 0, 255), scale, "default", "center", "center", false, false, true, false, false)
	dxDrawText(name.."\n"..sk_name, (screenW * 0.1972) - 1, (screenH * 0.3189) + 1, (screenW * 0.3542) - 1, (screenH * 0.4056) + 1, tocolor(0, 0, 0, 255), scale, "default", "center", "center", false, false, true, false, false)
	dxDrawText(name.."\n"..sk_name, (screenW * 0.1972) + 1, (screenH * 0.3189) + 1, (screenW * 0.3542) + 1, (screenH * 0.4056) + 1, tocolor(0, 0, 0, 255), scale, "default", "center", "center", false, false, true, false, false)
	dxDrawText(name.."\n"..sk_name, screenW * 0.1972, screenH * 0.3189, screenW * 0.3542, screenH * 0.4056, tocolor(r, g, b, 255), scale, "default", "center", "center", false, false, true, false, false)

	dxDrawText("---------------------------------------------------------------------------------------", screenW * 0.1576, screenH * 0.4267, screenW * 0.4069, screenH * 0.4478, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", true, false, true, false, false)
	if next (weapons) then
		dxDrawText(table.concat (weapons, ", "), screenW * 0.1576, screenH * 0.4989, screenW * 0.4000, screenH * 0.5289, tocolor(255, 255, 255, 255), 1.00, "clear", "left", "top", false, true, true, false, false)
		dxDrawText(weapon..":", screenW * 0.1576, screenH * 0.4589, screenW * 0.2687, screenH * 0.4933, tocolor(255, 255, 255, 255), 1.60, "default", "left", "top", false, true, true, false, false)
	end
	dxDrawText("Açıklama:", screenW * 0.1576, screenH * 0.5933, screenW * 0.2687, screenH * 0.5978, tocolor(255, 255, 255, 255), 1.60, "default", "left", "top", false, false, true, false, false)
	dxDrawText(desc, screenW * 0.1576, screenH * 0.6278, screenW * 0.4000, screenH * 0.7300, tocolor(255, 255, 255, 255), 1.00, "clear", "left", "top", false, true, true, false, false)
	if players then
		dxDrawText("Oyuncular:", screenW * 0.1576, screenH * 0.5433, screenW * 0.2049, screenH * 0.5567, tocolor(255, 255, 255, 255), 1.60, "default", "left", "top", false, false, true, false, false)
		dxDrawText(players, screenW * 0.2349, screenH * 0.5633, screenW * 0.2944, screenH * 0.5567, tocolor(255, 255, 255, 255), 1.00, "clear", "left", "center", false, false, true, false, false)
	end

	dxDrawText("Başlamak için 'enter' tuşuna basın.", screenW * 0.2076, screenH * 0.7144, screenW * 0.3556, screenH * 0.7389, tocolor(255, 255, 255, 255), 0.90, "default-bold", "center", "top", false, false, true, false, false)
end

----------------------
-- MAP RESTRICTION
----------------------

local restriction_tick = 0;
local restriction_time = 0;

addEvent ("engines.addrestrict", true);
addEventHandler ("engines.addrestrict", root,
	function (time)
		restriction_tick = getTickCount ();
		restriction_time = time;
		removeEventHandler ("onClientRender", root, drawRestriction);
		addEventHandler("onClientRender", root, drawRestriction);
	end
);

addEvent ("engines.removerestrict", true);
addEventHandler ("engines.removerestrict", root,
	function (time)
		restriction_tick = 0;
		restriction_time = 0;
		removeEventHandler ("onClientRender", root, drawRestriction);
	end
);

function drawRestriction()
	dxDrawRectangle(screenW * 0.0000, screenH * 0.0000, screenW * 1.0000, screenH * 1, tocolor(0, 0, 0, 111), false)

	dxDrawText("Haritaya geri dön!", (screenW * 0.2750) - 1, (screenH * 0.2467) - 1, (screenW * 0.7160) - 1, (screenH * 0.3611) - 1, tocolor(0, 0, 0, 255), 4.00, "default", "center", "top", false, false, false, false, false)
	dxDrawText("Haritaya geri dön!", (screenW * 0.2750) + 1, (screenH * 0.2467) - 1, (screenW * 0.7160) + 1, (screenH * 0.3611) - 1, tocolor(0, 0, 0, 255), 4.00, "default", "center", "top", false, false, false, false, false)
	dxDrawText("Haritaya geri dön!", (screenW * 0.2750) - 1, (screenH * 0.2467) + 1, (screenW * 0.7160) - 1, (screenH * 0.3611) + 1, tocolor(0, 0, 0, 255), 4.00, "default", "center", "top", false, false, false, false, false)
	dxDrawText("Haritaya geri dön!", (screenW * 0.2750) + 1, (screenH * 0.2467) + 1, (screenW * 0.7160) + 1, (screenH * 0.3611) + 1, tocolor(0, 0, 0, 255), 4.00, "default", "center", "top", false, false, false, false, false)
	dxDrawText("Haritaya geri dön!", screenW * 0.2750, screenH * 0.2467, screenW * 0.7160, screenH * 0.3611, tocolor(255, 0, 0, 255), 4.00, "default", "center", "top", false, false, false, false, false)

	if getTickCount () > restriction_tick + 1000 then
		restriction_tick = getTickCount ();
		restriction_time = restriction_time - 1;
	end

	dxDrawText(restriction_time.." saniye içinde öldürüleceksin!", (screenW * 0.3201) - 1, (screenH * 0.3767) - 1, (screenW * 0.6792) - 1, (screenH * 0.4267) - 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "top", false, false, false, false, false)
	dxDrawText(restriction_time.." saniye içinde öldürüleceksin!", (screenW * 0.3201) + 1, (screenH * 0.3767) - 1, (screenW * 0.6792) + 1, (screenH * 0.4267) - 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "top", false, false, false, false, false)
	dxDrawText(restriction_time.." saniye içinde öldürüleceksin!", (screenW * 0.3201) - 1, (screenH * 0.3767) + 1, (screenW * 0.6792) - 1, (screenH * 0.4267) + 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "top", false, false, false, false, false)
	dxDrawText(restriction_time.." saniye içinde öldürüleceksin!", (screenW * 0.3201) + 1, (screenH * 0.3767) + 1, (screenW * 0.6792) + 1, (screenH * 0.4267) + 1, tocolor(0, 0, 0, 255), 1.50, "default", "center", "top", false, false, false, false, false)
	dxDrawText(restriction_time.." saniye içinde öldürüleceksin!", screenW * 0.3201, screenH * 0.3767, screenW * 0.6792, screenH * 0.4267, tocolor(255, 255, 255, 255), 1.50, "default", "center", "top", false, false, false, false, false)
end


----------------------
-- COUNTDOWN
----------------------

local count_tick = 0;
local count_time = 0;
local count_cache = 0;

function startCountDown ()
	removeEventHandler("onClientRender", root, drawCountDown);
	count_tick = getTickCount ();
	count_time = 3;
	count_cache = 3;
	addEventHandler("onClientRender", root, drawCountDown);
	playSound ("events/files/sound/count_"..count_time..".mp3");
end
addEvent ("engines.startCountDown", true);
addEventHandler ("engines.startCountDown", root, startCountDown);

function drawCountDown()
	local rate = (getTickCount () - count_tick) / (300);
	local w, h = interpolateBetween (186/2, 185/2, 0, 186, 185, 0, rate, "InBack");
	if getTickCount () >= count_tick + 1000 then
		if count_time == "go" then
			removeEventHandler("onClientRender", root, drawCountDown);
			count_time = 3;
			count_cache = 3;
			triggerEvent ("onClientCountDownReachToEnd", resourceRoot);
			return
		end
		count_tick = getTickCount ();
		count_time = count_time - 1;
		if count_time <= 0 then
			count_time = "go";
		end
		playSound ("events/files/sound/count_"..count_time..".mp3");
	end
	dxDrawImage((screenW - w) / 2, (screenH - h) / 2, w, h, "events/files/img/count_"..count_time..".png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
end

----------------------
-- IMMUNITY
----------------------
local immune = {};

addEvent ("engines.immunity", true);
addEventHandler ("engines.immunity", root,
	function (player)
		if player == localPlayer then return; end
		if type (player) == "userdata" then
			immune[player] = true;
		else
			immune = {};
		end
	end
);

function addImmunity (attacker)
	if immune[attacker] then
		cancelEvent();
	end
end
addEventHandler ("onClientPlayerDamage", localPlayer, addImmunity);

----------------------
-- FINISHING EVENT
----------------------

addEvent ("engines.eventfinish", true);
addEventHandler ("engines.eventfinish", root,
	function (time)
		local sound = playSFX("genrl", 75, 1, false);
		setGameSpeed (.3);
		setTimer (function (s) setGameSpeed (1); if isElement (s) then s:destroy(); end end, time * 1000, 1, sound);
	end
);

----------------------
-- GET EVENTS
----------------------
local eventsTable = {};

addEvent ("events.getevents", true);
addEventHandler ("events.getevents", root,
	function (e_, a_)
		if e_ then
			eventsTable.events = e_;
			eventsTable.active = a_;
		end
	end
);

addEventHandler ("onClientResourceStart", resourceRoot,
	function ()
		triggerServerEvent ("events.sendevents", localPlayer);
	end
);

function getEvents ()
	return eventsTable;
end

----------------------
-- RACE RANK
----------------------
local race = {};

function showRank(rank)
	race.rank = rank;
	removeEventHandler ("onClientRender", root, renderRank);
	addEventHandler ("onClientRender", root, renderRank);
end
addEvent ("engines.race.showrank", true);
addEventHandler ("engines.race.showrank", root, showRank);

function updateRank(rank)
	race.rank = rank;
end
addEvent ("engines.race.updaterank", true);
addEventHandler ("engines.race.updaterank", root, showRank);

function destroyRank()
	removeEventHandler ("onClientRender", root, renderRank);
	race = {};
end
addEvent ("engines.race.destroyrank", true);
addEventHandler ("engines.race.destroyrank", root, showRank);

function renderRank()
	if not race.rank then return; end
	local r_t = "SIRA\n"..race.rank;
	local r_x, r_y, r_w, r_h = screenW - 177 - 10, (screenH - 142) / 2, (screenW - 177 - 10) + 177, ( (screenH - 142) / 2) + 142;
	dxDrawText(r_t, r_x-1, r_y-1, r_w-1, r_h-1, tocolor (0, 0, 0, 255), 1, "bankgothic", "center", "center");
	dxDrawText(r_t, r_x+1, r_y-1, r_w+1, r_h-1, tocolor (0, 0, 0, 255), 1, "bankgothic", "center", "center");
	dxDrawText(r_t, r_x-1, r_y+1, r_w-1, r_h+1, tocolor (0, 0, 0, 255), 1, "bankgothic", "center", "center");
	dxDrawText(r_t, r_x+1, r_y+1, r_w+1, r_h+1, tocolor (0, 0, 0, 255), 1, "bankgothic", "center", "center");
	dxDrawText(r_t, r_x, r_y, r_w, r_h, tocolor(237, 172, 17, 255), 1.00, "bankgothic", "center", "center");
end

----------------------
-- BLIPS
----------------------
local blips = {};
function createTeamBlips (players, r, g, b)
	destroyBlips();
	for i, v in ipairs (players) do
		if not isElement (blips[v]) then
			local r, g, b = r, g, b or getPlayerNametagColor (v);
			local blip = createBlipAttachedTo ( v, 0, 2, r, g, b, 255, 0, 1000 );
			blips[v] = blip;
		end
	end
end
addEvent ("events.createblips", true);
addEventHandler("events.createblips", root, createTeamBlips);

function destroyBlips()
	for player, blip in pairs(blips) do
		if isElement (blip) then
			blip:destroy();
		end
	end
end
addEvent ("events.destroyblips", true);
addEventHandler ("events.destroyblips", root, destroyBlips);

bindKey ("num_4", "down",
	function ()
		if isElement (blips[localPlayer]) then
			triggerServerEvent ("events.flashblip", localPlayer, blips);
		end
	end
);

addEvent ("events.flashblip", true);
addEventHandler ("events.flashblip", root,
	function (player)
		if blips[player] then
			flashBlip (blips[player]);
		end
	end
);

local flashblipsTimer = {}
local flashing = {}

function flashBlip (blip)
	if blip and isElement (blip) then
		if getElementType (blip) == "blip" then
			flashing[blip] = false
			local r, g, b = getBlipColor (blip)
			local blipsize = getBlipSize (blip)
			if not flashblipsTimer[blip] or not isTimer (flashblipsTimer[blip]) then
				flashblipsTimer[blip] = setTimer (
					function ()
						if flashing[blip] == true then
							setBlipSize (blip, blipsize)
							setBlipColor (blip, r, g, b, 255)
							flashing[blip] = false
						else
							setBlipColor (blip, 255, 255, 0, 255)
							setBlipSize (blip, tonumber (blipsize) + 0.85)
							flashing[blip] = true
						end
					end,
				500, 20)
				setTimer (
					function ()
						setBlipSize (blip, blipsize)
						setBlipColor (blip, r, g, b, 255)
						flashing[blip] = false
					end,
				11000, 1)
			end
		end
	end
end

----------------------
-- WEAPON SELECTION
----------------------

wp = {
    gridlist = {},
    window = {},
    button = {},
	weaponlist = {
		{
			{weapon = 22, ammo = 300},
			{weapon = 23, ammo = 200},
			{weapon = 24, ammo = 100},
		},
		{
			{weapon = 25, ammo = 100},
			{weapon = 27, ammo = 100}
		},
		{
			{weapon = 30, ammo = 1500},
			{weapon = 31, ammo = 1000},
		},
		{
			{weapon = 33, ammo = 250},
			{weapon = 34, ammo = 100},
		}
	}
};

addEvent ("engines.weaponselectionmenu", true);
addEventHandler("engines.weaponselectionmenu", root,
    function(state)
		if state ~= true then
			if isElement (wp.window[1]) then
				wp.window[1]:destroy();
				showCursor(false);
			end
			return;
		end
		local screenW, screenH = guiGetScreenSize()
        wp.window[1] = guiCreateWindow((screenW - 791) / 2, (screenH - 259) / 2, 791, 259, "Silah Seç", false)
        guiWindowSetSizable(wp.window[1], false)

        wp.gridlist[1] = guiCreateGridList(0.01, 0.10, 0.23, 0.76, true, wp.window[1])
        guiGridListAddColumn(wp.gridlist[1], "Silah", 0.5)
        guiGridListAddColumn(wp.gridlist[1], "Ammo", 0.4)
        wp.button[1] = guiCreateButton(0.45, 0.88, 0.10, 0.08, "Onayla", true, wp.window[1])
        guiSetProperty(wp.button[1], "NormalTextColour", "FFAAAAAA")
        wp.gridlist[2] = guiCreateGridList(0.26, 0.10, 0.23, 0.76, true, wp.window[1])
        guiGridListAddColumn(wp.gridlist[2], "Silah", 0.5)
        guiGridListAddColumn(wp.gridlist[2], "Ammo", 0.4)
        wp.gridlist[3] = guiCreateGridList(0.51, 0.10, 0.23, 0.76, true, wp.window[1])
        guiGridListAddColumn(wp.gridlist[3], "Silah", 0.5)
        guiGridListAddColumn(wp.gridlist[3], "Ammo", 0.4)
        wp.gridlist[4] = guiCreateGridList(0.76, 0.10, 0.23, 0.76, true, wp.window[1])
        guiGridListAddColumn(wp.gridlist[4], "Silah", 0.5)
        guiGridListAddColumn(wp.gridlist[4], "Ammo", 0.4)

		for i, list in ipairs (wp.weaponlist) do
			local grid = wp.gridlist[i];
			for k, v in ipairs (list) do
				local row = guiGridListAddRow(grid);
				guiGridListSetItemText (grid, row, 1, getWeaponNameFromID(v.weapon), false, false);
				guiGridListSetItemText (grid, row, 2, v.ammo, false, false);
				guiGridListSetItemData (grid, row, 1, v.weapon);
			end
		end

		showCursor(true);

		addEventHandler ("onClientGUIClick", wp.button[1],
			function ()
				local wep = {};
				for i=1, 4 do
					local item = guiGridListGetSelectedItem (wp.gridlist[i]);
					if item ~= -1 then
						local weapon = guiGridListGetItemData (wp.gridlist[i], item, 1);
						local ammo = tonumber (guiGridListGetItemText (wp.gridlist[i], item, 2));
						table.insert (wep, {weapon = tonumber(weapon), ammo = tonumber(ammo)});
					end
				end
				guiSetVisible (wp.window[1], false);
				showCursor(false);
				triggerLatentServerEvent ("engines.submitweapon", localPlayer, wep);
			end,
		false);
    end
)
