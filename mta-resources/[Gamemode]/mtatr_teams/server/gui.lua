local invitations = {};

function updateInfo (player)
	local player = isElement (player) and player or source;
	if isPlayerInAGroup (player) then 
		local tbl = {};
		local group = getPlayerGroup (player);
		for i, v in ipairs (getMembersInGroup(group)) do
			table.insert (tbl, 
				{
					name = exports.database:getPlayerData (v, "fr_stats", "last_played_char") or "N/A",
					rank = getMemberRank (v),
					time = getMemberData (v, "join_time"),
					isActive = isElement (exports.database:getPlayerFromID (v)),
					member = v
				}
			);	
		end
		triggerLatentClientEvent (player, "groups:getInfo", player, tbl, getPlayerRank (player));
	end	
end

function getInvitations (player)
	return invitations[player];
end	

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root, 
	function ()
		if not isPlayerInAGroup (source) then return; end
		local id = exports.database:getPlayerId (source);
		local group = getMemberGroup (id);
		for i, v in ipairs (getPlayersInGroup(group)) do  
			updateInfo(v);
		end
	end
);	

addEventHandler ("onPlayerQuit", root,
	function ()
		if not isPlayerInAGroup (source) then return; end
		local id = exports.database:getPlayerId (source);
		local group = getMemberGroup (id);
		setTimer (
			function (group)
				for i, v in ipairs (getPlayersInGroup(group)) do  
					updateInfo(v);
				end
			end,
		1000, 1, group);		
		invitations[source] = nil;
	end
);	

addEvent ("onPlayerRequestGroupMenu", true);
addEventHandler ("onPlayerRequestGroupMenu", root, 
	function ()
		local money = tonumber (get ("*Miktar"));
		local level = tonumber (get ("*Level"));
		triggerClientEvent (client, "onServerRespondGroupMenu", client, isPlayerInAGroup(client), nil, money, level);
	end
);

function setGroupWindow (player, state)
	local money = tonumber (get ("*Miktar"));
	local level = tonumber (get ("*Level"));
	triggerClientEvent (player, "onServerRespondGroupMenu", player, isPlayerInAGroup(player), state, money, level);
end	

addEvent ("groups:requestInfo", true);
addEventHandler ("groups:requestInfo", root,
	function ()
		if isPlayerInAGroup (client) then 
			updateInfo (client);
		end
	end
);	

--events--

addEvent ("groups:kick", true);
addEventHandler ("groups:kick", root, 
	function (id)
		if id == exports.database:getPlayerId (client) then return; end
		if getMemberRank (id) == "Kurucu" then 
			exports.mtatr_hud:dm ("Kurucuyu gruptan çıkaramazsınız.", client, 200, 0, 0);
			return;
		end
		if getMemberRank (id) == getPlayerRank (client) then return; end	
		if getPlayerRank (client) == "Üye" then return; end
		local player = exports.database:getPlayerFromID(id);
		if isElement (player) then 
			exports.mtatr_hud:dm (client:getName().." adlı oyuncu sizi gruptan çıkardı!", player, 200, 0, 0);	
			kickPlayerOut (player);
		else
			kickMemberOut (id);
		end
		local name = exports.database:getPlayerData (id, "fr_stats", "last_played_char") or "N/A";
		exports.mtatr_hud:dm (name.." adlı oyuncu gruptan şutlandı!", client, 200, 0, 0);
	end
);	

addEvent ("groups:promote", true);
addEventHandler ("groups:promote", root, 
	function (id)	
		if promoteMember (client, id) then 
			local player = exports.database:getPlayerFromID(id);
			local name = exports.database:getPlayerData (id, "fr_stats", "last_played_char") or "N/A";
			exports.mtatr_hud:dm (name.." adlı oyuncunun rankı yükseltildi!", client, 0, 200, 0);
			if isElement (player) then 
				exports.mtatr_hud:dm (client:getName().." adlı oyuncu rankınızı yükseltti!", player, 0, 200, 0);
			end	
		end
	end
);	

addEvent ("groups:demote", true);
addEventHandler ("groups:demote", root, 
	function (id)
		if demoteMember (client, id) then 
			local player = exports.database:getPlayerFromID(id);
			local name = exports.database:getPlayerData (id, "fr_stats", "last_played_char") or "N/A";
			exports.mtatr_hud:dm (name.." adlı oyuncunun rankı düşürüldü!", client, 200, 0, 0);
			if isElement (player) and player ~= client then 
				exports.mtatr_hud:dm (client:getName().." adlı oyuncu rankınızı düşürdü!", player, 200, 0, 0);
			end	
		end	
	end
);	

addEvent ("groups:invite", true);
addEventHandler ("groups:invite", root, 
	function (player)
		if isPlayerInAGroup (player) then
			outputChatBox ("Bu oyuncu zaten bir grupta!", client, 200, 0, 0);
			return;
		end
		local group = getPlayerGroup (client);
		exports.mtatr_hud:dm (client:getName().. " sizi "..getGroupName(group).. " adlı grubuna davet ediyor!", player, 0, 200, 0);
		exports.mtatr_hud:dm ("Oyuncu davet edildi!", client, 0, 200, 0);
		if not invitations[player] then 
			invitations[player] = {};
		end
		invitations[player][group] = {name = getGroupName(group), color = {getGroupColor(group)}, inviter = client};
		triggerLatentClientEvent (player, "groups:requestInvitations", player, getInvitations(player));
	end
);	
addEvent ("groups:accept_invite", true);
addEventHandler ("groups:accept_invite", root, 
	function (name)
		local group = getGroupFromName (name);
		if invitations[client] then 
			invitations[client] = nil;
		end
		setPlayerGroup (client, group);
		outputGroupChat (group, client:getName().." gruba girdi!");
		setGroupWindow (client, false);
		setPlayerRank (client, "Üye");
	end
);
	
addEvent ("groups:decline_invite", true);
addEventHandler ("groups:decline_invite", root,
	function (name)
		local group = getGroupFromName (name);
		if invitations[client] and invitations[client][group] then 
			local inviter = invitations[client][group].inviter;
			if isElement (inviter) then 
				outputChatBox (client:getName().. " grup davetinizi geri çevirdi.", inviter, 200, 0, 0);
			end	
			invitations[client][group] = nil;	
			triggerLatentClientEvent (client, "groups:requestInvitations", client, getInvitations(player));
		end	
	end
);	

addEvent ("groups:leave", true);
addEventHandler ("groups:leave", root,
	function ()
		local group = getPlayerGroup (client);
		outputGroupChat (group, client:getName().." gruptan ayrıldı!");
		kickPlayerOut (client);
	end
);

addEvent ("groups:delete", true);
addEventHandler ("groups:delete", root, 
	function (pass)
		local group = getPlayerGroup (client);
		local id = exports.database:getPlayerId (client);
		local pass_ = exports.database:getPlayerData (id, "userinfo", "password");
		local pass = md5(pass);
		if pass ~= pass_ then 
			outputChatBox ("Girdiğiniz şifreler uyuşmuyor, lütfen tekrar kontrol edin.", client, 200, 0, 0);
			return;
		end
		outputGroupChat (group, client:getName().. " grubu sildi!");
		deleteGroup (group)
	end
);	

addEvent ("groups:change_name", true);
addEventHandler ("groups:change_name", root, 
	function (name)
		if name:check() then 
			if doesGroupExist (name) then 	
				outputChatBox("Bu isimde bir grup zaten var. Lütfen başka isim seçin.", client, 200, 0, 0);
				return;
			end
			local money = tonumber (get ("*Miktar"))/2;
			if getPlayerMoney (client) < money then outputChatBox ("Bu işlemi yapabilmek için en az "..money.."₺ paranız olmalı.", client, 200, 0, 0); return; end
			local group = getPlayerGroup (client);
			setGroupName (group, name);	
			outputGroupChat (group, client:getName().. " grup ismini "..name.. " olarak değiştirdi!");
			exports.database:takePlayerMoney (client, money, "Group name change");
		end	
	end
);	

addEvent ("groups:change_tag", true);
addEventHandler ("groups:change_tag", root, 
	function (tag) 
		if tag:check(true) then 
			if getGroupFromTag (tag) then 
				outputChatBox ("Bu tagi başka bir klan kullanıyor. Lütfen başka bir tag seçin.", client, 200, 0, 0);
				return;
			end	
			local money = tonumber (get ("*Miktar"))/4;
			if getPlayerMoney (client) < money then outputChatBox ("Bu işlemi yapabilmek için en az "..money.."₺ paranız olmalı.", client, 200, 0, 0); return; end
			local group = getPlayerGroup (client);
			setGroupTag (group, tag);	
			outputGroupChat (group, client:getName().. " grup tagini "..tag.. " olarak değiştirdi!");
			exports.database:takePlayerMoney (client, money, "Group tag change");
		else 
			outputChatBox ("Geçersiz tag.", client, 255, 0, 0);
		end	
	end
);	

addEvent ("groups:color", true);
addEventHandler ("groups:color", root, 
	function (r, g, b)
		local group = getPlayerGroup (client);
		setGroupColor (group, r, g, b);
	end
);	

addEvent ("groups:transfer", true);
addEventHandler ("groups:transfer", root, 
	function (id)
		if id == exports.database:getPlayerId (client) then 
			outputChatBox ("Bu işlemi kendiniz üstünde uygulayamazsınız!", client, 200, 0, 0);
			return;
		end	
		local group = getPlayerGroup (client);
		setMemberRank (id, "Kurucu");
		kickPlayerOut (client);
	end
);	