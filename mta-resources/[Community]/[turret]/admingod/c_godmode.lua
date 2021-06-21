addEventHandler("onClientPlayerDamage", localPlayer, function(attacker, weapon, bodypart, damage)

	if getElementData(source, "invincible") and attacker ~= false then
		cancelEvent()
		triggerServerEvent("dealDamageToAttacker", source, attacker, damage)
	end
end)

addEventHandler("onClientPlayerStealthKill",localPlayer, function(target)
	if getElementData(target, "invincible") then
		cancelEvent()
	end
end)