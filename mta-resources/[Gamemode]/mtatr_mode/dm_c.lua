local dxfont0_birth_of_a_hero = dxCreateFont("font/birth_of_a_hero.ttf", 45)
local screenW, screenH = guiGetScreenSize()
local spree = {
	rows = {
		[1] = "FIRST BLOOD",
		[2] = "MULTIKILL",
		[5] = "KILLING SPREE",
		[6] = "HEADSHOT",
		[9] = "HOLY SHIT",
		[12] = "DOMINATING",
		[16] = "RAMPAGE",
		[19] = "WICKED SICK",
		[23] = "UNSTOPPABLE",
		[30] = "GODLIKE",
	},
	texts = {
		font = dxCreateFont("font/birth_of_a_hero.ttf", 45),
	},
	offset = 2,
	alpha = 255,
	text = "FIRST BLOOD"
}

local sounds = {
    ['first blood'] = 'first_blood.mp3',
    ['multikill'] = 'multikill.mp3',
    ['killing spree'] = 'first_blood.mp3',
    ['headshot'] = 'first_blood.mp3',
    ['holy shit'] = 'first_blood.mp3',
    ['dominating'] = 'dominating.mp3',
    ['rampage'] = 'rampage.mp3',
    ['wicked sick'] = 'wicked_sick.mp3',
    ['unstoppable'] = 'unstoppable.mp3',
    ['godlike'] = 'godlike.mp3',
    ['headshot'] = 'headshot.mp3',
    ['yeni seviye!'] = 'yeni_seviye.mp3'
};

function spree.draw()
	if getTickCount() >= spree.tick then
		spree.alpha = spree.alpha - 5;
	end
	dxDrawText(spree.text, (screenW * 0.3507) - 1, (screenH * 0.0433) - 1, (screenW * 0.7167) - 1, (screenH * 0.2144) - 1, tocolor(0, 0, 0, spree.alpha), 1.00, dxfont0_birth_of_a_hero, "center", "center", false, false, false, false, false)
	dxDrawText(spree.text, (screenW * 0.3507) + 1, (screenH * 0.0433) - 1, (screenW * 0.7167) + 1, (screenH * 0.2144) - 1, tocolor(0, 0, 0, spree.alpha), 1.00, dxfont0_birth_of_a_hero, "center", "center", false, false, false, false, false)
	dxDrawText(spree.text, (screenW * 0.3507) - 1, (screenH * 0.0433) + 1, (screenW * 0.7167) - 1, (screenH * 0.2144) + 1, tocolor(0, 0, 0, spree.alpha), 1.00, dxfont0_birth_of_a_hero, "center", "center", false, false, false, false, false)
	dxDrawText(spree.text, (screenW * 0.3507) + 1, (screenH * 0.0433) + 1, (screenW * 0.7167) + 1, (screenH * 0.2144) + 1, tocolor(0, 0, 0, spree.alpha), 1.00, dxfont0_birth_of_a_hero, "center", "center", false, false, false, false, false)
	dxDrawText(spree.text, screenW * 0.3507, screenH * 0.0433, screenW * 0.7167, screenH * 0.2144, tocolor(255, 222, 87, spree.alpha), 1.00, dxfont0_birth_of_a_hero, "center", "center", false, false, false, false, false)
	if spree.alpha <= 0 then
		removeEventHandler ("onClientRender", root, spree.draw);
		spree.alpha = 255;
	end
end

function spree.texts.draw ()
	spree.offset = spree.offset - 0.1;
	dxDrawText(spree.text, screenW * 0.3507, screenH * 0.0433, screenW * 0.7167, screenH * 0.2144, tocolor(255, 222, 87, spree.texts.alpha), spree.offset, spree.texts.font, "center", "center", false, false, false, false, true);
	if spree.offset <= 1.00 then
		removeEventHandler ("onClientRender", root, spree.texts.draw);
		spree.offset = 2;
	end
end

function spree.show ()
	spree.texts.alpha = 124;
	removeEventHandler ("onClientRender", root, spree.draw);
	removeEventHandler ("onClientRender", root, spree.texts.draw);
	addEventHandler("onClientRender", root, spree.draw);
	addEventHandler ("onClientRender", root, spree.texts.draw);
    if (spree.text) then
	    playSound ("sounds/"..sounds[spree.text:lower()]);
    end
	spree.tick = getTickCount () + 2000
end

addEvent ("spree.show", true);
function showSpree (row)
	if row then
		if spree.rows[tonumber (row)] then
			spree.text = spree.rows[tonumber (row)];
			spree.show();
		elseif row == "level" then
			spree.text = "YENI SEVIYE!";
			spree.show();
		end
	end
end
addEventHandler ("spree.show", root, showSpree);

local x, y		= guiGetScreenSize();
local h 		= 18;

local file = xmlLoadFile ("levels.xml");
local levels = {};

do
	for i, v in ipairs (xmlNodeGetChildren (file)) do
		levels[i] = tonumber (xmlNodeGetValue (v));
	end
end


function drawBar ()
	if localPlayer:getData"inevent" then return; end
	if localPlayer:getData"current.char" then
		local level = localPlayer:getData"char.level" or 1;
		local next_exp = levels[level] or 0;
		local experience = localPlayer:getData ("char.exp") or 0;
		if level == #levels then
			next_exp = levels[level];
			experience = levels[level];
		end

		dxDrawRectangle(0, y-h, x, h, tocolor(0, 0, 0, 125), false);
		dxDrawRectangle(0, y-h, x*(experience/next_exp), h, tocolor(225, 153, 10, 255), false);
		dxDrawText(math.floor (experience).."/".. (next_exp or 0), 0, y-h, x, (y-h) + h, tocolor(255, 255, 255, 255), 1.00, "default-bold", "center", "center");
	end
end

function showBar ()
	addEventHandler ("onClientRender", root, drawBar);
end
-- addEventHandler ("onClientResourceStart", resourceRoot, showBar);

function hideBar ()
	removeEventHandler ("onClientRender", root, drawBar);
end

addEvent ("onClientPlayerLevelUp", true);
addEventHandler ("onClientPlayerLevelUp", root,
	function (level)
		showSpree("level");
	end
);

addEvent ("mode.damaged", true);
addEventHandler ("mode.damaged", root,
	function (damaged)
		dmgtick = damaged+getTickCount();
	end
);

addEventHandler ("onClientRender", root,
	function ()
		if getElementData (localPlayer, "inevent") or
		getElementData (localPlayer, "inmission") or
		getElementData (localPlayer, "inpvp") or
		getElementData (localPlayer, "indm") then
			return;
		end
		local multiplier=.1;
		if dmgtick then
			if getTickCount() > dmgtick then
				setElementHealth(localPlayer, getElementHealth(localPlayer) + multiplier);
			end
		end
	end
);
