payammount = 0
Pizzas = 0
local PizzaslocLS = {
{653.670, -1652.420, 13.655},
{650.505, -1694.262, 13.668},
{135.998, -1492.103, 17.766},
{256.985, -1364.476, 52.109},
{431.052, -1250.777, 50.581},
{697.425, -1058.735, 48.410},
{1409.815, -920.860, 37.422},
{2082.661, -1040.638, 30.802},
{2351.307, -1166.693, 26.481},
{2550.617, -1194.643, 59.826},
{1026.814, -1772.175, 12.547},
{993.026, -1815.844, 13.067},
{958.458, -1807.486, 13.068},
{315.874, -1771.541, 3.685},
{305.360, -1771.903, 3.550},
{206.848, -1771.292, 3.267},
{192.732, -1771.341, 3.214},
{168.508, -1771.099, 3.394},
{-67.132, -1548.024, 1.617},
{-86.909, -1563.135, 1.611},
{144.176, -1468.481, 24.204},
{611.101, -1084.364, 57.827},
{1024.137, -983.160, 41.644},
{1182.526, -1076.203, 30.672},
{1143.144, -1092.879, 27.188},
{1284.773, -1308.431, 12.539},
{1284.639, -1329.433, 12.545},
{1284.563, -1350.022, 12.564},
{1984.074, -1718.934, 14.969},
{2069.768, -1643.750, 12.547},
}
local PizzasMarkersLS = {
{2096.820, -1799.175, 12.383},
}
local ctrls ={
"sprint",
"jump",
"enter_exit",
"enter_passenger",
"fire", 
"crouch", 
"aim_weapon",
"next_weapon",
"previous_weapon",
}
local pizzas = {}
function randomh()
	return unpack( PizzaslocLS [math.random (#PizzaslocLS)] )
end

function randomMarkers()
	return unpack( PizzasMarkersLS [math.random (#PizzasMarkersLS)] )
end


addEvent("PizzaDelivery.onPizzaBoyEnter", true)
addEventHandler("PizzaDelivery.onPizzaBoyEnter", root, function()
    if (getElementData(localPlayer,"inmission") == "Pizza Kuryesi") then 
        if not isElement(Pizzabox) and not isElement(blip) and not isElement(refblip) then
            if ( Pizzas == 0 ) then
				local rdmX,rdmY,rdmZ = randomMarkers()
				refmarker = createMarker (rdmX, rdmY, rdmZ, "cylinder", 1.5, 255, 25, 0, 170 )
				refblip = createBlipAttachedTo(refmarker, 41)
                exports.mtatr_hud:dm("Pizzan yok! Devam etmek için dükkandan yeni pizzalar al.", 255, 0, 0)
				reload = false
            else
                mission()
            end
        end
    end
end )
addEvent("PizzaDelivery.marker", true)
addEventHandler("PizzaDelivery.marker", root, function(theVeh)
    local mx,my,mz = getElementPosition(theVeh)
    refillmarker = createMarker(mx, my, mz, "cylinder", 0.8, 255, 25, 0, 170 )
    attachElements(refillmarker,theVeh,0,-1.3,-0.5,1,0,0)
end )
function mission()
    local x1, y1, z1 = randomh()
	if x1 == lastPosx and y1 == lastPosy then
		mission()
	return end
	lastPosx,lastPosy,lastPosz = x1,y1,z1
    marker = createMarker ( x1, y1, z1, "cylinder", 0.9, 255, 255, 50, 170 )
    blip = createBlipAttachedTo(marker, 41)
    loca = getZoneName(x1,y1,z1)
    exports.mtatr_hud:dm("Yeni pizza siparişi geldi: "..loca, 255, 255, 0)
    local d1x, d1y, d1z = getElementPosition ( marker )
    local d2x, d2y, d2z = getElementPosition ( localPlayer )
    local distance = getDistanceBetweenPoints3D(d1x,d1y,d1z,d2x,d2y,d2z)
    payammount = distance
end

function Pizzaexit(thePlayer)
    if ( getElementModel ( source ) == 448 ) and ( thePlayer == localPlayer )and (getElementData(localPlayer,"inmission") == "Pizza Kuryesi") then
        if ( Pizzas > 0 ) and isElement(marker) then
			local p1x, p1y, p1z = getElementPosition ( marker )
			local p2x, p2y, p2z = getElementPosition ( localPlayer )
			local dist = getDistanceBetweenPoints3D(p1x,p1y,p1z,p2x,p2y,p2z)
			if ( dist < 40 ) then
				triggerServerEvent("PizzaDelivery.freeze", resourceRoot,true)
				setElementFrozen(localPlayer,true)
				toggleAllControls(false,true,false)
				setTimer( function()
					setElementFrozen(localPlayer,false)
					toggleAllControls(true)
					toggleControl("crouch", false)
					triggerServerEvent("PizzaDelivery.anim", resourceRoot,1,2)
					pizza = true
					setPedWeaponSlot(localPlayer,0)
                end, 950, 1 )
			end
		end
	end
end
addEventHandler ( "onClientVehicleExit", root, Pizzaexit )


function refillDone()
    Pizzas = 5
    toggleAllControls(true)
    exports.mtatr_dx:drawStat("PizzaID", "Pizzalar", Pizzas.."/5", 255, 200, 0)
    exports.mtatr_hud:dm("Pizzaboy'unu doldurdun!", 255, 0, 0)
	for i,v in ipairs(ctrls) do
		toggleControl(v, true)
	end
    triggerServerEvent("PizzaDelivery.freeze", resourceRoot,false)
	reload = false
	mission()
	destroyElement(refblip)
	destroyElement(refmarker)
end
function destroyPizzas()
end
function startprogress(thePlayer)
    if ( source == refmarker ) and ( thePlayer == localPlayer) and ( isPedInVehicle ( thePlayer ) ) then
		toggleAllControls(false,true,false) 
		pTimer1 = setTimer(refillDone, 1000, 1)
    triggerServerEvent("PizzaDelivery.freeze", resourceRoot,true)
    end
end
addEventHandler("onClientMarkerHit",getRootElement(),startprogress)
function pay(thePlayer)
    if ( thePlayer == localPlayer ) and ( source == marker ) and not ( isPedInVehicle ( thePlayer ) ) then
        if (pizza == true) then
			toggleAllControls(false,true,false) 
			destroyElement(marker)
			destroyElement(blip)
			playSound("walking.mp3", false)
			setTimer(function()
				playSFX("spc_fa", 17, math.random(5,11), false)
				Pizzas = Pizzas - 1
				pizza = false
				exports.mtatr_dx:drawStat("PizzaID", "Pizzalar", Pizzas.."/5", 255, 200, 0)
				toggleAllControls(true,true,false) 
                triggerServerEvent("PizzaDelivery.freeze", resourceRoot,false)
                triggerServerEvent("PizzaDelivery.anim", resourceRoot,3,0)
                triggerServerEvent("PizzaDelivery.getpaid", resourceRoot, payammount)
            end, 7500,1 )
        end
    end 
end
addEventHandler ( "onClientMarkerHit", root, pay)

function delelem(thePlayer)
	if (getElementData(localPlayer,"inmission") == "Pizza Kuryesi") then
		payammount = 0
		Pizzas = 0
		pizza = false
		if isElement(marker) then destroyElement(marker) end
		if getPedAnimation(localPlayer) then triggerServerEvent("PizzaDelivery.anim", resourceRoot,0,0) end
		if isElement(refmarker) then destroyElement(refmarker) end
		if isElement(refillmarker) then destroyElement(refillmarker) end
		if isElement(refblip) then destroyElement(refblip) end
		if isElement(Pizzabox) then destroyElement(Pizzabox) end
		if isElement(blip) then destroyElement(blip) end
		exports.mtatr_dx:drawStat("PizzaID", "", "", 255, 200, 0)
		if isTimer(pTimer1) then killTimer(pTimer1) end
		if isTimer(pTimer) then killTimer(pTimer) end
		if isTimer(refTimer1) then killTimer(refTimer1) end
		toggleAllControls(true)
	end
end
addEvent("onClientVehicleHide", true)
addEventHandler ("onClientVehicleHide", root, delelem)
addEventHandler ("onClientPlayerWasted", localPlayer, delelem)
function onJobQuit(job)
    if ( job == "Pizza Kuryesi" ) then 
		Pizzas = 0
		payammount = 0
		if isElement(marker) then destroyElement(marker) end
		if isElement(blip) then destroyElement(blip) end
		if isTimer(pTimer) then killTimer(pTimer) end
		toggleAllControls(true)
		if getPedAnimation(localPlayer) then triggerServerEvent("PizzaDelivery.anim", resourceRoot,0,0) end
		if isTimer(pTimer1) then killTimer(pTimer1) end
		if isTimer(refTimer1) then killTimer(refTimer1) end
		if isElement(Pizzabox) then destroyElement(Pizzabox) end
		if isElement(refillmarker) then destroyElement(refillmarker) end
		if isElement(refmarker) then destroyElement(refmarker) end
		if isElement(refblip) then destroyElement(refblip) end
		exports.mtatr_dx:drawStat("PizzaID", "", "", 255, 200, 0)
	end
end
addEvent("onClientPlayerLeaveMission",true)
addEventHandler("onClientPlayerLeaveMission",localPlayer,onJobQuit)