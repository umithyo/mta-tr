function weaponSyncClient (aw)
	player = aw
	for slot=1,12 do
		local weap = getPedWeapon(aw,slot)
		local ammo = getPedTotalAmmo(aw,slot)
		local clip = (getPedAmmoInClip(aw,slot) or 0)
		if (weap > 0 and ((ammo > 1 and slot == 8) or ammo > 0)) then
			triggerServerEvent("weaponSync", root, player, slot, weap, ammo, clip)
			-- outputChatBox(slot..": w-"..weap.." a-"..ammo.." c-"..clip)
		end
	end
end
addEvent("onExitWeaponSync",true )
addEventHandler("onExitWeaponSync",localPlayer, weaponSyncClient)