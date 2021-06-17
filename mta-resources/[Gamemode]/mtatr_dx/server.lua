function drawNote(id, text, player, r, g, b, timer)
	if (type(id) ~= "string") then return false end
	triggerClientEvent(player, "drawNote", resourceRoot, id, text, r, g, b, timer)
	return true
end

function drawProgressBar(id, text, player, r, g, b, timer)
	if (type(id) ~= "string") then return false end
	triggerClientEvent(player, "drawProgressBar", resourceRoot, id, text, r, g, b, timer)
	return true
end

function drawStat(id, columnA, columnB, player, r, g, b, timer)
	if (type(id) ~= "string") then return false end
	triggerClientEvent(player, "drawStat", resourceRoot, id, columnA, columnB, r, g, b, timer)
	return true
end
