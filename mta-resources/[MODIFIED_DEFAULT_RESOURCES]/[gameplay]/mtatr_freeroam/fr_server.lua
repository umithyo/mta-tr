function givePlayerMoney (...)
	return exports.database:givePlayerMoney (...);
end

function takePlayerMoney (...)
	return exports.database:takePlayerMoney (...);
end

function setPlayerMoney (...)
	return exports.database:takePlayerMoney (...);
end

g_Root = getRootElement()
g_ResRoot = getResourceRootElement(getThisResource())
g_PlayerData = {}
g_VehicleData = {}
local chatTime = {}
local lastChatMessage = {}

g_ArmedVehicles = {
	[425] = true,
	[447] = true,
	[520] = true,
	[430] = true,
	[464] = true,
	[432] = true
}
g_Trailers = {
	[606] = true,
	[607] = true,
	[610] = true,
	[590] = true,
	[569] = true,
	[611] = true,
	[584] = true,
	[608] = true,
	[435] = true,
	[450] = true,
	[591] = true
}

g_RPCFunctions = {
	addPedClothes = { option = 'clothes', descr = 'Modifying clothes' },
	addVehicleUpgrade = { option = 'upgrades', descr = 'Adding/removing upgrades' },
	fadeVehiclePassengersCamera = true,
	fixVehicle = { option = 'repair', descr = 'Repairing vehicles' },
	giveMeVehicles = { option = 'createvehicle', descr = 'Creating vehicles' },
	giveMeWeapon = { option = 'weapons.enabled', descr = 'Getting weapons' },
	givePedJetPack = { option = 'jetpack', descr = 'Getting a jetpack' },
	killPed = { option = 'kill', descr = 'Killing yourself' },
	removePedClothes = { option = 'clothes', descr = 'Modifying clothes' },
	removePedFromVehicle = true,
	removePedJetPack = { option = 'jetpack', descr = 'Removing a jetpack' },
	removeVehicleUpgrade = { option = 'upgrades', descr = 'Adding/removing upgrades' },
	setElementAlpha = { option = 'alpha', descr = 'Changing your alpha' },
	setElementPosition = true,
	setElementInterior = true,
	setMyGameSpeed = { option = 'gamespeed.enabled', descr = 'Setting game speed' },
	setMySkin = { option = 'setskin', descr = 'Setting skin' },
	setPedAnimation = { option = 'anim', descr = 'Setting an animation' },
	setPedFightingStyle = { option = 'setstyle', descr = 'Setting fighting style' },
	setPedGravity = { option = 'gravity.enabled', descr = 'Setting gravity' },
	setPedStat = { option = 'stats', descr = 'Changing stats' },
	setTime = { option = 'time.set', descr = 'Changing time' },
	setTimeFrozen = { option = 'time.freeze', descr = 'Freezing time' },
	setVehicleColor = true,
	setVehicleHeadLightColor = true,
	setVehicleOverrideLights = { option = 'lights', descr = 'Forcing lights' },
	setVehiclePaintjob = { option = 'paintjob', descr = 'Applying paintjobs' },
	setVehicleRotation = true,
	setWeather = { option = 'weather', descr = 'Setting weather' },
	spawnMe = true,
	warpMe = { option = 'warp', descr = 'Warping' },
	setMyPos = true
}

g_OptionDefaults = {
	alpha = true,
	anim = true,
	clothes = true,
	createvehicle = true,
	gamespeed = {
		enabled = true,
		min = 0.0,
		max = 3
	},
	gravity = {
		enabled = true,
		min = 0,
		max = 0.1
	},
	jetpack = true,
	kill = true,
	lights = true,
	paintjob = true,
	repair = true,
	setskin = true,
	setstyle = true,
	spawnmaponstart = true,
	spawnmapondeath = true,
	stats = true,
	time = {
		set = true,
		freeze = true
	},
	upgrades = true,
	warp = true,
	weapons = {
		enabled = true,
		vehiclesenabled = true,
		disallowed = {},
		kniferestrictions = true
	},
	weather = true,
	welcometextonstart = true,
	vehicles = {
		maxidletime = 60000,
		idleexplode = true,
		maxperplayer = 2,
		disallowed = {}
	}
}

function getOption(optionName)
	local option = get(optionName:gsub('%.', '/'))
	if option then
		if option == 'true' then
			option = true
		elseif option == 'false' then
			option = false
		end
		return option
	end
	option = g_OptionDefaults
	for i,part in ipairs(optionName:split('.')) do
		option = option[part]
	end
	return option
end

addEventHandler('onResourceStart', g_ResRoot,
	function()
		table.each(getElementsByType('player'), joinHandler)
	end
)

function joinHandler(player)
	if not player then
		player = source
	end
	local r, g, b = math.random(50, 255), math.random(50, 255), math.random(50, 255)
	if not player then return end
	g_PlayerData[player] = { vehicles = {} }
	if not exports.mtatr_teams:isPlayerInAGroup(player) then
		setPlayerNametagColor(player, r, g, b);
		g_PlayerData[player].blip = createBlipAttachedTo(player, 0, 2, r, g, b, 0)
	end
	if g_FrozenTime then
		clientCall(player, 'setTimeFrozen', true, g_FrozenTime[1], g_FrozenTime[2], g_FrozenWeather)
	end
	if getOption('welcometextonstart') then
		outputChatBox("Freeroam'a hoşgeldiniz", player, 0, 255, 0)
		outputChatBox("F1'e basarak menüyü gizleyip açabilirsiniz.", player, 0, 255, 0)
	end
end
addEventHandler('onPlayerJoin', g_Root, joinHandler)

addEvent('onLoadedAtClient', true)
addEventHandler('onLoadedAtClient', g_ResRoot,
	function()
		if getOption('spawnmaponstart') and isPedDead(client) then
			clientCall(client, 'showWelcomeMap')
		end
	end,
	false
)

addEventHandler('onPlayerWasted', g_Root,
	function()
		if not getOption('spawnmapondeath') then
			return
		end
		local player = source
		setTimer(
			function()
				if isPedDead(player) then
					clientCall(player, 'showMap')
				end
			end,
			2000,
			1
		)
	end
)

addEvent('onClothesInit', true)
addEventHandler('onClothesInit', resourceRoot,
	function()
		local result = {}
		local texture, model
		-- get all clothes
		result.allClothes = {}
		local typeGroup, index
		for type=0,17 do
			typeGroup = {'group', type = type, name = getClothesTypeName(type), children = {}}
			table.insert(result.allClothes, typeGroup)
			index = 0
			texture, model = getClothesByTypeIndex(type, index)
			while texture do
				table.insert(typeGroup.children, {id = index, texture = texture, model = model})
				index = index + 1
				texture, model = getClothesByTypeIndex(type, index)
			end
		end
		-- get current player clothes { type = {texture=texture, model=model} }
		result.playerClothes = {}
		for type=0,17 do
			texture, model = getPedClothes(client, type)
			if texture then
				result.playerClothes[type] = {texture = texture, model = model}
			end
		end
		triggerClientEvent(client, 'onClientClothesInit', resourceRoot, result)
	end
)

addEvent('onPlayerGravInit', true)
addEventHandler('onPlayerGravInit', resourceRoot,
	function()
		triggerClientEvent(root, 'onClientPlayerGravInit', resourceRoot, getPedGravity(client))
	end
)

function setMySkin(skinid)
	if isPedDead(source) then

	else
		setElementModel(source, skinid)
	end
	setCameraTarget(source, source)
	setCameraInterior(source, getElementInterior(source))
end

function spawnMe(x, y, z)
	if not x then
		x, y, z = getElementPosition(source)
	end
	if isPedTerminated(source) then
		repeat until spawnPlayer(source, x, y, z, 0, math.random(9, 288))
	else
		spawnPlayer(source, x, y, z, 0, getPedSkin(source))
	end

	if ( getOption('weapons.kniferestrictions') ) then
		setPlayerKnifeRestricted ( client )
	end

	setCameraTarget(source, source)
	setCameraInterior(source, getElementInterior(source))
end

--TOGGLE WARPING
local toggle_warp = {};
addEvent ("fr.toggle_warp", true);
addEventHandler ("fr.toggle_warp", root,
	function (state)
		toggle_warp[client] = state;
	end
);

function warpMe(targetPlayer)
	if exports.mtatr_deathmatches:isPlayerInDeathmatch (targetPlayer)
	-- or exports.mtatr_jobs:isPlayerInJob (targetPlayer)
	or exports.mtatr_civ:getPlayerMission(targetPlayer)
	or getElementData (targetPlayer, "inevent") then
		errMsg ("Bu oyuncuya ışınlanamazsın.", source);
		return;
	end
	if toggle_warp[targetPlayer] then
		if isPedDead(source) then
			spawnMe()
		end

		local vehicle = getPedOccupiedVehicle(targetPlayer)
		local interior = getElementInterior(targetPlayer)
		if not vehicle then
			-- target player is not in a vehicle - just warp next to him
			local x, y, z = getElementPosition(targetPlayer)
			clientCall(source, 'setPlayerPosition', x + 2, y, z)
			setElementInterior(source, interior)
			setCameraInterior(source, interior)
		else
			-- target player is in a vehicle - warp into it if there's space left
			if getPedOccupiedVehicle(source) then
				--removePlayerFromVehicle(source)
				outputChatBox('Önce araçtan inmeniz gerek.', source)
				return
			end
			local numseats = getVehicleMaxPassengers(vehicle) or 0
			for i=0,numseats do
				if not getVehicleOccupant(vehicle, i) then
					if isPedDead(source) then
						local x, y, z = getElementPosition(vehicle)
						spawnMe(x + 4, y, z + 1)
					end
					setElementInterior(source, interior)
					setCameraInterior(source, interior)
					warpPedIntoVehicle(source, vehicle, i)
					return
				end
			end
			outputChatBox(getPlayerName(targetPlayer) .. ' adlı oyuncunun aracında yer yok.', source, 255, 0, 0)
		end
	else
		errMsg ("Bu oyuncuya ışınlanamazsın.", source);
	end
	triggerClientEvent (source, "fr_onwarpresponded", source, toggle_warp[targetPlayer]);
end

local sawnoffAntiAbuse = {}
function giveMeWeapon(weapon, amount)
	if weapon and weapon > 50 then
		return
	end
	if table.find(getOption('weapons.disallowed'), weapon) then
		-- errMsg((getWeaponNameFromID(weapon) or tostring(weapon)) .. ' yasak.', source)
	else
		giveWeapon(source, weapon, amount, true)
		if weapon == 26 then
			if not sawnoffAntiAbuse[source] then
				setControlState (source, "aim_weapon", false)
				setControlState (source, "fire", false)
				toggleControl (source, "fire", false)
				reloadPedWeapon (source)
				sawnoffAntiAbuse[source] = setTimer (function(source)
					if not source then return end
					toggleControl (source, "fire", true)
					sawnoffAntiAbuse[source] = nil
				end, 3000, 1, source)
			end
        end
	end
end

function killSawnOffTimersOnQuit()
	if sawnoffAntiAbuse[source] and isTimer (sawnoffAntiAbuse[source]) then
		killTimer (sawnoffAntiAbuse[source])
		sawnoffAntiAbuse[source] = nil
	end
end
addEventHandler ("onPlayerQuit", root, killSawnOffTimersOnQuit)

function giveMeVehicles(vehicles)
	if exports.mtatr_deathmatches:isPlayerInDeathmatch (source) then
		return false;
	end
	-- if exports.mtatr_jobs:isPlayerInJob (source) then
		-- return false;
	-- end
	if type(vehicles) == 'number' then
		vehicles = { vehicles }
	end

	local px, py, pz, prot
	local radius = 3
	local playerVehicle = getPedOccupiedVehicle(source)
	if playerVehicle and isElement(playerVehicle) then
		px, py, pz = getElementPosition(playerVehicle)
		prot, prot, prot = getVehicleRotation(playerVehicle)
	else
		px, py, pz = getElementPosition(source)
		prot = getPedRotation(source)
	end
	local offsetRot = math.rad(prot)
	local vx = px + radius * math.cos(offsetRot)
	local vy = py + radius * math.sin(offsetRot)
	local vz = pz + 2
	local vrot = prot

	local vehicleList = g_PlayerData[source].vehicles
	local vehicle
	if ( not vehicles ) then return end
	for i,vehID in ipairs(vehicles) do
		if i > getOption('vehicles.maxperplayer') then
			break
		end
		if vehID < 400 or vehID > 611 then
			errMsg(vehID ..' yanlış bir araç modeli.', source)
		elseif not table.find(getOption('vehicles.disallowed'), vehID) then
			if #vehicleList >= getOption('vehicles.maxperplayer') then
				unloadVehicle(vehicleList[1])
			end
			vehicle = createVehicle(vehID, vx, vy, vz, 0, 0, vrot)
			if (not isElement(vehicle)) then return end
			setElementInterior(vehicle, getElementInterior(source))
			setElementDimension(vehicle, getElementDimension(source))
			table.insert(vehicleList, vehicle)
			g_VehicleData[vehicle] = { creator = source, timers = {} }
			if vehID == 464 then
				warpPedIntoVehicle(source, vehicle)
			elseif not g_Trailers[vehID] then
				if getOption('vehicles.idleexplode') then
					g_VehicleData[vehicle].timers.fire = setTimer(commitArsonOnVehicle, getOption('vehicles.maxidletime'), 1, vehicle)
				end
				g_VehicleData[vehicle].timers.destroy = setTimer(unloadVehicle, getOption('vehicles.maxidletime') + (getOption('vehicles.idleexplode') and 10000 or 0), 1, vehicle)
			end
			vx = vx + 4
			vz = vz + 4
		else
			-- errMsg(getVehicleNameFromModel(vehID):gsub('y$', 'ie') .. ' yasak.', source)
		end
	end
end

_setPlayerGravity = setPedGravity
function setPedGravity(player, grav)
	if grav < getOption('gravity.min') then
		errMsg(('Minimum allowed gravity is %.5f'):format(getOption('gravity.min')), player)
	elseif grav > getOption('gravity.max') then
		errMsg(('Maximum allowed gravity is %.5f'):format(getOption('gravity.max')), player)
	else
		_setPlayerGravity(player, grav)
	end
end

function setMyGameSpeed(speed)
	if speed < getOption('gamespeed.min') then
		errMsg(('Minimum allowed gamespeed is %.5f'):format(getOption('gamespeed.min')), source)
	elseif speed > getOption('gamespeed.max') then
		errMsg(('Maximum allowed gamespeed is %.5f'):format(getOption('gamespeed.max')), source)
	else
		clientCall(source, 'setGameSpeed', speed)
	end
end

function setTimeFrozen(state)
	if state then
		g_FrozenTime = { getTime() }
		g_FrozenWeather = getWeather()
		clientCall(g_Root, 'setTimeFrozen', state, g_FrozenTime[1], g_FrozenTime[2], g_FrozenWeather)
	else
		if g_FrozenTime then
			setTime(unpack(g_FrozenTime))
			g_FrozenTime = nil
			setWeather(g_FrozenWeather)
			g_FrozenWeather = nil
		end
		clientCall(g_Root, 'setTimeFrozen', state)
	end
end

function fadeVehiclePassengersCamera(toggle)
	local vehicle = getPedOccupiedVehicle(source)
	if not vehicle then
		return
	end
	local player
	for i=0,getVehicleMaxPassengers(vehicle) do
		player = getVehicleOccupant(vehicle, i)
		if player then
			fadeCamera(player, toggle)
		end
	end
end

-- addEventHandler('onPlayerChat', g_Root,
	-- function(msg, type)
		-- if type == 0 then
			-- cancelEvent()
			-- if chatTime[source] and chatTime[source] + tonumber(get("*chat/mainChatDelay")) > getTickCount() then
				-- outputChatBox("Stop spamming main chat!", source, 255, 0, 0)
				-- return
			-- else
				-- chatTime[source] = getTickCount()
			-- end
			-- if get("*chat/blockRepeatMessages") == "true" and lastChatMessage[source] and lastChatMessage[source] == msg then
				-- outputChatBox("Stop repeating yourself!", source, 255, 0, 0)
				-- return
			-- else
				-- lastChatMessage[source] = msg
			-- end
			-- local r, g, b = getPlayerNametagColor(source)
			-- outputChatBox(getPlayerName(source) .. ': #FFFFFF' .. msg:gsub('#%x%x%x%x%x%x', ''), g_Root, r, g, b, true)
			-- outputServerLog( "CHAT: " .. getPlayerName(source) .. ": " .. msg )
		-- end
	-- end
-- )

addEventHandler('onVehicleEnter', g_Root,
	function(player, seat)
		if not g_VehicleData[source] then
			return
		end
		if g_VehicleData[source].timers.fire then
			killTimer(g_VehicleData[source].timers.fire)
			g_VehicleData[source].timers.fire = nil
		end
		if g_VehicleData[source].timers.destroy then
			killTimer(g_VehicleData[source].timers.destroy)
			g_VehicleData[source].timers.destroy = nil
		end
		if not getOption('weapons.vehiclesenabled') and g_ArmedVehicles[getElementModel(source)] then
			toggleControl(player, 'vehicle_fire', false)
			toggleControl(player, 'vehicle_secondary_fire', false)
		end
	end
)

function setPlayerKnifeRestricted ( player )
	g_PlayerData[player].timers = g_PlayerData[player].timers or {}
	if g_PlayerData[player].timers.knifeProtection then
		resetTimer ( g_PlayerData[player].timers.knifeProtection )
	else
		addEventHandler ( "onPlayerStealthKill", player, knifeCancelEvent )
		g_PlayerData[player].timers.knifeProtection =  setTimer ( removeKnifeRestrictions, 5000, 1, player )
	end
end

function knifeCancelEvent ()
	outputChatBox ( "Bıçak kullanamazsın.", source, 255, 0, 0 )
	cancelEvent(true,"Knife restrictions")
end

function removeKnifeRestrictions (player)
	if not isElement(player) or getElementType(player) ~= "player" then
		return
	end
	g_PlayerData[player].timers.knifeProtection = nil
	removeEventHandler ( "onPlayerStealthKill", player, knifeCancelEvent )
end

function setMyPos(x, y, z)
	if not isElement(client) or getElementType(client) ~= "player" then
		return
	end

	if ( getOption('weapons.kniferestrictions') ) then
		setPlayerKnifeRestricted ( client )
	end

	local veh = getPedOccupiedVehicle (client)
	if veh then
		if getVehicleController(veh) == client then
			setElementPosition (veh, x, y, z)
			setElementInterior (veh, getElementInterior (client))
			for s = 1, getVehicleMaxPassengers (veh) do
				local occ = getVehicleOccupant (veh, s)
				if occ then
					setElementInterior (occ, getElementInterior(veh))
				end
			end
			setElementDimension (veh, 0)
		else
			removePedFromVehicle(source)
		end
	end
	setElementPosition (client, x, y, z)
	setElementDimension (client, 0)
	fadeCamera (client, true)
end

addEventHandler('onVehicleExit', g_Root,
	function(player, seat)
		if not g_VehicleData[source] then
			return
		end
		if not g_VehicleData[source].timers.fire then
			for i=0,getVehicleMaxPassengers(source) or 1 do
				if getVehicleOccupant(source, i) then
					return
				end
			end
			if getOption('vehicles.idleexplode') then
				g_VehicleData[source].timers.fire = setTimer(commitArsonOnVehicle, getOption('vehicles.maxidletime'), 1, source)
			end
			g_VehicleData[source].timers.destroy = setTimer(unloadVehicle, getOption('vehicles.maxidletime') + (getOption('vehicles.idleexplode') and 10000 or 0), 1, source)
		end
		if g_ArmedVehicles[getElementModel(source)] then
			toggleControl(player, 'vehicle_fire', true)
			toggleControl(player, 'vehicle_secondary_fire', true)
		end
	end
)

function commitArsonOnVehicle(vehicle)
	g_VehicleData[vehicle].timers.fire = nil
	setElementHealth(vehicle, 0)
end

addEventHandler('onVehicleExplode', g_Root,
	function()
		if not g_VehicleData[source] then
			return
		end
		if g_VehicleData[source].timers.fire then
			killTimer(g_VehicleData[source].timers.fire)
			g_VehicleData[source].timers.fire = nil
		end
		if not g_VehicleData[source].timers.destroy then
			g_VehicleData[source].timers.destroy = setTimer(unloadVehicle, 5000, 1, source)
		end
	end
)

function unloadVehicle(vehicle)
	if not g_VehicleData[vehicle] then
		return
	end
	for name,timer in pairs(g_VehicleData[vehicle].timers) do
		if isTimer(timer) then
			killTimer(timer)
		end
		g_VehicleData[vehicle].timers[name] = nil
	end
	local creator = g_VehicleData[vehicle].creator
	if g_PlayerData[creator] then
		table.removevalue(g_PlayerData[creator].vehicles, vehicle)
	end
	g_VehicleData[vehicle] = nil
	if isElement(vehicle) then
		destroyElement(vehicle)
	end
end

function quitHandler(player)
	if type(player) ~= 'userdata' then
		player = source
	end
	if not player then return end
	if g_PlayerData[player].blip and isElement(g_PlayerData[player].blip) then
		destroyElement(g_PlayerData[player].blip)
	end
	table.each(g_PlayerData[player].vehicles, unloadVehicle)
	g_PlayerData[player] = nil
	chatTime[player] = nil
	lastChatMessage[player] = nil
end
addEventHandler('onPlayerQuit', g_Root, quitHandler)

addEventHandler('onResourceStop', g_ResRoot,
	function()
		for player,data in pairs(g_PlayerData) do
			quitHandler(player)
		end
	end
)

addEvent ('onPlayerRequestDeathmatch', true);
addEventHandler ('onPlayerRequestDeathmatch', root,
	function (dm)
		if isPedDead (client) then return; end
		if isPedInVehicle (client) then outputChatBox ("Deathmatch'e girmek için önce aracınızdan inmeniz gerekli!", client, 255, 0, 0); return; end
		if exports.mtatr_deathmatches:isPlayerInDeathmatch (client) then return; end
		-- if exports.mtatr_jobs:isPlayerInJob (client) then return; end
		if getElementAttachedTo (client) then return; end
		exports.mtatr_deathmatches:setPlayerInDeathmatch (client, dm);
		triggerClientEvent (client, "dm.closeWindow", client);
	end
);

addEvent ("onPlayerJoinMission");
addEventHandler ("onPlayerJoinMission", root,
	function ()
		triggerClientEvent (source, "dm.closeWindow", source);
	end
);

function getVehicleHandlingProperty ( element, property )
    if isElement ( element ) and getElementType ( element ) == "vehicle" and type ( property ) == "string" then
        local handlingTable = getVehicleHandling ( element );
        local value = handlingTable[property];
        if value then
            return value;
        end
    end
    return false;
end

local bikehan = [[ { "suspensionLowerLimit": -0.1599999964237213, "engineInertia": 5, "suspensionHighSpeedDamping": 0, "collisionDamageMultiplier": 0.1500000059604645, "suspensionDamping": 0.1500000059604645, "seatOffsetDistance": 0, "headLight": "small", "dragCoeff": 0, "centerOfMass": [ 0, 0.07999999821186066, -0.300000011920929 ], "steeringLock": 35, "suspensionUpperLimit": 0.1500000059604645, "suspensionAntiDiveMultiplier": 0, "turnMass": 200, "brakeBias": 0.5, "tractionLoss": 1, "monetary": 10000, "ABS": false, "suspensionFrontRearBias": 0.5, "percentSubmerged": 103, "tractionBias": 0.4799999892711639, "numberOfGears": 5, "suspensionForceLevel": 0.8500000238418579, "animGroup": 4, "engineAcceleration": 45, "maxVelocity": 10000, "mass": 400, "driveType": "rwd", "modelFlags": 16785408, "brakeDeceleration": 21.60000038146973, "handlingFlags": 2, "tractionMultiplier": 2, "engineType": "petrol", "tailLight": "small" } ]];

addEvent( "handling.send",true )
addEventHandler( "handling.send",root, function(pack)
	local cost, name, accel, decel, maxvel, driveType, traction, mass = pack.cost, pack.name, pack.accel, pack.decel, pack.maxvel, pack.driveType, pack.traction, pack.mass;
	local veh = getPedOccupiedVehicle(client)
	if veh then
		if tonumber (cost) > getPlayerMoney (client) then
			outputChatBox ("Paranız yeterli değil.", client, 255, 50, 50);
			return;
		end
		outputChatBox ("Handling başarıyla uygulandı!", client, 50, 255, 50);
		if name == "Orijinal Paket" then
			setVehicleHandling(veh, false);
			exports.database:takePlayerMoney(client, cost, "Handling");
			return
		end
		setVehicleHandling(veh, false);
		if getVehicleType(veh) == "Boat" then
			setVehicleHandling(veh, "engineAcceleration", 2);
			local dec = tonumber(maxvel) and getVehicleHandlingProperty(veh, "maxVelocity")+tonumber(maxvel) or nil;
			setVehicleHandling(veh, "maxVelocity", dec);
			exports.database:takePlayerMoney(client, 500, "Handling");
			return
		elseif getVehicleType(veh) == "Bike" then
			for i, v in pairs(fromJSON(bikehan)) do
				setVehicleHandling(veh, i, v);
			end
			exports.database:takePlayerMoney(client, 500, "Handling");
			return
		end
		local acc = tonumber(accel) and getVehicleHandlingProperty(veh, "engineAcceleration")+tonumber(accel) or nil;
		setVehicleHandling(veh, "engineAcceleration", acc);
		local dec = tonumber(decel) and getVehicleHandlingProperty(veh, "brakeDeceleration")+tonumber(decel) or nil;
		setVehicleHandling(veh, "brakeDeceleration", dec);
		local dec = tonumber(maxvel) and getVehicleHandlingProperty(veh, "maxVelocity")+tonumber(maxvel) or nil;
		setVehicleHandling(veh, "maxVelocity", dec);
		local dec = tonumber(traction) and getVehicleHandlingProperty(veh, "tractionMultiplier")+tonumber(traction) or nil;
		setVehicleHandling(veh, "tractionMultiplier", dec);
		local dec = tonumber(mass) and getVehicleHandlingProperty(veh, "mass")+tonumber(mass) or nil
		setVehicleHandling(veh, "mass", dec);
		setVehicleHandling(veh, "driveType", driveType);
		exports.database:takePlayerMoney(client, cost, "Handling");
	end
end)

addEvent ("fr.setneoncolor", true);
addEventHandler ("fr.setneoncolor", root,
	function (r, g, b)
		if r and g and b then
			local vehicle = getPedOccupiedVehicle (client);
			if isElement (vehicle) then
				if exports.mtatr_neon:doesVehicleHaveNeon (vehicle) then
					exports.mtatr_neon:setNeonColor(vehicle, r, g, b);
				end
			end
		end
	end
);

addEvent ("onClientPlayerRequestGamemode", true);
addEventHandler ("onClientPlayerRequestGamemode", root,
	function (mode)
		triggerEvent ("onPlayerRequestGamemode", client, mode);
	end
);

addEvent ("fr.toggleNeon", true);
addEventHandler ("fr.toggleNeon", root,
	function (state)
		local vehicle = getPedOccupiedVehicle (client);
		if isElement (vehicle) then
			if state == true then
				if not exports.mtatr_neon:doesVehicleHaveNeon (vehicle) then
					exports.mtatr_neon:addNeon (vehicle, 255, 255, 255, 255);
				else
					exports.mtatr_neon:setNeonLightsEnabled (vehicle, true);
				end
			else
				exports.mtatr_neon:setNeonLightsEnabled (vehicle, false);
			end
		end
	end
);

addEvent('onServerCall', true)
addEventHandler('onServerCall', resourceRoot,
	function(fnName, ...)
		source = client		-- Some called functions require 'source' to be set to the triggering client
		local fnInfo = g_RPCFunctions[fnName]
		if fnInfo and ((type(fnInfo) == 'boolean' and fnInfo) or (type(fnInfo) == 'table' and getOption(fnInfo.option))) then
			local fn = _G
			for i,pathpart in ipairs(fnName:split('.')) do
				fn = fn[pathpart]
			end
			fn(...)
		elseif type(fnInfo) == 'table' then
			-- errMsg(fnInfo.descr .. ' yasak.', source)
		end
	end
)

function clientCall(player, fnName, ...)
	triggerClientEvent(player, 'onClientCall', g_ResRoot, fnName, ...)
end
