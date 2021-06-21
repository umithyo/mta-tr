_setNametagColor = setPlayerNametagColor;
function setPlayerNametagColor (player, r, g, b)
	local blip = exports.mtatr_playerblips:getPlayerBlip (player);
	if isElement (blip) then
		setBlipColor (blip, r, g, b, 255);
	end
	return _setNametagColor (player, r, g, b);
end

_setPlayerTeam = setPlayerTeam;
function setPlayerTeam (player, team, name)
	if isElement (player) then
		if team == nil then
			local r, g, b =  math.random(1, 255), math.random (1, 255), math.random(1, 255);
			if exports.database:getPlayerData (exports.database:getPlayerId (player), "userinfo", "usercolour") then
				r, g, b = unpack (fromJSON (exports.database:getPlayerData (exports.database:getPlayerId (player), "userinfo", "usercolour")))
			end
			setPlayerNametagColor (player, r, g, b);

			local team = getPlayerTeam (player);
			if isElement (team) then
				if countPlayersInTeam (team) == 1 then
					team:destroy();
				end
			end
			setPlayerName (player, exports.mtatr_accounts:getPlayerCurrentCharacter (player));
			return _setPlayerTeam (player, nil);
		end
		-- if name == true then
			local tag = getGroupData (getGroupFromName (getTeamName (team)), "tag");
			if tag and exports.mtatr_accounts:getPlayerCurrentCharacter (player) then
				local name = "["..tag.."] "..exports.mtatr_accounts:getPlayerCurrentCharacter (player);
				if  #name > 21 then
					name = name:sub (1, 22 - (#name - 22));
				end
				setPlayerName (player, name);
			end
		-- end
		setPlayerNametagColor (player, getTeamColor (team));
		return _setPlayerTeam (player, team);
	end
end

function arePlayersTeammates (player1, player2)
	if TEAM then
		local team1, team2 = isElement (getPlayerTeam (player1)) and getPlayerTeam (player1), isElement (getPlayerTeam (player2)) and getPlayerTeam (player2);
		return team1 and team2 and team1 == team2;
	else
		return player1:getData(TEAM_DATA) ~= nil and player1:getData(TEAM_DATA) == player2:getData(TEAM_DATA);
	end
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function RGBToHex(red, green, blue, alpha)
	if((red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255) or (alpha and (alpha < 0 or alpha > 255))) then
		return nil
	end
	if(alpha) then
		return string.format("#%.2X%.2X%.2X%.2X", red,green,blue,alpha)
	else
		return string.format("#%.2X%.2X%.2X", red,green,blue)
	end
end

function tocomma(number)
	while true do
		number, k = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return number
end

-- To Date
----------->>

function todate(timestamp)
	local timestamp = tonumber(timestamp) or 0
	local year = math.floor(timestamp/31557600)+1970
	local isLeapYear = false
	if ((year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)) then
		isLeapYear = true
	end

	local daysLeft = math.floor((timestamp-((year-1970)*31557600))/86400)+1
	local month = 1
	if (daysLeft <= 31) then
		month = 1
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if ((daysLeft <= 28) or (isLeapYear and daysLeft <= 29)) then
		month = 2
		return daysLeft, month, year
	end
	if (not isLeapYear) then
		daysLeft = daysLeft - 28 else daysLeft = daysLeft - 29 end
	if (daysLeft <= 31) then
		month = 3
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if (daysLeft <= 30) then
		month = 4
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 30
	if (daysLeft <= 31) then
		month = 5
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if (daysLeft <= 30) then
		month = 6
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 30
	if (daysLeft <= 31) then
		month = 7
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if (daysLeft <= 31) then
		month = 8
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if (daysLeft <= 30) then
		month = 9
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 30
	if (daysLeft <= 31) then
		month = 10
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 31
	if (daysLeft <= 30) then
		month = 11
		return daysLeft, month, year
	end
	daysLeft = daysLeft - 30
	month = 12
	if (daysLeft > 31) then daysLeft = 31 end
	return daysLeft + 1, month, year
end

-- To Time
----------->>

function totime(timestamp)
	local timestamp = tonumber(timestamp) or 0
	local timestamp = timestamp - (math.floor(timestamp/86400) * 86400)
	local hours = math.floor(timestamp/3600)
	timestamp = timestamp - (math.floor(timestamp/3600) * 3600)
	local mins = math.floor(timestamp/60)
	local secs = timestamp - (math.floor(timestamp/60) * 60)
	return hours, mins, secs
end

-- Month Number to Text
------------------------>>

local monthTable = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
function getMonthName(month, digits)
	if (not monthTable[month]) then return end
	local month = monthTable[month]
	if (digits) then
		month = string.sub(month, 1, digits)
	end
	return month
end

function string.check (self, tag)
	if #self < MIN_CHAR then
		return false;
	end
	if self:find ("#%x%x%x%x%x%x") then
		return false;
	end
	if self:find ("Deathmatch: ") or self:find ("Meslek: ") then
		return false;
	end
	if tag == true then
		if not string.match(self, "^[%a%d.:,;#'+*~|<>@^!\"$%%&/()=?{}%[%]\\_-]+$") then
			return false;
		end
	end
	return true;
end
