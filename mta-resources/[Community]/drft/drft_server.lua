function givePlayerMoney (...)
	return exports.database:givePlayerMoney (...);
end

function takePlayerMoney (...)
	return exports.database:takePlayerMoney (...);
end

function setPlayerMoney (...)
	return exports.database:setPlayerMoney (...);
end

local root = getRootElement()
local thisResourceRoot = getResourceRootElement(getThisResource())
local drift_mejor = 0
local drift_nombre = "N/A"

addEventHandler ( "onResourceStart", thisResourceRoot,
	function()
		--call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Best Drift")
		--call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Last Drift")
		--call(getResourceFromName("scoreboard"), "addScoreboardColumn", "Total Drift")

		local xmlFile = xmlLoadFile("recordDrift.xml")
		local xmlPuntaje = xmlFindChild(xmlFile, "score", 0)
		local xmlNombre = xmlFindChild(xmlFile, "name", 0)
		if xmlPuntaje and xmlNombre then
			drift_mejor = tonumber(xmlNodeGetValue(xmlPuntaje))
			drift_nombre = xmlNodeGetValue(xmlNombre)
--			outputDebugString(string.format("Drift: Record restored. (%d points) (%s)",drift_mejor,drift_nombre))
			setTimer(triggerClientEvent, 3000, 1, root, "driftActualizarRecord", root, drift_mejor, drift_nombre)
			xmlUnloadFile(xmlFile)
		else
--			outputDebugString("Drift: Server failed loading record data.")
		end
	end
)

addEventHandler ( "onResourceStop", thisResourceRoot,
	function()
		call(getResourceFromName("mtatr_scoreboard"), "removeScoreboardColumn", "Best Drift")
		call(getResourceFromName("mtatr_scoreboard"), "removeScoreboardColumn", "Last Drift")
		call(getResourceFromName("mtatr_scoreboard"), "removeScoreboardColumn", "Total Drift")
		local xmlFile = xmlLoadFile("recordDrift.xml")
		if xmlFile then
			local temp = xmlFindChild(xmlFile, "score", 0)
			if not temp then
				temp = xmlCreateChild(xmlFile, "score")
			end
			xmlNodeSetValue(temp, tostring(drift_mejor))

			temp = xmlFindChild(xmlFile, "name", 0)
			if not temp then
				temp = xmlCreateChild(xmlFile, "name")
			end
			xmlNodeSetValue(temp, drift_nombre)
			xmlSaveFile(xmlFile)
			xmlUnloadFile(xmlFile)
		end
	end
)

addEventHandler("onVehicleDamage", root, function()
	thePlayer = getVehicleOccupant(source, 0)
	if thePlayer then
		triggerClientEvent(thePlayer, "driftCarCrashed", root, source)
	end
end)

addEvent("driftNuevoRecord", true)
addEventHandler("driftNuevoRecord", root, function(score, name)
	if score > drift_mejor then
		--outputChatBox(string.format("New drift record! (%d points) (%s)",score,name))
		drift_mejor = score
		drift_nombre = name
		triggerClientEvent(root, "driftActualizarRecord", root, drift_mejor, drift_nombre)
	end
end)

addEvent("driftClienteListo", true)
addEventHandler("driftClienteListo", root, function(player)
	triggerClientEvent(player, "driftActualizarRecord", root, drift_mejor, drift_nombre)
	--outputChatBox(string.format("The actual record is %d points (%s)", drift_mejor, drift_nombre), player)
end)
--- FIN

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

addEvent( "afterDriftEvent", true )
function afterDriftEvent(player,score)
	if math.round(score/20)< 500 then
		givePlayerMoney( player, math.round(score/20), "Drift" )
	else
		givePlayerMoney( player, 500, "Drift" )
	end
end
addEventHandler( "afterDriftEvent", getRootElement(), afterDriftEvent )
