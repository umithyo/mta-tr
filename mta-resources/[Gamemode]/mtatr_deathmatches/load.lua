DMS = {};
DIMENSION = 600;
DM_TYPE = exports.mtatr_main:getTeamsType ();
DEF_PRIZE = 100;
ZOMBIE_EXPERIENCE = 1;

function getDeathmatchColors ()
	return 251, 217, 106;
end

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		if next (DM_LIST) then
			for i, v in ipairs (DM_LIST) do
				local dm = createElement ("deathmatch", v.name);
				dm:setPosition (v.posX or 0, v.posY or 0, 0);
				dm:setData ("sizeX", v.sizeX or 0);
				dm:setData ("sizeY", v.sizeY or 0);
				dm:setData ("group", v.group);
				dm:setData ("prize", v.prize or DEF_PRIZE)
				setElementInterior (dm, v.int);
				for weapon, data in pairs (v.weapons) do
					setElementData (dm, weapon, data);
				end
				for _, spawnpoint in ipairs (v.spawnpoints) do
					local point = createElement ("dm_spawnpoint");
					point:setData ("caller", v.name);
					local x, y, z, rot = unpack (spawnpoint);
					setElementPosition (point, x, y, z);
					setElementData (point, "rotZ", rot);
				end
			end
		end
		for i, v in ipairs (getElementsByType"deathmatch") do
			local id = getElementID (v);
			local dim = DIMENSION + i;
			setElementData (v, "DMDIM", dim);
			setElementData (v, "DMINT", getElementInterior (v));
			DMS[id] = {};
			for k, child in ipairs (getElementsByType"dm_spawnpoint") do
				if getElementData (child, "caller") == id then
					local x, y, z = getElementPosition (child);
					local rot = getElementData (child, "rotZ");
					table.insert (DMS[id], {pos = {x, y, z}, rot = rot});
				end
			end
		end
	end
);

function buildDeathmatches ()
	exports.mtatr_scoreboard:removeScoreboardColumn("Deathmatch", root);
	for i, v in ipairs (getElementsByType"deathmatch") do
		local id = getElementID (v);
		if isElement (getTeamFromName(id)) then
			getTeamFromName (id):destroy();
		end
		if DM_TYPE == "teams" then
			local r, g, b = getDeathmatchColors ();
			createTeam ("Deathmatch: "..id, r, g, b);
		end
		createDeathmatch (v);
	end
end

function getDeathmatchData (id, data)
	local dm = getElementByID (id);
	return isElement (dm) and getElementData (dm, data);
end

function createDeathmatch (dm)
	local x, y = getElementPosition (dm);
	local w, h = getElementData (dm, "sizeX"), getElementData (dm, "sizeY");
	local col = createColRectangle (x, y, w, h);
	local r, g, b =  200, 0, 0;
	local radar = createRadarArea (x, y, w, h, r, g, b, 125 );
	local dim = getElementData (dm, "DMDIM");
	col:setDimension (dim);
	radar:setDimension (dim);

	addEventHandler ("onColShapeLeave", col,
		function (player, dim_)
			if player and dim_ and isElement (player) and getElementType (player) == "player" then
				if isPlayerInDeathmatch (player) and getPlayerCurrentDeathmatch (player) == dm:getID() then
					outputChatBox ("Deathmatch'i terkediyorsunuz!", player, 255, 0, 0);
				end
			end
		end
	);
end

local slots = {
	"melee",
	"handgun",
	"shotgun",
	"smg",
	"machine_gun",
	"rifle",
	"heavy",
	"projectile",
	"special1",
	"gift",
	"special2",
};

function getDeathmatchWeapons (dm)
	local weapons = {};
	for i, v in ipairs (slots) do
		local dm = getElementByID (dm);
		local weapon = getElementData (dm, v);
		local ammo = getElementData (dm, v.."_ammo") or 0;
		if weapon == 0 and i ~= 1 then
			return
		end
		if weapon and (ammo ~= 0 or i == 1) then
			table.insert (weapons,
				{
					id = weapon,
					ammo = ammo
				}
			);
		end
	end
	return weapons;
end

function getDeathmatchType (dm)
	return dm:find ("Zombi") and "zombie" or "normal";
end
