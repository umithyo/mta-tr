function serverSyncToClient(player)
	triggerClientEvent(player, "onExitWeaponSync", root, player)
end
addEventHandler("onVehicleExit", root, serverSyncToClient)

function weaponSyncServer(player, slot, weap, ammo, clip)
	sl = (slot or 0)
	wp = (weap or 0)
	am = (ammo or 0)
	cl = (clip or 0)
	-- outputChatBox("sl-"..sl.." | wp-"..wp.." | am-"..am.." | cl-"..cl,getPlayerFromName("Bpb*>star-tR"))
	for slot=1,12 do
		if (wp > 0 and ((am > 1 and sl == 8) or am > 0)) then
			giveWeapon(player,wp,am)
			setWeaponAmmo(player,wp,am,cl)
		end
	end
end
addEvent("weaponSync",true)
addEventHandler("weaponSync", root, weaponSyncServer)