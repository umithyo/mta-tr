function buildRooms(rooms_)
	local item = guiGridListGetSelectedItem(duel.gridlist[1]);
	local text = guiGridListGetItemText(duel.gridlist[1], item, 1);
	item=nil;
	guiGridListClear(duel.gridlist[1]);
	for i, v in ipairs (rooms_) do
		local row = guiGridListAddRow(duel.gridlist[1]);
		for k, data in ipairs ({"id", "type"}) do 
			guiGridListSetItemText(duel.gridlist[1], row, k, v[data], false, false);
		end
		local playercount = 0;
		players[v.id]={};
		for player, info in pairs (v.players) do 
			players[v.id][player]=info;
			playercount=playercount+1;
		end	
		guiGridListSetItemText(duel.gridlist[1], row, 3, playercount.."/"..v.limit, false, false);
		guiGridListSetItemText(duel.gridlist[1], row, 4, v.starter:getName(), false, false);
		guiGridListSetItemText(duel.gridlist[1], row, 5, v.bet, false, false);
		if text == v.id then 
			item = row;
		end	
	end
	
	if item then 
		guiGridListSetSelectedItem(duel.gridlist[1], item, 1);
		loadGrid(duel.gridlist[2], tonumber(text));
	end	
end

function getPlayersInRoom(id)
	local tbl={};
	local team1, team2={}, {};
	if players[id] then 
		for player, info in pairs (players[id]) do 
			if info.team == "team1" then 
				table.insert(team1, {player=player, info=info});
			else
				table.insert (team2, {player=player, info=info});
			end
			table.insert(tbl, {player=player, info=info});
		end
		table.sort (tbl, function(a, b) return (a.info.joined or 0) < (b.info.joined or 0); end);
		table.sort (team1, function(a, b) return (a.info.joined or 0) < (b.info.joined or 0); end);
		table.sort (team2, function(a, b) return (a.info.joined or 0) < (b.info.joined or 0); end);
	end
	return tbl, team1, team2;
end

function loadGrid(grid, room)
	guiGridListClear(grid);
	local room = tonumber (room); 
	if not room then return; end
	local _, team1, team2 = getPlayersInRoom(room);	
	local item = guiGridListGetSelectedItem(grid);
	local text = guiGridListGetItemText(grid, item, 1);
	item=nil;
	if team1 and team2 then 
		for k, team in ipairs ({team1, team2}) do
			local catrow = guiGridListAddRow(grid);
			guiGridListSetItemText (grid, catrow, 1, "Takım "..k, true, false);
			for i, v in ipairs (team) do 
				if isElement (v.player) then 
					local row = guiGridListAddRow(grid);
					guiGridListSetItemText(grid, row, 1, v.player:getName(), false, false);
					if text == v.player:getName() then 
						item=row;
					end	
				end
			end	
		end	
	end	
	if item then 
		guiGridListSetSelectedItem(grid, item, 1);
	end	
end

function buildRoom(id, starter)
	guiSetVisible(duel.window[2], true);
	duel.window[2]:setText("Oda #"..id);
	duel.button[5]:setEnabled(true);
	duel.button[7]:setEnabled(true);
	duel.button[8]:setEnabled(true);
	duel.button[6]:setEnabled(true);
	if not starter then 
		duel.button[5]:setEnabled(false);
		duel.button[7]:setEnabled(false);
		duel.button[8]:setEnabled(false);
	else
		duel.button[6]:setEnabled(false);
	end	
	loadGrid(duel.gridlist[3], id);
end

function destroyRoom()
	guiSetVisible(duel.window[2], false);
end