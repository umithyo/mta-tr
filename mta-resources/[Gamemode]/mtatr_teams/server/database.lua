groups = {};
names = {};
members = {};
local console = {
	groups = {},
	members = {},
};
local maxID = 1;
db = exports.database:dbConnect();
local ready = {};

addEventHandler ("onResourceStart", root,
	function (res)
		if getResourceName (res) == "database" then
			db = exports.database:dbConnect();
		end
	end
);

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		-- setmetatable (groups, {
				-- __newindex = function (t, k, v)
					-- rawset (t, k, v);
					-- local group = v;
					-- setmetatable (group, {
							-- __newindex = function (g, j, vl)
								-- rawset (g, j, vl);
								-- for _, m in ipairs (getPlayersInGroup(k)) do
									-- updateInfo(m);
								-- end
								-- iprint ("group update", j, vl)
							-- end
						-- }
					-- );
					-- for _, m in ipairs (getPlayersInGroup(k)) do
						-- updateInfo(m);
					-- end
					-- iprint ("new group", k, v)
				-- end
			-- }
		-- );

		-- setmetatable (members, {
				-- __newindex = function (t, k, v)
					-- rawset (t, k, v);
					-- local member = v;
					-- local group = getMemberGroup(k);
					-- setmetatable (member, {
							-- __newindex = function (g, j, vl)
								-- rawset (g, j, vl);
								-- for _, m in ipairs (getPlayersInGroup(group)) do
									-- updateInfo(m);
								-- end
								-- iprint ("member update", j, vl, g[j])
							-- end
						-- }
					-- );
					-- for _, m in ipairs (getPlayersInGroup(group)) do
						-- updateInfo(m);
					-- end
					-- iprint ("new member", k, v)
				-- end
			-- }
		-- );
		dbQuery (cacheGroups, {}, db, "SELECT * FROM fr_groups");
		dbQuery (cacheMembers, {}, db, "SELECT * FROM fr_group_members");
	end
);

function cacheGroups (qh)
	local result = dbPoll (qh, 0);
	for i, v in ipairs (result) do
		names[v.name] = v.id;
		groups[v.id] = {};

		if (maxID < v.id) then	maxID = v.id; end

		for column, value in pairs (v) do
			if column ~= "id" then
				groups[v.id][column] = value;
				console["groups"][column] = true;
			end
		end
	end
	ready.groups = true;
	if ready.members then
		loadGroups();
	end
end

function cacheMembers (qh)
	local result = dbPoll (qh, 0);
	for i, v in ipairs (result) do
		members[v.user_id] = {};
		for column, value in pairs (v) do
			if column ~= "user_id" then
				members[v.user_id][column] = value;
				console["members"][column] = true;
			end
		end
	end
	ready.members = true;
	if ready.groups then
		loadGroups();
	end
end

function setGroupData (group, key, data)
	if group and key then
		local method = type (group) == "number" and "id" or "name";
		local name = method == "id" and getGroupName (group) or group;

		if not names[name] then
			local id = maxID + 1;
			names[name] = id;
			groups[id] = {};
			groups[id].name = name;
			dbExec (db, "INSERT INTO `fr_groups` (id, name) VALUES (?, ?)", id, name);
			if (maxID < id) then maxID = id; end
		end

		local id = getGroupFromName (name);

		if not console["groups"][key] then
			dbExec(db, "ALTER TABLE `fr_groups` ADD `??` text", key);
			console["groups"][key] = true;
		end

		if groups[id] then
			dbExec (db, "UPDATE `fr_groups` SET `??` = ? WHERE name = ?", key, data, name);
			groups[id][key] = tonumber (data) or data;
			if key == "name" then
				names[data] = id;
				names[name] = nil;
			end
		end
		for _, m in ipairs (getPlayersInGroup(id)) do
			updateInfo(m);
		end
	end
end

function getGroupData (group, key)
	if group and key then
		local method = type (group) == "number" and "id" or "name";
		local group = method == "id" and group or getGroupFromName (group);
		if groups[group] then
			local data = groups[group][key];
			return tonumber (data) or data;
		end
	end
	return false;
end

function setMemberData (member, key, data)
	if member and key then
		local id = tonumber (member) or exports.database:getIDFromAccount (member);

		if not members[id] then
			members[id] = {};
			dbExec (db, "INSERT INTO `fr_group_members` (user_id) VALUES (?)", id);
		end

		if not console["members"][key] then
			dbExec(db, "ALTER TABLE `fr_group_members` ADD `??` text", key);
			console["members"][key] = true;
		end

		if members[id] then
			dbExec (db, "UPDATE `fr_group_members` SET `??` = ? WHERE user_id = ?", key, data, id);
			members[id][key] = tonumber (data) or data;
		end

		local group = getMemberGroup (id);
		for _, m in ipairs (getPlayersInGroup(group)) do
			updateInfo(m);
		end
	end
end

function getMemberData (member, key)
	if member and key then
		local id = tonumber (member) and tonumber (member) or exports.database:getIDFromAccount (member);
		if members[id] then
			local data = members[id][key];
			return tonumber (data) or data;
		end
	end
	return false;
end

function getGroups ()
	local tbl = {};
	for i, v in pairs (groups) do
		local data = v;
		data.id = i;
		table.insert (tbl, data);
	end
	table.sort (tbl, function (a, b) return a.id < b.id end);
	return tbl;
end

function loadGroups ()
	for i, v in ipairs (getElementsByType"team") do
		if not v:getName():find("Deathmatch: ") or v:getName():find("Meslek: ") then
			v:destroy();
		end
	end
	exports.mtatr_scoreboard:removeScoreboardColumn (TEAM_DATA);
	if TEAM then
		for i, v in ipairs (Element.getAllByType("player")) do
			if isPlayerInAGroup (v) then
				setElementData (v, TEAM_DATA, nil);
				local group = getPlayerGroup (v);
				local group_name = getGroupName(group);
				local r, g, b = getGroupColor (group);
				local team = getTeamFromName (group_name);
				if not isElement (team) then
					team = createTeam (group_name, r, g, b);
				end
				setPlayerTeam (v, team);
			end
		end
	else
		exports.mtatr_scoreboard:addScoreboardColumn(TEAM_DATA, root, 6, 120);
		exports.mtatr_scoreboard:scoreboardSetColumnPriority (TEAM_DATA, 6);
		for i, v in ipairs (Element.getAllByType("player")) do
			if isPlayerInAGroup (v) then
				local group = getPlayerGroup (v);
				local r, g, b = getGroupColor (group);
				setElementData (v, TEAM_DATA, getGroupName(group));
				setPlayerNametagColor (v, r, g, b);
			end
		end
	end
end
