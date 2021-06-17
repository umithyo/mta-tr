function setPlayerData (player, key, data)
	local id = exports.database:getPlayerId (player);
	setMemberData (id, key, data);
end

function getPlayerData (player, key)
	local id = exports.database:getPlayerId (player);
	return getMemberData (id, key, data);
end

function isPlayerInAGroup (player)
	return getPlayerGroup (player) ~= false;
end

function getPlayerGroup (player)
	return getPlayerData (player, "group_id")
end

function getMemberGroup (id)
	return getMemberData (id, "group_id");
end

function setMemberGroup (id, group)
	setMemberData (id, "group_id", group);
	setMemberData (id, "join_time", getRealTime().timestamp);
end

function setPlayerGroup (player, group)
	local canhe, err = canPlayerJoinGroup(player);
	if not canhe then 
		exports.mtatr_hud:dm (err, player, 200, 0, 0);
		return;
	end	
	local id = exports.database:getPlayerId (player);
	setMemberGroup (id, group);
	local name = getGroupName (group);
	local r, g, b = getGroupColor (group);
	if TEAM then 
		local team = getTeamFromName (name);
		if not isElement (team) then 
			team = createTeam (name, r, g, b);
		end	
		setPlayerTeam (player, team);
	else
		player:setData (TEAM_DATA, name);
		setPlayerNametagColor (player, r, g, b);
		local tag = getGroupData (getGroupFromName (name), "tag");
		if tag and exports.mtatr_accounts:getPlayerCurrentCharacter (player) then 
			local name = tag..exports.mtatr_accounts:getPlayerCurrentCharacter (player);
			if  #name > 22 then 
				name = name:sub (1, 22 - (#name - 22));
			end
			setPlayerName (player, name);	
		end	
	end
end	

function canPlayerCreateGroup (player, name, tag)
	if isPlayerInAGroup (player) then 
		return false, "Grup kurmak için şuanki grubunuzdan çıkmanız gerekmektedir.";
	end	
	if doesGroupExist (name) then 	
		return false, "Bu isimde bir grup zaten var. Lütfen başka isim seçin.";
	end
	if getGroupFromTag (tag) then 
		return false, "Bu tagi başka bir klan kullanıyor. Lütfen başka bir tag seçin.";
	end	
	local money = tonumber (get ("*Miktar"));
	local level = tonumber (get ("*Level"));
	if getPlayerMoney (player) < money then 
		return false, "Grup oluşturmak için yeterli miktarda paranız yok.";
	end
	if exports.mtatr_mode:getPlayerCharacterLevel (player) < level then 
		return false, "Grup oluşturmak için en az "..level.." seviye karakteriniz olmalı.";
	end	
	return true;
end

function canPlayerJoinGroup (player)
	if isPlayerInAGroup (player) then 
		return false, "Gruba girmek için şuanki grubunuzdan çıkmanız gerekmektedir.";
	end	
	return true;
end

function kickMemberOut (id)
	local group = getPlayersInGroup(getMemberGroup(id));
	dbExec (db, "DELETE FROM fr_group_members WHERE user_id = ?", id);
	members[id] = nil;
	for i, v in ipairs (group) do  
		updateInfo(v);
	end
end

function kickPlayerOut (player)
	if isElement (player) then 
		local id = exports.database:getPlayerId(player);	
		kickMemberOut (id);
		if TEAM then 
			setPlayerTeam (player, nil);
		end	
		player:setData(TEAM_DATA, nil);
		setGroupWindow (player, false);
		local r, g, b =  math.random(1, 255), math.random (1, 255), math.random(1, 255);
		if exports.database:getPlayerData (exports.database:getPlayerId (player), "userinfo", "usercolour") then 
			r, g, b = unpack (fromJSON (exports.database:getPlayerData (exports.database:getPlayerId (player), "userinfo", "usercolour")))
		end	
		setPlayerName (player, exports.mtatr_accounts:getPlayerCurrentCharacter (player));
		setPlayerNametagColor (player, r, g, b);
	end	
end	

--ranks 

function getMemberRank (member)
	return getMemberData (member, "rank_id");
end	

function setMemberRank (member, rank)
	setMemberData (member, "rank_id", rank);
end	

function getPlayerRank (player)
	local id = exports.database:getPlayerId(player);
	return getMemberRank (id);
end

function setPlayerRank (player, rank)
	local id = exports.database:getPlayerId(player);
	setMemberRank (id, rank);
end	

function getMembersByRank (group, rank)
	local tbl = {};
	for i, v in ipairs (getMembersInGroup (group)) do 
		if getMemberRank (v) == rank then 
			table.insert (tbl, v);
		end
	end
	return tbl;
end

function promoteMember (promoter, player)
	if getPlayerRank (promoter)~= "Kurucu" then 
		exports.mtatr_hud:dm ("Rank yükseltmek için kurucu olmanız gerek.", promoter, 200, 0, 0);
		return false;
	end	
	if getMemberRank (player) == "Kurucu" then 
		exports.mtatr_hud:dm ("Oyuncu rankı en üst seviyede.", promoter, 200, 0, 0);
		return false;
	end
	if getMemberRank (player) == "Lider" then 
		-- setMemberRank (player, "Kurucu");	
		exports.mtatr_hud:dm ("Oyuncu rankı en üst seviyede.", promoter, 200, 0, 0);
		return false
	elseif getMemberRank (player) == "Üye" then 
		setMemberRank (player, "Kıdemli");
	elseif getMemberRank (player) == "Kıdemli" then 
		setMemberRank (player, "Yrd. Lider");
	elseif getMemberRank (player) == "Yrd. Lider" then 
		setMemberRank (player, "Lider");
	end	
	return true;
end

function demoteMember (demoter, player) 
	local rank = getMemberRank (player);
	local group = getPlayerGroup (demoter);
	if getPlayerRank (demoter) ~= "Kurucu" then 
		exports.mtatr_hud:dm ("Rank indirmek için kurucu olmanız gerek.", demoter, 200, 0, 0);
		return false;
	end
	if rank == getPlayerRank (demoter) and exports.database:getPlayerId (demoter) ~= player then 
		exports.mtatr_hud:dm ("Aynı ranka sahip üyenin rankını indiremezsiniz.", demoter, 200, 0, 0);
		return false;
	end	
	if rank == "Kurucu" then 
		if #getMembersByRank (group, "Kurucu") == 1 then 
			exports.mtatr_hud:dm ("Bu işlemi yapmak için başka birini kuruculuğa yükseltmeniz gerekmektedir.", demoter, 200, 0, 0);
			return false;
		end
	end
	if rank == "Üye" then 
		return false;
	end
	if rank == "Lider" then 
		setMemberRank (player, "Yrd. Lider");
	elseif rank == "Yrd. Lider" then 
		setMemberRank (player, "Kıdemli");
	elseif rank == "Kıdemli" then 
		setMemberRank (player, "Üye");
	elseif rank == "Kurucu" then 
		setMemberRank (player, "Lider");
	end
	return true;
end

function chatGroup (player, msg)
	local group = getPlayerGroup (player);
	local r, g, b = getGroupColor (group);
	local name = getGroupName (group);
	for i, v in ipairs (getPlayersInGroup(group)) do 
		outputChatBox ("[GRUP] "..player:getName()..":#ffffff "..msg, v, r, g, b, true);
	end	
end

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root,
	function ()
		if isPlayerInAGroup (source) then 
			local group = getPlayerGroup (source);
			local name = getGroupName (group);
			local r, g, b = getGroupColor (group)
			if TEAM then 
				local team = getTeamFromName (name);
				if not isElement (team) then
					team = createTeam (name, r, g, b);
				end
				setPlayerTeam (source, team);
			else
				source:setData (TEAM_DATA, name);
				setPlayerNametagColor (source, r, g, b);
			end
		end	
	end,
true, "high+7" );	

addEventHandler ("onPlayerQuit", root, 
	function ()
		if TEAM then 
			local team = getPlayerTeam (source);
			if isElement (team) then
				if countPlayersInTeam (team) == 1 then 
					team:destroy();
				end
			end	
		end
	end
);	