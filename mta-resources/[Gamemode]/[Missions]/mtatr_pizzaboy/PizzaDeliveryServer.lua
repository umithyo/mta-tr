local Pizzas = {}

local civ = {
	name = "Pizza Kuryesi",
	desc = "30 dk içinde götürmezsen pizzalar beleş!",
	r = 255, g = 100, b = 50,
};

-- Hourly Distance: 41,768 meters -->>

addEventHandler ("onResourceStart", resourceRoot,
	function()
		exports.mtatr_civ:construct (civ.name, civ.desc, 2095.91, -1800.5, 13.38, civ.r, civ.g, civ.b, {});
	end
);	

addEvent("PizzaDelivery.getpaid", true)
addEventHandler("PizzaDelivery.getpaid", root, function(dist_)
	local distance = math.ceil(dist_)
	exports.database:givePlayerMoney(client,distance*0.7, "Mission: "..civ.name);
end)

function PizzaboyEnter ( thePlayer, seat, jacked )
    if isElement(source) and ( getElementModel ( source ) == 448 ) and exports.mtatr_civ:doesPlayerOwnVehicle(thePlayer, source) and (seat == 0) and (getElementData(thePlayer,"inmission") == civ.name) then 
       triggerClientEvent ( thePlayer, "PizzaDelivery.onPizzaBoyEnter", resourceRoot )
    end
end
addEventHandler ( "onVehicleEnter", getRootElement(), PizzaboyEnter )
addEvent("PizzaDelivery.freeze", true)
addEventHandler("PizzaDelivery.freeze", root, function(fre)
	local theveh = getElementData(client, "veh")
	if not isElement(theveh) then return end
	if fre == false then
		setElementFrozen(theveh,false)
	elseif fre == true then 
		setElementFrozen(theveh,true)
	end
end )

addEvent("PizzaDelivery.getTheVeh", true)
addEventHandler("PizzaDelivery.getTheVeh", root, function()
local theVeh = getElementData(client, "veh")
triggerClientEvent ( client, "PizzaDelivery.marker", client, theVeh )
end )
addEvent("PizzaDelivery.anim", true)
addEventHandler("PizzaDelivery.anim", root, function(anim,box)
if box == 0 then
	if isElement(Pizzas[client]) then
	destroyElement(Pizzas[client])
	Pizzas[client] = nil
	end
	elseif box == 2 then
	local x,y,z = getElementPosition(client)
	Pizzas[client] = createObject(1582, x, y, z)
	setObjectScale(Pizzas[client],0.75)
	setElementCollisionsEnabled(Pizzas[client],false)
	attachElements(Pizzas[client],client,0,0.45,0.37,1,0,0)
end
if anim == 1 then
    toggleControl(client,"sprint", false)
    toggleControl(client,"jump", false)
    toggleControl(client,"enter_exit", false)
    toggleControl(client,"enter_passenger",false)
    toggleControl(client,"aim_weapon",false)
    toggleControl(client,"fire", false)
    toggleControl(client,"next_weapon", false)
    toggleControl(client,"previous_weapon", false)
    setPedAnimation(client, "CARRY", "crry_prtial", 50, false, true, false, false)
    setPedAnimation(client, "CARRY", "crry_prtial", 50, false, true, false, true)
end
if anim == 2 then 
setPedAnimation(client, "VENDING", "VEND_Use", 10000, true, false, false, false)
end
if anim == 3 then 
setPedAnimation(client, "ON_LOOKERS", "wave_loop", 1000, false, false, false, false)
end
end )

addEventHandler("onPlayerQuit", root, function()
	if isElement(Pizzas[source]) then
	destroyElement(Pizzas[source])
	Pizzas[source] = nil
	end
end)

addEvent ("onPlayerJoinMission");
addEventHandler ("onPlayerJoinMission", root, 
	function (mission)
		if mission == civ.name then
			local vehicle = createVehicle(448, 2095.91, -1800.5, 13.38, 0, 0, 82.13);
			exports.mtatr_civ:assignPlayerVehicle(source, vehicle);
			warpPedIntoVehicle(source, vehicle);
			setElementModel(source, 155);
		end
	end
);	