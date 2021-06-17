function table.find (tbl, index, value)
	for i, v in pairs (tbl) do 
		if v[index] == value then 
			return i;
		end
	end
	return false;
end	

local mods = {};
local mods_ordered = {};

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		local meta = xmlLoadFile ("meta.xml");
		for i, v in ipairs (xmlNodeGetChildren (meta)) do 
			if xmlNodeGetName(v) == "file" then
				local name = xmlNodeGetAttribute (v, "name");
				if name then 
					local dir = xmlNodeGetAttribute (v, "src");
					local model = xmlNodeGetAttribute (v, "model");
					local type = xmlNodeGetAttribute (v, "mod_type");
					local background = xmlNodeGetAttribute (v, "background") == "true";
					local file = fileOpen (dir);
					local size = fileGetSize (file)/1000000;
					fileClose(file);
					if not table.find (mods, "name", name) then 
						local txd, dff;
						if dir:find (".txd") then 
							txd = dir;
						else
							dff = dir;
						end			
						local info = {name = name, size = size, model = model, type = type, background = background};
						if not mods_ordered[type] then 
							mods_ordered[type] = {};
						end
						if txd then 
							info.txd = txd;
							table.insert (mods, info);
							table.insert (mods_ordered[type], info);
						else
							info.dff = dff;
							table.insert (mods, info);
							table.insert (mods_ordered[type], info);
						end	
					else			
						local index = table.find (mods, "name", name);
						local tbl = mods[index];
						local txd, dff;
						if tbl then 
							if dir:find (".txd") then 
								txd = dir;
							else
								dff = dir;
							end	
							if txd then 
								tbl.txd = txd;
							else
								tbl.dff = dff;
							end	
							tbl.size = tbl.size + size;
						end	
					end
				end	
			end
		end
	end
);	

addEvent ("onClientRequestList", true);
addEventHandler ("onClientRequestList", root, 
	function ()
		triggerLatentClientEvent (client, "onClientDownloadList", client, mods, mods_ordered);
	end
);	