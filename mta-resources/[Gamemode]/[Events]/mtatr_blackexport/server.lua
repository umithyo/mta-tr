BLACK_EXPORT_START_RATIO = 10;
BLACK_EXPORT_ABORT_RATIO = 6;
BLACK_EXPORT_PRIZE = math.random (10000, 15000);

blackexport = {
	vehicles = {},
	lastid = 0,
	location = 0,
	locations = {},
	marker_location = {1664.06, 713.35, 9.82},
};

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		for i, v in ipairs (xmlNodeGetChildren (xmlLoadFile("vehicles.xml"))) do 
			local id = xmlNodeGetAttribute(v, "id");
			local name = xmlNodeGetAttribute(v, "name");
			table.insert (blackexport.vehicles, {id = id, name = name});
		end	

		for i, v in ipairs (getElementsByType"black_export_spawn_points") do 
			local x, y, z = getElementPosition (v);
			local _, _, rot = getElementRotation (v);
			table.insert (blackexport.locations,
				{x, y, z, rot}
			)
		end	
	end
);	

local function blackexport_abort ()
	if isBlackExportVehicle (source) then 
		blackexport.abort(_, false);
	end	
end
local function blackexport_winner (element, dim)
	if isElement (element) and dim and getElementType (element) == "vehicle" and isBlackExportVehicle (element) then
		blackexport.abort(getVehicleController (element), true);
	end	
end

local function blackexport_jacked (player, seat, jackedFrom)
	if isElement (blackexport.vehblip) then 
		setElementVisibleTo (blackexport.vehblip, root, true);
	end	
	if jackedFrom then 
		exports.mtatr_hud:dmn (player:getName().. ", "..jackedFrom:getName().. " adlı oyuncudan aracı çaldı.");
	else
		exports.mtatr_hud:dmn (player:getName().. " black export aracını aldı! Bitiş noktasına yetişmeden aracı al, ödülü kap!");
	end	
end

local function blackexport_exit (player, _, jacker)
	if isElement (blackexport.vehblip) then 
		setElementVisibleTo (blackexport.vehblip, root, false);
	end	
end

function blackexport.abort (responsible_element, won)
	
	if isElement (blackexport.vehicle) then 
		removeEventHandler ("onVehicleEnter", blackexport.vehicle, blackexport_jacked);
		removeEventHandler ("onVehicleExit", blackexport.vehicle, blackexport_exit);
		removeEventHandler ("onVehicleExplode", blackexport.vehicle, blackexport_abort);
		blackexport.vehicle:destroy();
	end		
	
	if isTimer (blackexport.aborttimer) then 
		killTimer (blackexport.aborttimer);
	end
	
	if isElement (blackexport.marker) then 
		removeEventHandler ("onMarkerHit", blackexport.marker, blackexport_winner);
		blackexport.marker:destroy();
	end
	
	if isElement (blackexport.blip) then 
		blackexport.blip:destroy();
	end	
	
	if isElement (blackexport.indicator) then 
		blackexport.indicator:destroy();
	end	
	
	if isElement (blackexport.vehblip) then 
		blackexport.vehblip:destroy();
	end	
	
	if responsible_element and won == true then
		exports.mtatr_hud:dmn ("Black export bitti. "..responsible_element:getName().." aracı bulup teslim etmeyi başardı.", root);
		exports.database:givePlayerMoney (responsible_element, BLACK_EXPORT_PRIZE, "Black Export");
	elseif won == false then 
		exports.mtatr_hud:dmn ("Black export bitti. Araç yok edildi.", root);
	else
		exports.mtatr_hud:dmn ("Black export bitti. Kimse aracı bulamadı.", root);
	end	
	
	triggerClientEvent (root, "blackexport.getvehicle", resourceRoot);
	
	triggerEvent ("onMissionFinished", resourceRoot, "Black Export");
end

function stopBlackExport ()
	blackexport.abort();
end	

function blackexport.start (force)

	BLACK_EXPORT_PRIZE = math.random (10000, 15000);
	
	local id, location;
	repeat 
		id = math.random(#blackexport.vehicles);
		location = blackexport.locations[math.random(#blackexport.locations)];
	until id ~= lastid and location ~= blackexport.location;
	blackexport.lastid, blackexport.location = id, location;
	
	local veh = blackexport.vehicles[id].id;
	local name = blackexport.vehicles[id].name;
	local x, y, z, rot = unpack (location);
	blackexport.vehicle = createVehicle (veh, x, y, z, 0, 0, rot, "MTA-TR.com");
	addEventHandler ("onVehicleExplode", blackexport.vehicle, blackexport_abort);
	addEventHandler ("onVehicleEnter", blackexport.vehicle, blackexport_jacked);
	addEventHandler ("onVehicleExit", blackexport.vehicle, blackexport_exit);
	
	blackexport.indicator = createMarker (x, y, z, "arrow", .8, 45, 207, 255, 100);
	attachElements (blackexport.indicator, blackexport.vehicle, 0, -.2, 1.5);
	
	local mx, my, mz = unpack (blackexport.marker_location);
	blackexport.marker = createMarker (mx, my, mz, "cylinder", 7.0, 20, 251, 213, 125);
	blackexport.blip = createBlip (mx, my, mz, 11);
	addEventHandler ("onMarkerHit", blackexport.marker, blackexport_winner);
	
	if not force then 
		triggerClientEvent (root, "blackexport.getvehicle", resourceRoot, name, BLACK_EXPORT_ABORT_RATIO * 60 * 1000);
	end	
	
	blackexport.vehblip = createBlipAttachedTo (blackexport.vehicle, 41);
	exports.mtatr_utils:flashBlip (blackexport.vehblip, true);
	
	outputChatBox ("Black export başladı. "..name.." aracını bulup sarı buldozere getiren ilk kişi "..BLACK_EXPORT_PRIZE.."₺ kazanacak." , root, 255, 102, 0);
	
	return true;
end

function startBlackExport (arg)
	return blackexport.start (arg);
end	

addEvent ("blackexport.getvehicle", true)
addEventHandler ("blackexport.getvehicle", root, 
	function ()
		if isElement (blackexport.vehicle) then 
			local name = getVehicleName (blackexport.vehicle);
			local time = exports.mtatr_engines:getMissionTimerDetails("Black Export");
			triggerClientEvent (client, "blackexport.getvehicle", resourceRoot, name, time)
		end	
	end
);	

addEvent ("onPlayerCharacterLogin");
addEventHandler ("onPlayerCharacterLogin", root, 
	function ()
		if isElement (blackexport.vehblip) then 
			exports.mtatr_utils:flashBlip (blackexport.vehblip, true, source);
		end
	end
);	

function isBlackExportVehicle (vehicle)
	return vehicle == blackexport.vehicle;
end	