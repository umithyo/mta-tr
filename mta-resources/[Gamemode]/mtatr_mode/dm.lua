local levels = {};
local reward_exp = 12

do
	local conf = xmlLoadFile ("levels.xml");
	for i, v in ipairs (xmlNodeGetChildren (conf)) do 
		levels[i] = tonumber (xmlNodeGetValue (v));
	end	
end

function setPlayerCharacterExperience (player, exp)	
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	exports.database:setPlayerCharacterData (player, char, "experience", exp);
	setElementData (player, "char.exp", exp);
end

function getPlayerCharacterExperience (player)
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	return exports.database:getPlayerCharacterData (player, char, "experience") or 0;
end

function givePlayerCharacterExperience (player, exp)
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	setPlayerCharacterExperience (player, (getPlayerCharacterExperience (player) or 0) + exp);
	checkLevel (player);
end

function takePlayerCharacterExperience (player, exp)
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	setPlayerCharacterExperience (player, (getPlayerCharacterExperience (player) or 0) - exp);
end

function setPlayerCharacterLevel (player, level)
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	exports.database:setPlayerCharacterData (player, char, "level", level);
	setElementData (player, "char.level", level);
	setElementData (player, "Seviye", level);
end

function getPlayerCharacterLevel (player)
	local char = exports.mtatr_accounts:getPlayerCurrentCharacter (player);
	return exports.database:getPlayerCharacterData (player, char, "level") or 0;
end	

function increaseLevel (player)
	local level = getPlayerCharacterLevel (player);
	setPlayerCharacterLevel (player, level + 1);
	setPlayerCharacterExperience (player, 0);
	triggerEvent ("onPlayerLevelUp", player, level + 1);
end

local function calculatereward(lvl1, lvl2)
	if lvl1 < lvl2 then 
		local rewardexp = reward_exp + ((lvl2 - lvl1) * 2);
		if reward_exp <= 0 then 
			reward_exp = 11;
		end	
		return math.floor (rewardexp);
	elseif lvl1 >= lvl2 then 
		return 11;
	end	
end

function checkLevel (player)
	local level = getPlayerCharacterLevel (player);
	if level == #levels then return; end
	local exp = getPlayerCharacterExperience (player);
	local next_exp = levels[level];
	if next_exp then 
		if exp >= next_exp then 
			increaseLevel (player);
		end
	end	
end

addEventHandler ("onPlayerWasted", root, 
	function (_, killer)
		if not isElement (killer) then return; end
		if killer == source then return; end
		if exports.mtatr_accounts:isPlayerInGame (killer) and exports.mtatr_accounts:isPlayerInGame (source) then 
			local level1, level2 = getPlayerCharacterLevel (killer), getPlayerCharacterLevel (source);
			local reward = calculatereward (level1, level2);
			givePlayerCharacterExperience (killer, reward);
			if getPlayerCharacterExperience (source) - (reward/2) > 0 then 
				takePlayerCharacterExperience (source, reward/2);
			end
			
		end	
	end
);	

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root, 
	function ()
		local level = getPlayerCharacterLevel (source);
		local exp = getPlayerCharacterExperience (source);
		setElementData (source, "char.level", level or 1);
		setElementData (source, "Seviye", level or 1);
		setElementData (source, "char.exp", exp or 0);
	end
);	

addEvent ("onPlayerLevelUp");
addEventHandler ("onPlayerLevelUp", root, 
	function (level)
		triggerClientEvent (source, "onClientPlayerLevelUp", source, level);
	end
);	

local spree = {}
local damaged = {};
local DAMAGE_SECOND = 30 -- if player is damaged within 30 seconds 

addEventHandler ("onPlayerWasted", root, 
	function (_, killer)
		if killer and killer ~= source then 
			if isElement (killer) then 
				if killer:getType () == "player" then 
					if exports.mtatr_deathmatches:isPlayerInDeathmatch(killer) then 
						if not spree[killer] then 
							spree[killer] = 0
						end	
						spree[killer] = spree[killer] + 1;
						spree[source] = nil;
						if spree[killer] then 
							triggerClientEvent (killer, "spree.show", killer, spree[killer])
						end
					end	
				end	
			end	
		end	
	end	
)

addEventHandler ("onPlayerQuit", root, 
	function ()
		spree[source] = nil;
		damaged[source] = nil;
	end
)	

addEventHandler ("onPlayerDamage", root, 
	function ()
		damaged[source] = getTickCount();
		triggerClientEvent(source, "mode.damaged", source, DAMAGE_SECOND*1000);
	end
);

function isPlayerDamaged(player)
	return getTickCount () - (tonumber(damaged[player]) or 0) <= DAMAGE_SECOND*1000;
end	