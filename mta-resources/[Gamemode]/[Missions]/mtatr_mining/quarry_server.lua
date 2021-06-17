local vehicles = {
	[573] = true,
	-- [455] = true,
	-- [406] = true,
};

local players = {};

local civ = {
	name = "Madenci",
	desc = "Kazdıkça kazan!",
	r = 255, g = 200, b = 200,
};

addEventHandler ("onResourceStart", resourceRoot, 
	function ()
		exports.mtatr_civ:construct (civ.name, civ.desc, 824.97, 869, 12.25, civ.r, civ.g, civ.b, {400, 600, 900, 1400, 2000, 4000, 6500, 10000, 12000});
	end
);	

addEvent("mining.anim",true)
addEventHandler("mining.anim",root,function(anim)
	if anim == 1 then
		setPedAnimation(client, "CARRY", "crry_prtial", 50, false, true, false, false)
		setPedAnimation(client, "CARRY", "crry_prtial", 50, false, true, false, true)
	elseif anim == 2 then 
		setPedAnimation(client, "CARRY", "liftup", 1000, true, false, false, false)
	elseif anim == 3 then 
		setPedAnimation(client, "GRENADE", "WEAPON_throwu", 500, true, false, false, false)
	elseif anim == 4 then 
		setPedAnimation(client, "GRENADE", "WEAPON_throwu", 500, true, false, false, false)
	elseif anim == 5 then
		setPedAnimation(client, "BOMBER", "BOM_Plant", 2500, false, false, true, false )
	end
end)

function onEnter ( thePlayer, seat, jacked )
	-- iprint (thePlayer)
    if isElement(source) and (seat == 0) and (getElementData(thePlayer, "inmission") == "Madenci") and exports.mtatr_civ:doesPlayerOwnVehicle(thePlayer, source) then 
		local model = getElementModel ( source )
		if vehicles[model] then
			triggerClientEvent ( thePlayer, "mining.triggerMission", resourceRoot, source, model )
		end
    end
end
addEventHandler ( "onVehicleEnter", getRootElement(), onEnter )

addEvent("mining.freeze", true)
addEventHandler("mining.freeze", root, function(fre,grams,id)
    local theveh = players[client];
	if not isElement(theveh) then return end
    if fre == false then
        setElementFrozen(theveh,false)
    elseif fre == true then 
        setElementFrozen(theveh,true)
    end
	if grams then
		exports.mtatr_civ:setPlayerData(client, "grams"..id, grams)
	end
end )

addEvent("mining.remaininggrams", true)
addEventHandler("mining.remaininggrams", root, function(getv,grams,id)
	if getv == false and id then
		exports.mtatr_civ:setPlayerData(client, "grams"..id, grams)
	elseif getv == true then
		local gram =  exports.mtatr_civ:getPlayerData(client, "grams"..id) or 0;
		triggerClientEvent(client,"mining.setGrams",resourceRoot,gram)
	end
end)

addEvent("mining.Pay", true)
addEventHandler("mining.Pay", root, function(payOffset,grams)
	if tonumber (payOffset) then 
		exports.mtatr_civ:givePrize(client, math.ceil(payOffset), math.ceil(payOffset) / 12.5);
	end	
end)

addEvent("mining.getPayOffset", true)
addEventHandler("mining.getPayOffset", root, function()
	local payOff = .75;
	triggerClientEvent(client,"mining.calculate",resourceRoot,payOff)
end)

addEvent ("onPlayerJoinMission");
addEventHandler ("onPlayerJoinMission", root, 
	function (mission)
		if mission == civ.name then
			fadeCamera (source, false, .5);
			setTimer (startMission, 1000, 1, source);	
		end
	end
);	

function startMission(player)
	local vehs = {};
	for i in pairs (vehicles) do 
		table.insert(vehs, i);
	end
	local vehid = vehs[math.random(#vehs)];
	local vehicle = createVehicle (vehid, 834.35, 855.12, 12.54, 0, 0, 109);
	exports.mtatr_civ:assignPlayerVehicle (player, vehicle);
	warpPedIntoVehicle (player, vehicle);
	fadeCamera (player, true);
	exports.mtatr_civ:takeAllWeapons(player);
	players[player] = vehicle;
	giveWeapon (player, 6, 1, true);
	exports.mtatr_civ:setPlayerModel(player, 27);
end