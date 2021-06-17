JOB_TYPE = exports.mtatr_main:getTeamsType ();
JOBS = {};

function getJobColors ()
	return exports.mtatr_deathmatches:getDeathmatchColors();
end

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		if next (JOB_LIST) then
			for i, v in ipairs (JOB_LIST) do
				local job = createElement ("job", v.name);
				for weapon, data in pairs (v.weapons) do
					setElementData (job, weapon, data);
				end
				job:setData("group", "Normal");
				for _, spawnpoint in ipairs (v.spawnpoints) do
					local point = createElement ("job_spawnpoint");
					point:setData ("caller", v.name);
					local x, y, z, rot, model = unpack (spawnpoint);
					setElementPosition (point, x, y, z);
					setElementData (point, "rotZ", rot);
					setElementData (point, "model", model);
				end
				for i, v in ipairs (getElementsByType"job") do
					local id = getElementID (v);
					JOBS[id] = {};
					for k, child in ipairs (getElementsByType"job_spawnpoint") do
						if getElementData (child, "caller") == id then
							local x, y, z = getElementPosition (child);
							local rot = getElementData (child, "rotZ");
							local model = getElementData (child, "model");
							table.insert (JOBS[id], {pos = {x, y, z}, rot = rot, model = model});
						end
					end
				end
			end
		end
	end
);

function buildJobs ()
	exports.mtatr_scoreboard:removeScoreboardColumn("Meslek", root);
	for i, v in ipairs (getElementsByType"job") do
		local id = getElementID (v);
		if isElement (getTeamFromName(id)) then
			getTeamFromName (id):destroy();
		end
		if JOB_TYPE == "teams" then
			local r, g, b = exports.mtatr_deathmatches:getDeathmatchColors ();
			createTeam ("Meslek: "..id, r, g, b);
		end
	end
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

function getJobWeapons (job)
	local weapons = {};
	for i, v in ipairs (slots) do
		local job = getElementByID (job);
		local weapon = getElementData (job, v);
		local ammo = getElementData (job, v.."_ammo") or 0;
		if weapon == 0 and i ~= 1 then
			return
		end
		if weapon and (ammo ~= 0 or (i == 1 or i == 10) ) then
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
