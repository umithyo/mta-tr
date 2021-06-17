function getCameraAngles (x, y, z, angle, distance)
	local angle = angle/180*3.14159265358979;
    local x = x - ( math.sin (angle) * distance );
    local y = y + ( math.cos(angle) * distance );
	return x, y, z;
end

function findRotation(x1,y1,x2,y2)

  local t = -math.deg(math.atan2(x2-x1,y2-y1));
  if t < 0 then t = t + 360 end
  return t;

end

function CreateAntiRushZone(table_a,count_a)
	local radars = {};
	local Ploygon_s = {};
	local arena = {x={}, y={}};
	local int = 0;
	for i=1, count_a do
		for k, v in pairs(table_a[i]) do
			if k ~= 3 then
			int = int+1;
			Ploygon_s[int] = v;
			end
		end
	end
	Ploygon_s[int+1] = Ploygon_s[1];
	Ploygon_s[int+2] = Ploygon_s[2];
	local PolygonA = createColPolygon ( unpack(Ploygon_s) );

	for k,v in pairs(table_a) do
		table.insert(arena.x, v[1]);
		table.insert(arena.y, v[2]);
	end

	for j=1, #arena.x-1 do
		local distance = math.floor(getDistanceBetweenPoints2D (arena.x[j], arena.y[j], arena.x[j+1], arena.y[j+1]));
		local rot = math.floor(findRotation(arena.x[j], arena.y[j], arena.x[j+1], arena.y[j+1]));
		for i=1,math.floor(distance/5) do
			local x,y,z = getCameraAngles ( arena.x[j], arena.y[j], 0, rot, i*5);
			local radar = MarkTheRushField(x, y, 10, 10);
			radars [radar] = true;
		end
	end

	local distance = math.floor(getDistanceBetweenPoints2D ( arena.x[#arena.x], arena.y[#arena.x], arena.x[1], arena.y[1]));
	local rot = math.floor(findRotation(arena.x[#arena.x], arena.y[#arena.x], arena.x[1], arena.y[1]));
	for i=1, math.floor(distance/5) do
		local x,y,z = getCameraAngles ( arena.x[#arena.x], arena.y[#arena.x], 0, rot, i*5);
		local radar = MarkTheRushField(x, y, 10, 10);
		radars [radar] = true;
		setElementData (radar, "rushpointradar", true);
	end

	return PolygonA, radars;
end

function MarkTheRushField(x,y,sX,sY)
	return createRadarArea ( x-(sX/2), y-(sY/2), sX, sY );
end

function createAntiRushPoints ()
	local rush_table = 	getElementsByType ("Anti_Rush_Point");
	local AntiRush_t = {};
	local AntiRush_c = table.getn(rush_table);
		if AntiRush_c ~= 0 then
			for i=1, AntiRush_c do
			AntiRush_t[i] = {getElementData(rush_table[i], "posX"),getElementData(rush_table[i], "posY"),getElementData(rush_table[i], "posZ")};
		end
	end
	if AntiRush_c ~= 0 then
		return CreateAntiRushZone(AntiRush_t,AntiRush_c);
	end
end

local restricted = {};

function addRestriction (player, time)
	if isElement (player) and time then
		if not isTimer (restricted[player]) then
			triggerClientEvent (player, "engines.addrestrict", player, time);
			restricted[player] = setTimer (function (p) if isElement (p) then killPed (p) removeRestriction (p) end end, time*1000, 1, player);
		end
	end
end

function removeRestriction (player)
	if isElement (player) then
		triggerClientEvent (player, "engines.removerestrict", player);
		if isTimer (restricted[player]) then
			killTimer (restricted[player]);
		end
		restricted[player] = nil;
	end
end

function showTeamsBar (player, state)
	triggerClientEvent (player, "engines.showteambar", player, state);
end

--info TABLE;
--- text => team name
--- colour => colour
--- players => player count
--- score => score
--- health => health
-- time => event timeout
function updateTeamsBar (player, info)
	triggerLatentClientEvent (player, "engines.updateteambar", player, info);
end

function updateTeamsBarData (player, team, key, data)
	triggerClientEvent (player, "engines.updateteambardata", player, team, key, data);
end

function startTeamsBarTimer (player)
	triggerClientEvent (player, "engines.startteamsbartimer", player);
end

--event => event name
--weapon => weapon header (this could be a vehicle)
--dimension => event dimension
-- ... => team table
--- desc => desc
--- name => team name
--- skins => skins table
---- name = skin name
---- model = skin model
---- weapons => skin weapons table
----- weapon1 string, weapon2 string
--- colour => color table
---- r, g, b
--- players => player count
function createTeamMenu (player, event, weapon, dimension, teams)
	triggerLatentClientEvent (player, "engines.createteammenu", player, event, weapon, dimension, unpack (teams));
end

--team => team name
function updateTeamMenu (player, team, key, data)
	triggerClientEvent (player, "engines.updateteammenu", player, team, key, data);
end

function destroyTeamMenu (player, delay)
	triggerClientEvent (player, "engines.destroyteammenu", player, delay);
end

addEvent ("onClientPlayerAcceptsEventTeam", true);
addEventHandler ("onClientPlayerAcceptsEventTeam", root,
	function (team, skin)
		triggerEvent ("onPlayerSubmitEventTeam", client, team, skin);
	end
);

local countdown_timer;
local countdown_timers = {};

function startCountDown (player, special_id, ...)
	triggerClientEvent (player, "engines.startCountDown", player);
	if special_id then
		if not isTimer(countdown_timers[special_id]) then
			countdown_timers[special_id] = setTimer (triggerEvent, 3000, 1, "onCountDownReachedToEnd", resourceRoot, special_id, ...);
		end
		return;
	end
	if not isTimer (countdown_timer) then
		countdown_timer = setTimer (triggerEvent, 3000, 1, "onCountDownReachedToEnd", resourceRoot);
	end
end

function setEventFinished (player, time)
	triggerClientEvent (player, "engines.eventfinish", player, time);
end

function getNextSlot (tbl)
	local i = 1;
	while tbl[i] ~= nil do
		i = i + 1;
	end
	return i;
end

--players => player or {[player] = value, ...}
function setPlayerImmuneAgainst (player, players)
	if type (players) == "table" then
		if players[1] then
			for _, i in ipairs (players) do
				triggerLatentClientEvent (i, "engines.immunity", i, player);
				triggerLatentClientEvent (player, "engines.immunity", player, i);
			end
		else
			for i in pairs (players) do
				triggerLatentClientEvent (i, "engines.immunity", i, player);
				triggerLatentClientEvent (player, "engines.immunity", player, i);
			end
		end
	elseif type (players) == "userdata" then
		triggerLatentClientEvent (players, "engines.immunity", players, player);
	else
		if isElement (player) then
			triggerLatentClientEvent (player, "engines.immunity", resourceRoot);
		else
			for i, v in ipairs (getElementsByType"player") do
				triggerLatentClientEvent (v, "engines.immunity", resourceRoot);
			end
		end
	end
end

function showRaceRank (player, rank)
	triggerClientEvent (player, "engines.race.showrank", player, rank or 1);
end

function updateRaceRank (player, rank)
	triggerClientEvent (player, "engines.race.updaterank", player, rank or 1);
end

function destroyRaceRank(player)
	triggerClientEvent (player, "engines.race.destroyrank", player);
end

local blips = {};

addEvent ("events.flashblip", true);
addEventHandler ("events.flashblip", root,
	function ()
		if blips[client] then
			for i, player in ipairs (blips[client]) do
				triggerClientEvent (player, "events.flashblip", player, client);
				outputChatBox (client:getName().." yardım istiyor!", player, 255, 255, 0);
			end
		end
	end
);
--players => {player1, player2, ...} (ORDERED)
function createTeamBlips(player, players, r, g, b)
	exports.mtatr_playerblips:destroyBlipsAttachedTo(player);
	blips[player] = players;
	triggerLatentClientEvent (player, "events.createblips", player, players, r, g, b);
end

function destroyTeamBlips(player)
	blips[player] = nil;
	exports.mtatr_playerblips:createBlips(player);
	triggerClientEvent(player, "events.destroyblips", player);
end

function createWeaponSelectionMenu(player, state)
	triggerClientEvent (player, "engines.weaponselectionmenu", player, state);
end

addEvent ("engines.submitweapon", true)
addEventHandler ("engines.submitweapon", root,
	function (weaponlist)
		triggerEvent ("onPlayerSubmitWeaponList", client, weaponlist);
	end
);
