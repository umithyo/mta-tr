function cutscene()
	local ped1 = exports.mtatr_civ:createCutscenePed (28, 978.7, 2176.57, 10.82, 198);
	local vehicle = exports.mtatr_civ:createCutsceneVehicle (482, 980.88, 2177.84, 10.82, 0, 0, 163);
	setTimer (setVehicleColor, 50, 1, vehicle, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	exports.mtatr_civ:createCutscene ("Uyuşturucu Kaçakçısı", ped1, 2);
	exports.mtatr_civ:setSubtitles ("Don Faggot: Hoşgeldin.", 2);
	local angle = vehicle.position + (vehicle.matrix.forward * 6) + vehicle.matrix.up * 2;
	exports.mtatr_civ:setCutsceneFocusOnElement (vehicle, 2, 2, angle);
	exports.mtatr_civ:setSubtitles ("Don Faggot: Malları araca yükledim. Tek yapman gereken teslimat.", 2, 2);
	exports.mtatr_civ:setCutsceneFocusOnElement (ped1, 3, 4);
	exports.mtatr_civ:setSubtitles ("Don Faggot: Unutma, mallar ne kadar korunursa o kadar fazla para alırsın.", 3, 4);
	exports.mtatr_civ:setCutscenePedAnimation (ped1, 0, "ped", "IDLE_chat");
end	