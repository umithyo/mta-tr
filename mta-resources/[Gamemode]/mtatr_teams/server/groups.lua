function getGroupFromName (name)
	return tonumber (names[name]);
end

function getGroupName (group)
	return tostring (getGroupData (group, "name"));
end

function getGroupColor (group)
	return unpack (fromJSON (getGroupData (group, "colour")));
end	

function getGroupFromTag (tag)
	for i, v in ipairs (getGroups()) do 
		if getGroupTag (v.id) == tag then 
			return v.id;
		end
	end	
end	

function getGroupTag (group)
	return getGroupData (group, "tag");
end	

function getMembersInGroup (group)
	local tbl = {};
	for i, v in pairs (members) do 
		if v.group_id == group then 
			table.insert (tbl, i);
		end
	end
	table.sort (tbl, 
		function (a, b)
			return (getMemberData (a, "join_time") or math.huge) < (getMemberData (b, "join_time") or math.huge);
		end
	);	
	return tbl;
end	

function getPlayersInGroup (group)
	local tbl = {};
	local g_members = getMembersInGroup (group);
	for i, v in ipairs (g_members) do 
		if isElement (exports.database:getPlayerFromID(v)) then 
			table.insert (tbl, exports.database:getPlayerFromID(v));
		end
	end
	return tbl;
end

function doesGroupExist (name)
	return getGroupData (name, "name");
end	

function createGroup (name, tag, color, creator)
	if name:check() and tag:check(true) then 
		local canhe, err = canPlayerCreateGroup (creator, name, tag);
		if not canhe then 
			exports.mtatr_hud:dm (err, creator, 200, 0, 0);
			return;
		end	
		-- setGroupData (name, "tag", tag);
		setGroupData (name, "colour", (color and toJSON (color)) or toJSON (COLOR));
		setGroupData (name, "creation_time", getRealTime().timestamp);
		setGroupTag (name, tag);
		local group = getGroupFromName (name);
		setPlayerGroup (creator, group);
		setPlayerRank (creator, "Kurucu");
		setGroupWindow(creator, false);
		setGroupWindow (creator, true);
		local money = tonumber (get ("*Miktar"));
		exports.database:takePlayerMoney (creator, money, "Group Creation");
	else
		exports.mtatr_hud:dm ("Geçersiz klan ismi.", creator, 200, 0, 0);
	end
end

function deleteGroup (group)
	for i, v in ipairs (getPlayersInGroup(group)) do 
		kickPlayerOut (v);
	end
	for i, v in ipairs (getMembersInGroup(group)) do 
		kickMemberOut (v);
	end
	dbExec (db, "DELETE FROM fr_groups WHERE id = ?", group);
	local name = getGroupName (group);
	names[name] = nil;
	groups[group] = nil;
	triggerEvent ("onGangDeleted", resourceRoot, group);
end	

function outputGroupChat (group, msg)
	local r, g, b = getGroupColor (group);
	for i, v in ipairs (getPlayersInGroup(group)) do 
		outputChatBox (msg, v, r, g, b);
	end
end	

function setGroupName (group, name)
	setGroupData (group, "name", name);
	if TEAM then
		local team = getPlayersInGroup(group)[1]:getTeam();
		setTeamName (team, name);
	else
		for i, v in ipairs (getPlayersInGroup(group)) do 
			v:setData (TEAM_DATA, name);
		end
	end	
end

function setGroupTag (group, tag)
	setGroupData (group, "tag", tag);
	for i, player in ipairs (getPlayersInGroup(group)) do
		if tag and exports.mtatr_accounts:getPlayerCurrentCharacter (player) then 
			local name = "["..tag.."]"..exports.mtatr_accounts:getPlayerCurrentCharacter (player);
			if  #name > 22 then 
				name = name:sub (1, 22 - (#name - 22));
			end
			setPlayerName (player, name);	
		end	
	end	
end

function setGroupColor (group, r, g, b)
	setGroupData (group, "colour", toJSON ({r, g, b}));
	for i, v in ipairs (getPlayersInGroup(group)) do 
		setPlayerNametagColor (v, r, g, b);
	end	
	if TEAM then 
		local team = getPlayersInGroup(group)[1]:getTeam();
		setTeamColor (team, r, g, b);
	end
	for i, v in ipairs (getPlayersInGroup(group)) do 
		triggerEvent ("onPlayerGangColourChange", v, r, g, b);
	end	
end	