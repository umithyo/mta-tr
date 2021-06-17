local gm = {};

-- addEvent ("staff.load", true);
-- addEventHandler ("staff.load", root,
-- 	function ()
-- 		gm[source] = false;
-- 		toggleGM(source);
-- 	end
-- );

-- addEventHandler ("onPlayerLogin", root,
-- 	function ()
-- 		gm[source] = false
-- 		toggleGM(source);
-- 	end
-- );

addCommandHandler ("gm",
	function (player)
		toggleGM(player, true);
	end
);

function toggleGM (player, output)
	if exports.mtatr_accounts:isPlayerAdmin(player) then
		gm[player] = not gm[player];
		triggerClientEvent (player, "staff.gm", player, gm[player]);
		if output == true then
			outputChatBox ("Godmode: ".. tostring (gm[player] and "açık" or "kapalı"), player);
		end
		if isPedInVehicle (player) then
			local veh = getPedOccupiedVehicle(player);
			setVehicleDamageProof(veh, gm[player]);
		end
	end
end

addEventHandler ("onPlayerDamage", root,
	function (attacker, wep)
		if not gm[attacker] then return; end
		if exports.mtatr_accounts:isPlayerAdmin(attacker) then
			killPed (source, attacker, wep);
		end
	end
);

addEventHandler ("onPlayerVehicleEnter", root,
	function (veh)
		if gm[source] then
			setVehicleDamageProof(veh, true);
		end
	end
);

addEventHandler ("onPlayerVehicleExit", root,
	function (veh)
		if gm[source] then
			setVehicleDamageProof(veh, false);
		end
	end
);

addEventHandler ("onPlayerWeaponFire", root,
	function (wep, endx, endy, endz, element)
		if not gm[source] then return; end
		if isElement (element) and getElementType(element) == "vehicle" then
			element:destroy();
		end
	end
);

addCommandHandler ("speed",
	function (player, cmd, state)
		if isPedInVehicle (player) then
			if exports.mtatr_accounts:isPlayerAdmin(player) then
				local veh = getPedOccupiedVehicle(player);
				if getVehicleType (veh) == "Plane" then return; end
				if state == "jump" then
					local spx, spy, spz = getElementVelocity(veh);
					setElementVelocity(veh, spx, spy, spz+0.25);
				elseif state == "up" then
					local spx, spy, spz=getElementVelocity(veh);
					setElementVelocity(veh, spx*2, spy*2, spz*2);
				elseif state == "stop" then
					setElementVelocity(veh, 0, 0, 0);
				end
			end
		end
	end
);

--party mode--
local paths = {
	"http://chris8.free.fr/musique%20dance/THE.BEST.MUSIC.OF.50-60-70-90.part.1.of.2.Compilation.Pop.Rock.Hits.Recopilacion.Exitos.MP3.Renamed.ID3Tag.Volume.Normalized/a-ha%20-%20Take%20On%20Me.mp3",
};

local party_peds = {};

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

function findRotation( x1, y1, x2, y2 )
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

local function isCrew (player)
	return exports.mtatr_accounts:isPlayerAdmin(player);
end

local function isStaff (player)
	return exports.mtatr_accounts:isPlayerAdmin(player) or isCrew (player);
end

local party_animations = {
	starter = {
		{
			["scratching"] = {
				"scdldlp",
				"scdlulp",
				"scdrdlp",
				"scdrulp",
				"sclng_l",
				"sclng_r",
				"scmid_l",
				"scmid_r",
				"scshrtl",
				"scshrtr"
			}
		},
	},
	participants = {
		{
			["strip"] = {
				"strip_d",
				"strip_a",
				"strip_c",
				"strip_b",
				"strip_f",
				"strip_e",
				"strip_g",
				"str_loop_a",
				"str_loop_b",
				"str_loop_c",
			}
		},
		{
			["dancing"] = {
				"bd_clap",
				"bd_clap1",
				"dance_loop",
				"DAN_Down_A",
				"DAN_Left_A",
				"DAN_Loop_A",
				"DAN_Right_A",
				"DAN_Up_A",
				"dnce_M_a",
				"dnce_M_b",
				"dnce_M_c",
				"dnce_M_d",
				"dnce_M_e"
			}
		},
	},
}

local party = {timers = {}, objects = {}}

function createPartyItems (owner)
	if owner and isElement (owner) then
		if not isElement (party.objects[1]) then
			local _x, _y, z = getElementPosition (owner);
			local _, _, rot = getElementRotation (owner);
			local x, y = getPointFromDistanceRotation (_x, _y, 1, -rot);
			party.objects[1] = createObject (2205, x, y, z -1); --desk
			party.objects[2] = createObject (14820, x, y, z+1); -- dj_stuff
			attachElements (party.objects[2], party.objects[1], .7, -.2, 1);
			setElementRotation (party.objects[1], 0, 0, rot);
		end
	end
end

function doRunParty (creator)
	local creatoranim
	local participantanim

	if isElement (party.col) then
		participants = getElementsWithinColShape(party.col, "player")
		for i, v in ipairs (getElementsWithinColShape(party.col, "ped")) do
			table.insert (participants, v);
		end

		if isElement (creator) then
			if isElementWithinColShape (creator, party.col) then
				local ID = math.random(#party_animations.starter)
				for k in pairs (party_animations.starter[ID]) do
					creatoranim = k
				end
				local block, anim = creatoranim, party_animations.starter[ID][creatoranim][math.random (#party_animations.starter[ID][creatoranim])]
				creator:setAnimation (block:upper(), anim:upper(), -1, true, false, true, false)
			else
				doStartParty();
			end
		else
			doStopParty();
		end
		setSkyGradient(math.random(255), math.random(255), math.random(255), math.random(255), math.random(255), math.random(255));

		local x, y, z = getElementPosition (creator);
		for i, v in ipairs (participants) do
			if isElement (v) then
				if v ~= creator then
					local ID_ = math.random (#party_animations.participants)
					for k in pairs (party_animations.participants[ID_]) do
						participantanim = k
					end
					local block, anim = participantanim, party_animations.participants[ID_][participantanim][math.random(#party_animations.participants[ID_][participantanim])]
					v:setAnimation (block:upper(), anim:upper(), -1, true, false, true, false)
					if getElementType (v) == "ped" then
						local px, py, pz = getElementPosition (v);
						local rot = findRotation (px, py, x, y)
						setElementRotation (v, 0, 0, rot);
					end
				end
			end
		end
		if #participants == 0 then
			doStopParty()
		end
	else
		killTimer (sourceTimer)
		party.timers[1] = nil
	end
end

local function createPartyTimers (creator, timergap)
	party.timers[1] = setTimer (doRunParty,	timergap, 1, creator)
end

function doStartParty (creator, path, gap)
	if isElement (creator) then
		local x, y, z = getElementPosition (creator)
		party.col = createColSphere (x, y, z, 100)
		local participants = getElementsWithinColShape(party.col, "player")
		for i, v in ipairs (participants) do
			exports.mtatr_hud:dm (creator:getName().. " partiyi başlattı!", v, 255, 0, 255)
		end
		createPartyItems(creator)

		party.timers[2] = setTimer (
			function ()
				if not isTimer (party.timers[1]) then
					local timergap = gap and math.random (1000, 1000*gap) or math.random (1000, 5000)
					createPartyTimers (creator, timergap)
				end
			end,
		50, 0);
		local path = path;
		if path and path:find ("youtube.com") then
			path = "http://www.youtubeinmp3.com/fetch/?video="..path;
		end
		exports["mtatr_3dsound"]:create3DOwnerSound (path or paths[math.random (#paths)], party.objects[1], true, 100, getElementDimension (creator), getElementInterior(creator));
	end
end

function doStopParty ()
	for i, v in ipairs (party.timers) do
		if isTimer (v) then
			killTimer (v)
			v = nil
		end
	end
	if isElement (party.col) then
		for i, v in ipairs (getElementsWithinColShape(party.col, "player")) do
			if isElement (v) then
				v:setAnimation(nil)
			end
		end
		party.col:destroy()
		party.col = nil
	end
	for i, v in ipairs (party.objects) do
		if isElement (v) then
			v:destroy()
			v = nil;
		end
	end

	for i in pairs (party_peds) do
		if isElement (i) then
			i:destroy();
			i = nil;
		end
	end

	resetSkyGradient ();
end

addCommandHandler ("party",
	function (player, cmd, path)
		if isCrew (player) then
			if path then
				if path == "stop" then
					doStopParty()
					outputChatBox ("Partiyi durdurdun!", player, 255, 0, 255)
					return
				else
					if isTimer (party.timers[2]) then doStopParty(); end
					doStartParty (player, path)
					outputChatBox ("Partiyi başlattın!", player, 255, 0, 255)
				end
			else
				if isTimer (party.timers[2]) then doStopParty(); end
				doStartParty (player)
				outputChatBox ("Partiyi başlattın!", player, 255, 0, 255)
			end
		end
	end
);

addCommandHandler("surround",
function (player)
 if isCrew (player) then
  local x,y,z = getElementPosition(player);

  for i=1, 8 do
    local newX, newY = getPointFromDistanceRotation(x, y, 4, 360 * (i/8));
	local ped = createPed(0, newX, newY, z);
    party_peds[ped] = true;
	addPedClothes (ped, "gimpleg", "gimpleg", 17)
	setPedStat (ped, 23, 1000)
  end
 end
end
);

local aimmode = {};
local aimmodes = {};

addCommandHandler ("aimmode",
	function (player, cmd, mode)
		if not isCrew(player) then return; end
		aimmode[player] = mode;
		outputChatBox ("Aimmode: "..tostring(mode), player);
	end
);

addEventHandler ("onPlayerTarget", root,
	function (target)
		if aimmode[source] and aimmodes[aimmode[source]]then
			local fn = aimmodes[aimmode[source]];
			fn(source, target);
		end
	end
);

function aimmodes.grav (player, target)
	if not isElement (target) then return; end
	triggerClientEvent (player, "aimmodes.grav", player, target);
end

addEvent ("aimmodes.grav", true);
addEventHandler ("aimmodes.grav", root,
	function (plr, x, y, z)
		setElementPosition (plr, x, y, z)
	end
);

addCommandHandler ("dev",
	function (player)
		redirectPlayer (player, "", "22005");
	end
);

addCommandHandler ("main",
	function (player)
		redirectPlayer (player, "", "22003");
	end
);
