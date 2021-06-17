houses = {};
local console = {};
owners = {};
db = exports.database:dbConnect ();
local maxHouseID = 0;

addEventHandler ("onResourceStart", root, 
	function (res)
		if getResourceName (res) == "database" then 
			db = exports.database:dbConnect();
		elseif res == getThisResource() then 
			local query = "SELECT * FROM fr_housing";
			dbQuery (cacheHouses, {}, db, query);
		end	
	end
);

function cacheHouses (qh)
	local result = dbPoll (qh, 0);
	if next (result) then 
		for i, v in ipairs (result) do
			houses[v.id] = {};
			for column, value in pairs (v) do 
				console[column] = true;
				if column ~= "id" then
					local value = value;
					if column == "location" or column == "offers" then 
						value = fromJSON (value or "[[]]");
					end	
					houses[v.id][column] = value;
					if (maxHouseID < v.id) then
						maxHouseID = v.id;
					end
				end
			end	
			v.owner = tonumber (v.owner);
			if v.owner then 
				if v.owner and not owners[v.owner] then 
					owners[v.owner] = {};
				end	
				if v.owner then 
					table.insert (owners[v.owner], v.id);
				end			
			end		
		end	
	end	
end

function setHouseData (id, key, data)
	if not id or not key then return false; end
	local id = tonumber (id);
	if not id then return false; end
	if not houses[id] then 
		houses[id] = {};
		dbExec (db, "INSERT INTO `fr_housing` (id) VALUES (?)", id);
	end	
	if not console[key] then 
		dbExec(db, "ALTER TABLE `fr_housing` ADD `??` text", key);
		console[key] = true;
	end	
	if houses[id] then 
		dbExec (db, "UPDATE `fr_housing` SET `??` = ? WHERE id = ?", key, data, id);
		local data = data;
		if key == "location" or key == "offers" then 
			data = fromJSON (data or "[[]]");
		end	
		if key == "owner" then 
			if data == nil then 
				local owner = getHouseData (id, "owner");
				for i, v in ipairs (owners[owner] or {}) do 
					if v == id then 
						table.remove (owners[owner], i);
					end
				end
			else
				if not owners[data] then 
					owners[data] = {};
				end
				table.insert (owners[data], id);
			end
		end	
		houses[id][key] = data;
		for i, v in ipairs (getElementsByType"player") do 
			syncHousingData (v, id, key, data);
		end	
	end	
	if (maxHouseID < id) then maxHouseID = id end
end

function getNextSlot ()
	return maxHouseID + 1;
end	

function getHouseData (id, key)
	if not id or not key then return false; end
	if not houses[id] then return false; end
	local data = houses[id][key];
	if data == "true" then 
		data = true;
	elseif data == "false" then 
		data = false;
	end	
	return tonumber (data) or data;
end

function isPlayerOwner (player, id)
	return type (id) == "number" and houses[id] and tonumber (houses[id].owner) == exports.database:getPlayerId (player);
end	

function getHouses ()
	return houses;
end