local screenW, screenH = guiGetScreenSize();
local vehicle;
local time = 0;
local tick = 0

addEventHandler("onClientRender", root,
    function()
		if vehicle then 
			if getTickCount () - tick >= 1000 then 
				if time then 
					if time - time % 1000 > 0 then 
						time = (time - time % 1000) - 1000;
						tick = getTickCount();
					end	
				end	
			end	
			if getElementData (localPlayer, "current.char") and not isPlayerMapVisible () then 
				local converted_time = exports.mtatr_utils:totime (time/1000);
				dxDrawText("BLACK EXPORT", (screenW * 0.6486) - 1, (screenH * 0.2722) - 1, (screenW * 0.8917) - 1, (screenH * 0.3133) - 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("BLACK EXPORT", (screenW * 0.6486) + 1, (screenH * 0.2722) - 1, (screenW * 0.8917) + 1, (screenH * 0.3133) - 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("BLACK EXPORT", (screenW * 0.6486) - 1, (screenH * 0.2722) + 1, (screenW * 0.8917) - 1, (screenH * 0.3133) + 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("BLACK EXPORT", (screenW * 0.6486) + 1, (screenH * 0.2722) + 1, (screenW * 0.8917) + 1, (screenH * 0.3133) + 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("BLACK EXPORT", screenW * 0.6486, screenH * 0.2722, screenW * 0.8917, screenH * 0.3133, tocolor(255, 102, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)

				dxDrawText(vehicle, (screenW * 0.6486) - 1, (screenH * 0.3244) - 1, (screenW * 0.8917) - 1, (screenH * 0.3656) - 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText(vehicle, (screenW * 0.6486) + 1, (screenH * 0.3244) - 1, (screenW * 0.8917) + 1, (screenH * 0.3656) - 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText(vehicle, (screenW * 0.6486) - 1, (screenH * 0.3244) + 1, (screenW * 0.8917) - 1, (screenH * 0.3656) + 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText(vehicle, (screenW * 0.6486) + 1, (screenH * 0.3244) + 1, (screenW * 0.8917) + 1, (screenH * 0.3656) + 1, tocolor(0, 0, 0, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText(vehicle, screenW * 0.6486, screenH * 0.3244, screenW * 0.8917, screenH * 0.3656, tocolor(153, 153, 153, 255), 0.90, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("Kalan: "..converted_time, (screenW * 0.6486) - 1, (screenH * 0.3656) - 1, (screenW * 0.8917) - 1, (screenH * 0.4067) - 1, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("Kalan: "..converted_time, (screenW * 0.6486) + 1, (screenH * 0.3656) - 1, (screenW * 0.8917) + 1, (screenH * 0.4067) - 1, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("Kalan: "..converted_time, (screenW * 0.6486) - 1, (screenH * 0.3656) + 1, (screenW * 0.8917) - 1, (screenH * 0.4067) + 1, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("Kalan: "..converted_time, (screenW * 0.6486) + 1, (screenH * 0.3656) + 1, (screenW * 0.8917) + 1, (screenH * 0.4067) + 1, tocolor(0, 0, 0, 255), 0.70, "bankgothic", "center", "center", false, false, false, false, false)
				dxDrawText("Kalan: "..converted_time, screenW * 0.6486, screenH * 0.3656, screenW * 0.8917, screenH * 0.4067, tocolor(153, 153, 153, 255), 0.70, "bankgothic", "center", "center", false, false, false, false, false)
			end	
		end	
    end
)

addEvent ("blackexport.getvehicle", true);
addEventHandler ("blackexport.getvehicle", root, 
	function (veh, time_)
		vehicle = veh;
		time = time_;
		tick = 0;
	end
);	

triggerServerEvent ("blackexport.getvehicle", localPlayer);