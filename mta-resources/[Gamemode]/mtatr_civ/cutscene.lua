local sx, sy 		= guiGetScreenSize();
local align			= 0.0989;
local height		= sy * align;
local alignedY		= sy * (1 - align);
local edgeOffset	= 10;
local font 			= dxCreateFont ("files/sub.ttf", 18);
local entity 		= {};
local cutscene 		= {};
local subtitles 	= {};
local last_mission  = {}; 

function toggleHUD(state)
	if state == true then
		exports.mtatr_hud:hideHud();
		exports.mtatr_accounts:hideLogo();
		exports.mtatr_mode:hideBar();
		exports.fps:hideFPS();
		
		--restart
		exports.mtatr_hud:showHud();
		exports.mtatr_accounts:showLogo();
		exports.mtatr_mode:showBar();
		exports.fps:showFPS();
		showChat (true);
		toggleAllControls (true);
	else
		exports.mtatr_hud:hideHud();
		exports.mtatr_accounts:hideLogo();
		exports.mtatr_mode:hideBar();
		exports.fps:hideFPS();
		showChat (false);
		toggleAllControls(false);
	end
end	
addEvent ("cutscene.toggle", true);
addEventHandler ("cutscene.toggle", root, toggleHUD);

function createCutscenePed(...)
	local ped = Ped (...);
	entity[ped] = true;
	return ped;
end

function createCutsceneObject (...)
	local obj = Object (...);
	entity[obj] = true;
	return obj;
end	

function createCutsceneVehicle (...)
	local veh = Vehicle (...);
	entity[veh] = true;
	return veh;
end	

function isCutsceneEntity (e)
	return entity[e];
end	

function setCutscenePedAnimation (ped, start, ...)
	if start <= 49 then 
		return setPedAnimation (ped, ...);
	end	
	setTimer (setPedAnimation, (start or 1) * 1000, 1, ped, ...)
end
addEvent ("cutscene.setanim", true);
addEventHandler ("cutscene.setanim", root, setCutscenePedAnimation);

--startx, ...
function createCutscene(...)
	local arg = {...};
	last_mission = arg[1];
	toggleHUD(false);
	addEventHandler ("onClientPreRender", root, drawEdges);
	addEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
	if next (arg) then 
		if isElement (arg[2]) then 
			setCutsceneFocusOnElement(arg[2], arg[3], arg[4]);
		else
			local args = {...};
			table.remove (args, 1);
			setCutsceneFocus(unpack(args));
		end	
	end	
end
addEvent ("cutscene.create", true);
addEventHandler ("cutscene.create", root, createCutscene);

--element, delay, start
function setCutsceneFocusOnElement(...)
	local element = arg[1];
	if not isElement (element) then return; end
	local delay = tonumber(arg[2]) or 0;
	local start = tonumber(arg[3]) or 0;
	local angle = arg[4];
	setCutsceneFocus (_, _, _, _, _, _, delay, start, {element = element, angle = angle});
 end 
 addEvent ("cutscene.focus_elem", true);
 addEventHandler ("cutscene.focus_elem", root, setCutsceneFocusOnElement);
 
-- x, y, z, lx, ly, lz, delay (s), start, element
function setCutsceneFocus(...)
	local total = 0;
	local totalD = 0;
	for i, v in ipairs (cutscene) do 
		-- total = total + v[8];
		totalD = totalD + v[7];
	end	
	arg[7] = totalD + ((arg[7] or 0) * 1000);
	arg[8] = total + ((arg[8] or 0) * 1000);
	arg[10] = getTickCount ();
	
	table.insert (cutscene, arg);
	removeEventHandler ("onClientPreRender", root, handleFocus);
	addEventHandler ("onClientPreRender", root, handleFocus);
	playSFX("genrl", 52, 6, false);
end
addEvent ("cutscene.focus", true);
addEventHandler ("cutscene.focus", root, setCutsceneFocus);
 
function destroyCutscene()
	toggleHUD(false);
	toggleHUD(true);
	removeEventHandler ("onClientPreRender", root, drawEdges);
	removeEventHandler ("onClientPlayerDamage", localPlayer, cancelEvent);
	removeEventHandler ("onClientPreRender", root, handleFocus);
	setCameraTarget (localPlayer);
	for i in pairs (entity) do 
		if isElement (i) then 
			i:destroy();
		end
	end	
	subtitles = {};
	cutscene  = {};
end	
addEventHandler ("onClientResourceStop", resourceRoot, destroyCutscene);
addEvent ("cutscene.destroy", true);
addEventHandler ("cutscene.destroy", root, destroyCutscene);

function setSubtitles(text, delay, start)
	local totalD = 0;
	for i, v in ipairs (subtitles) do 
		totalD = totalD + v.delay;
	end
	local delay = totalD + ((delay or 0) * 1000);
	local tick = getTickCount() 
	local start =  getTickCount() + ((start or 0) * 1000);
	table.insert (subtitles, 
		{
			text = text,
			tick = tick,
			delay = delay,
			start = start
		}
	);
end	
addEvent ("cutscene.setsub", true);
addEventHandler ("cutscene.setsub", root, setSubtitles);

function drawEdges()
	dxDrawRectangle (0, 0, sx, height, tocolor (0, 0, 0, 255), false);
	dxDrawRectangle (0, 0, sx, height + edgeOffset, tocolor (0, 0, 0, 125), false);
	dxDrawRectangle (0, alignedY, sx, height, tocolor (0, 0, 0, 255), false);
	dxDrawRectangle (0, alignedY - edgeOffset, sx, height + edgeOffset, tocolor (0, 0, 0, 125), false);
	if #subtitles > 0 then 
		local text = subtitles[1].text;
		local tick = subtitles[1].tick;
		local start = subtitles[1].start;
		local delay = subtitles[1].delay;
		if getTickCount() > tick + delay then 
			table.remove (subtitles, 1);
			return;
		end	
		
		if getTickCount() > start then 
			dxDrawText (text, 0, alignedY, sx, sy, tocolor(255, 255, 255, 255), 1.18, font, "center", "center", true, true);
		end	
	end	
end

function handleFocus()
	if #cutscene <= 0 then
		triggerEvent ("onClientCutsceneEnded", localPlayer, last_mission);
		destroyCutscene();
		return;
	end	
	local focus = cutscene[1];
	if focus then
		if getTickCount () > focus[10] + focus[7] then 
			table.remove(cutscene, 1);
			return;
		end
		if getTickCount () > focus[10] + focus[8] then 
			local mx, my, mz, x, y, z = focus[1], focus[2], focus[3], focus[4], focus[5], focus[6]
			if isElement (focus[9].element) then 
				local element = focus[9].element;
				x, y, z = getElementPosition (element);
				local angle = focus[9].angle or (element.position + (element.matrix.forward * 3) + element.matrix.up);
				mx, my, mz = angle.x, angle.y, angle.z;
			end	
			setCameraMatrix(mx, my, mz, x, y, z);
		end	
	end
end

addEvent ("onClientCutsceneEnded");
addEventHandler ("onClientCutsceneEnded", root, 
	function (mission) 
		triggerServerEvent ("onCutsceneEnded", localPlayer, mission);
	end
);	
--dev
-- createCutscene (localPlayer, 4);
-- local ped = createCutscenePed (0, -147.56, -72.87, 3.12);
-- setCutsceneFocusOnElement (ped, 5, 5);
-- setCutscenePedAnimation (ped, 5, "ped", "IDLE_chat");
-- setSubtitles ("Ped1: Hi.", 10, 5);
-- setCutsceneFocusOnElement (localPlayer, 3, 6);