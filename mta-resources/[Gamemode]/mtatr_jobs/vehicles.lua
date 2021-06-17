vehicle_coords = {
	-- model, x, y, z, rot
	Polis = {
		{596, 1550.46228, -1686.65698, 13.55457, 88},
		{598, 1550.46228, -1691.65698, 13.55457, 88},
		{601, 1548.62781, -1669.49487, 13.56597, 88},
		{599, 1547.01, -1653.88, 13.56, 88},
	},
	["Otobüs Şoförü"] = {
		{431, 1280.24, -1372.75, 13.3, 177},
		{431, 1273.66, -1371.53, 13.41, 177},
		{431, 1282.95, -1348.37, 13.38, 177},
		{431, 1274.72, -1350.35, 13.5, 177},
	},
	Taksici = {
		{438, 490.54, -1546.92, 18.19, 212},
		{420, 493.81, -1553.04, 17.56, 212},
		{420, 483.62, -1535.26, 19.3, 203},
		{438, 491.88, -1534.11, 19.19, 205},
		{420, 497.9, -1545.24, 17.99, 210},
		{420, 504.64, -1554.98, 16.91, 216},
	},
	Pilot = {
		{511, -1390.17, -226.97, 14.15, 329},
		{592, -1315.25, -261.18, 15.15, 310},
	},
};

vehicles 				= {};
delayed 				= {}
VEHICLE_SPAWN_RATE 		= 90;--seconds
VEHICLE_RESPAWN_RATE	= 1;--minutes

addEventHandler ("onVehicleExplode", root, 
	function ()
		setTimer (
			function (_s) 
				if isElement (_s) then 
					if vehicles[_s] then 
						respawnVehicle (_s);
					end	
				end	
			end,	
		VEHICLE_SPAWN_RATE*1000, 1, source);		
	end
);	

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		for i, v in pairs (vehicle_coords) do 
			for _, coord in ipairs (v) do 
				local job = i;
				local model, x, y, z, rot = unpack (coord);
				local veh = createVehicle (model, x, y, z, 0, 0, rot);
				vehicles[veh] = job;
			end
		end	
		setTimer (
			function ()
				for v in pairs (vehicles) do 
					if not isElement (v) then return; end
					if not isTimer (delayed[v]) and not getVehicleController (v) then 
						respawnVehicle (v);
					end
				end	
			end,	
		VEHICLE_RESPAWN_RATE * 60 * 1000, 0);
	end
);	

addEventHandler ("onVehicleExit", root, 
	function ()
		if vehicles[source] then 
			delayed [source] = setTimer (function (s) if isElement (s) then delayed[s] = nil; end end, 1000 * 60, 1, source);
		end	
	end
);	

addEventHandler ("onVehicleStartEnter", root, 
	function (player)
		if not vehicles[source] then return; end 
		local job = getPlayerCurrentJob (player);
		if job ~= vehicles[source] then 
			outputChatBox ("Bu araca binmeniz için "..vehicles[source]:lower().. " mesleğinde olmanız gerekli!", player, 200, 0, 0);
			cancelEvent();
		end
	end
);	

addEvent ("onPlayerLeaveJob");
addEventHandler ("onPlayerLeaveJob", root,
	function ()
		if isPedInVehicle (source) then 
			local veh = getPedOccupiedVehicle (source);
			if vehicles[veh] then 
				removePedFromVehicle (source);
			end
		end
	end
);	