local root = getRootElement()
local scoresRoot = getResourceRootElement(getThisResource())

local scoreColumns = {
	["Oyun Modu"] = {2, 80},
	Skor = {3, 60},
	["Ölüm"] = {4, 60},
	Para = {5, 90},
	Seviye = {6, 40, exports.mtatr_main:getTeamsType() == "scoreboard"},
	Deathmatch = {7, 120, exports.mtatr_main:getTeamsType() == "scoreboard"},
	["Görev"] = {8, 120, exports.mtatr_main:getTeamsType() == "scoreboard"},
	FPS = {9, 40},
	["Ülke"] = {10, 40},
}
local isColumnActive = {}

local KDR_DECIMAL_PLACES = 2

--http://lua-users.org/wiki/SimpleRound
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local function setScoreData (element, column, data)
	setElementData(element, column, data)
end

local function resetScores (element)
	local status = "Alive"
	if isPedDead(element) then
		status = "Dead"
	end
	setScoreData(element, "status", status)
end

local function updateRatio (element)
	local deaths = getElementData(element, "Ölüm")
	if deaths == 0 then
		setScoreData(element, "ratio", "-")
	else
		local kdr = round(getElementData(element, "Skor") / deaths, KDR_DECIMAL_PLACES)
		setScoreData(element, "ratio", tostring(kdr))
	end
end

function updateActiveColumns ()
	for column, priority in pairs(scoreColumns) do
		local cond = priority[3];
		if cond == true or cond == nil then
			isColumnActive[column] = true
			exports.mtatr_scoreboard:addScoreboardColumn(column, root, priority[1], priority[2])
			exports.mtatr_scoreboard:scoreboardSetColumnPriority (column, priority[1])
		end
	end
end

addEventHandler("onResourceStart", scoresRoot,
	function ()
		updateActiveColumns()
		for i, player in ipairs(getElementsByType("player")) do
			resetScores(player)
		end
	end
)

addEventHandler("onResourceStop", scoresRoot,
	function ()
		for column in pairs(scoreColumns) do
			if isColumnActive[column] then
				exports.mtatr_scoreboard:removeScoreboardColumn(column)
			end
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function ()
		resetScores(source)
	end
)

addEventHandler("onPlayerWasted", root,
	function (ammo, killer, weapon)
		if exports.mtatr_accounts:isPlayerLoggedIn (source) then
			local s_id = exports.mtatr_accounts:getPlayerCurrentCharacter(source);
			if killer then
				if killer ~= source then
					if exports.mtatr_accounts:isPlayerLoggedIn(killer) then
						local k_id = exports.mtatr_accounts:getPlayerCurrentCharacter(killer);
						-- k iller killed victim
						setScoreData(source, "Ölüm", (getElementData(source, "Ölüm") or 0) + 1)
						setScoreData(killer, "Skor", (getElementData(killer, "Skor") or 0) + 1)
						exports.database:setPlayerCharacterData (killer, k_id, "kills", (getElementData(killer, "Skor") or 0));
						if isColumnActive["ratio"] then
							updateRatio(killer)
							updateRatio(source)
						end
					end
				else
					-- victim killed himself
					setScoreData(source, "Ölüm", (getElementData(source, 	"Ölüm") or 0) + 1)
				end
			else
				-- victim died
				setScoreData(source, "Ölüm", (getElementData(source, "Ölüm") or 0) + 1)
				if isColumnActive["ratio"] then
					updateRatio(source)
				end
			end
			exports.database:setPlayerCharacterData (source, s_id, "deaths", (getElementData(source, "Ölüm") or 0));
			setScoreData(source, "status", "Dead")

		end
	end
)

addEventHandler("onPlayerSpawn", root,
	function ()
		setScoreData(source, "status", "Alive")
	end
)

addEvent("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root,
	function (char)
		local kills = exports.database:getPlayerCharacterData(source, char, "kills") or 0;
		local deaths = exports.database:getPlayerCharacterData(source, char, "deaths") or 0;
		local d= {
			["Skor"] = kills,
			["Ölüm"] = deaths,
		}
		for i, v in pairs (d) do
			setElementData (source, i, v);
		end
	end
);

addCommandHandler("score",
	function (player)
		if player then
			for column in pairs(scoreColumns) do
				if column == "status" then
						break
				end
				if isColumnActive[column] then
					exports.mtatr_scoreboard:addScoreboardColumn(column)
					outputConsole(column .. ": " .. getElementData(player, column), player)
				end
			end
		end
	end
)
