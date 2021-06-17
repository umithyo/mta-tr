function guiCreateButton (...)
	return exports.mtatr_gui:guiCreateButton(...);
end

function guiCreateEdit (...)
	return exports.mtatr_gui:guiCreateEdit(...);
end

function guiCreateWindow (...)
	return exports.mtatr_gui:guiCreateWindow(...);
end

function guiEditSetMasked (...)
	return exports.mtatr_gui:guiEditSetMasked(...);
end

function findInTable (tbl, index, value)
	for i, v in ipairs (tbl) do
		if (tonumber (v[index]) or v[index]) == value then
			return v;
		end
	end
	return false;
end

_createGrid = guiCreateGridList;

function guiCreateGridList (...)
	local gr_ = _createGrid (...);
	guiGridListSetSortingEnabled (gr_, false);
	return gr_;
end

char = {
    label = {},
    edit = {},
    button = {},
    window = {},
    gridlist = {},
    memo = {},
};

local chars = {};
local characters_prefix = {};

local toremove_skins = {};

local ped;

local screenW, screenH = guiGetScreenSize();

function createCharButtons()
	char.window[1] = guiCreateWindow(10, (screenH - 423) / 2, 420, 423, "Karakter Seçin", false)
	-- guiWindowSetSizable(char.window[1], false)

	char.gridlist[1] = guiCreateGridList(0.02, 0.05, 0.95, 0.85, true, char.window[1])
	guiGridListAddColumn(char.gridlist[1], "İsim", 0.3)
	guiGridListAddColumn(char.gridlist[1], "Durum", 0.3)
	guiGridListAddColumn(char.gridlist[1], "Seviye", 0.3)
	char.button[1] = guiCreateButton(0.55, 0.93, 0.15, 0.05, "Başla", true, char.window[1])
	guiSetProperty(char.button[1], "NormalTextColour", "FFAAAAAA")
	char.button[2] = guiCreateButton(0.72, 0.93, 0.25, 0.05, "Yeni Karakter", true, char.window[1])
	guiSetProperty(char.button[2], "NormalTextColour", "FFAAAAAA")

	for i, v in pairs (char.button) do
		addEventHandler ("onClientGUIClick", v, charConf, false);
	end

	for i, v in pairs (char.gridlist) do
		addEventHandler ("onClientGUIClick", v, charConf, false);
	end

	if next (chars) then
		loadChars ();
	else
		requestChars();
	end
	skin_cat, skins = exports.mtatr_utils:xmlToTable (":mtatr_freeroam/skins.xml", true);
end

function charConf()
	if source == char.gridlist[2] then
		loadSkins ();
	end
end

function toggle_nav (state)
	if state == true then
		if isElement (char.window[3]) then
			return
		end
		char.window[3] = guiCreateWindow(0.43, 0.86, 0.18, 0.08, "Skin Seç", true)
		-- guiWindowSetSizable(char.window[3], false)

		char.button[5] = guiCreateButton(0.04, 0.42, 0.30, 0.32, "<<", true, char.window[3])
		guiSetProperty(char.button[5], "NormalTextColour", "FFAAAAAA")
		char.button[6] = guiCreateButton(0.67, 0.42, 0.30, 0.32, ">>", true, char.window[3])
		guiSetProperty(char.button[6], "NormalTextColour", "FFAAAAAA")

		addEventHandler ("onClientGUIClick", char.button[5], charConf);
		addEventHandler ("onClientGUIClick", char.button[6], charConf);
	else
		if isElement (char.window[3]) then
			removeEventHandler ("onClientGUIClick", char.button[5], charConf);
			removeEventHandler ("onClientGUIClick", char.button[6], charConf);
			char.window[3]:destroy();
		end
	end
end

function toggle_new (state)
	if state == true then
		if isElement (char.window[2]) then
			return
		end

		char.window[2] = guiCreateWindow(screenW - 456 - 10, (screenH - 612) / 2, 456, 612, "Karakter Oluştur", false)
		-- guiWindowSetSizable(char.window[2], false)

		char.label[1] = guiCreateLabel(0.02, 0.04, 0.96, 0.04, "Formu doldurun.", true, char.window[2])
		guiLabelSetHorizontalAlign(char.label[1], "center", false)
		char.label[2] = guiCreateLabel(0.02, 0.12, 0.13, 0.04, "İsim:", true, char.window[2])
		guiLabelSetVerticalAlign(char.label[2], "center")
		char.label[3] = guiCreateLabel(0.02, 0.18, 0.13, 0.04, "Yaş:", true, char.window[2])
		guiLabelSetVerticalAlign(char.label[3], "center")
		char.edit[1] = guiCreateEdit(0.14, 0.12, 0.83, 0.04, "", true, char.window[2])
		char.edit[2] = guiCreateEdit(0.14, 0.18, 0.83, 0.04, "", true, char.window[2])
		char.label[4] = guiCreateLabel(0.02, 0.24, 0.13, 0.04, "Cinsiyet:", true, char.window[2])
		guiLabelSetVerticalAlign(char.label[4], "center")
		char.gridlist[2] = guiCreateGridList(0.17, 0.24, 0.79, 0.14, true, char.window[2])
		guiGridListAddColumn(char.gridlist[2], "Cinsiyet", 0.9)
		char.label[5] = guiCreateLabel(0.02, 0.40, 0.13, 0.04, "Liste", true, char.window[2])
		guiLabelSetVerticalAlign(char.label[5], "center")
		char.gridlist[3] = guiCreateGridList(0.17, 0.46, 0.79, 0.44, true, char.window[2])
		guiGridListAddColumn(char.gridlist[3], "ID", 0.3)
		guiGridListAddColumn(char.gridlist[3], "İsim", 0.3)
		guiGridListAddColumn (char.gridlist[3], "Seviye", 0.3);
		-- char.label[6] = guiCreateLabel(0.02, 0.62, 0.13, 0.04, "Bilgi:", true, char.window[2])
		-- guiLabelSetVerticalAlign(char.label[6], "center")
		-- char.memo[1] = guiCreateMemo(0.17, 0.62, 0.79, 0.27, "", true, char.window[2])
		char.button[3] = guiCreateButton(0.61, 0.94, 0.16, 0.04, "Oluştur", true, char.window[2])
		guiSetProperty(char.button[3], "NormalTextColour", "FFAAAAAA")
		char.button[4] = guiCreateButton(0.79, 0.94, 0.16, 0.04, "Vazgeç", true, char.window[2])
		guiSetProperty(char.button[4], "NormalTextColour", "FFAAAAAA")
		char.edit[3] = guiCreateEdit(0.16, 0.40, 0.46, 0.04, "Ara...", true, char.window[2])

		guiEditSetMaxLength (char.edit[1], 21);

		local e_row = guiGridListAddRow (char.gridlist[2]);
		guiGridListSetItemText (char.gridlist[2], e_row, 1, "Erkek", false, false);
		local k_row = guiGridListAddRow (char.gridlist[2]);
		guiGridListSetItemText (char.gridlist[2], k_row, 1, "Kadın", false, false);

		addEventHandler ("onClientGUIFocus", char.edit[3], char_focus, false);
		addEventHandler ("onClientGUIChanged", char.edit[3], char_edit);

        loadSkins();

		for i, v in pairs (char.button) do
			if isElement (v) then
				removeEventHandler ("onClientGUIClick", v, charConf);
				addEventHandler ("onClientGUIClick", v, charConf);
			end
		end

		for i, v in pairs (char.gridlist) do
			if isElement (v) then
				removeEventHandler ("onClientGUIClick", v, charConf);
				addEventHandler ("onClientGUIClick", v, charConf);
			end
		end
	else
		if isElement (char.window[2]) then
			removeEventHandler ("onClientGUIChanged", char.edit[3], char_edit);
			removeEventHandler ("onClientGUIFocus", char.edit[3], char_focus);
			char.window[2]:destroy();
			if isElement (ped) then
				if not get_grid_item_text (char.gridlist[1]) then
					ped:destroy();
				end
			end
			toggle_nav (false);
		end
	end
end
addEvent ("login.request_char_screen", true);
addEventHandler ("login.request_char_screen", root, toggle_new);

function char_focus()
	source:setText ("");
end

function char_edit()
	exports.mtatr_utils:searchInGrid (char.gridlist[3], source, skins, "loadSkins", "id", "name", "level", "keywords");
end

function get_grid_item_text (grid, column)
	local item = guiGridListGetSelectedItem (grid);
	if item ~= -1 then
		local text = guiGridListGetItemText (grid, item, column or 1);
		return text;
	end
	return false;
end

local function nav_skins (rol)
	if not rol then --left
		local item = guiGridListGetSelectedItem (char.gridlist[3]);
		if item == -1 then
			ped:setModel (skins[1].id);
			guiGridListSetSelectedItem (char.gridlist[3], 1, 1);
			return
		end
		guiGridListSetSelectedItem (char.gridlist[3], item - 1, 1);
		local model = get_grid_item_text (char.gridlist[3]);
		if model then
			ped:setModel (model);
		end
	else
		local item = guiGridListGetSelectedItem (char.gridlist[3]);
		if item == -1 then
			ped:setModel (skins[#skins].id);
			guiGridListSetSelectedItem (char.gridlist[3], guiGridListGetRowCount(char.gridlist[3]), 1);
			return
		end
		guiGridListSetSelectedItem (char.gridlist[3], item + 1, 1);
		local model = get_grid_item_text (char.gridlist[3]);
		if model then
			ped:setModel (model);
		end
	end
end

function charConf ()
	if source == char.button[1] then 	 	-- start
		local char = get_grid_item_text (char.gridlist[1]);
		if char then
			triggerServerEvent ("onClientPlayerRequestSpawn", localPlayer, char);
		end
	elseif source == char.button[2] then 	-- new char
		triggerServerEvent ("onPlayerRequestANewCharacter", localPlayer);
	elseif source == char.button[3] then 	-- create new char
		if isElement (ped) then
			local name =  char.edit[1]:getText ();
			local age = char.edit[2]:getText ();
			local model = ped:getModel();
			local level = tonumber (findInTable (skins, "id", model).level) or 1;
			-- local info = char.memo[1]:getText ();
			local info = "";
			if not string.match(name, "^[%a%d.:,;#'+*~|<>@^!\"$%%&/()=?{}%[%]\\_-]+$") then
				exports.mtatr_hud:dm ("Geçersiz karakter ismi.", 255, 0, 0);
				return
			end
			if name:find ("#%x%x%x%x%x%x") then
				exports.mtatr_hud:dm ("Geçersiz karakter ismi.", 255, 0, 0);
				return;
			end
			if name:lower():find("gaming") or name:lower():find("gamıng") then
				exports.mtatr_hud:dm ("Geçersiz karakter ismi.", 255, 0, 0);
				return;
			end
			if tonumber (level) ~= 1 then
				exports.mtatr_hud:dm ("Bu skin için yeterli seviyede değilsiniz.")
				return;
			end
			if name and model then
				triggerServerEvent ("onPlayerCreateANewCharacter", localPlayer, name, age, model, info);
			end
		else
			exports.mtatr_hud:dm ("Önce bir karakter seçmelisiniz.", 255, 0, 0);
		end
	elseif source == char.button[4] then 	-- cancel
		toggle_new (false);
	elseif source == char.button[5] then 	-- navigate left
		nav_skins (false);
	elseif source == char.button[6] then 	-- navigate right
		nav_skins (true);
	elseif source == char.gridlist[1] then 	-- current chars
		local char = get_grid_item_text(source);
		if char then
			if isElement (ped) then
				ped:destroy();
			end
			model = characters_prefix[char].model;
			ped = createPed(model, 259.1, -41.25, 1002, 54.0027465);
			setElementInterior(ped, 14);
		else
			if isElement (ped) then
				ped:destroy();
			end
		end
	elseif source == char.gridlist[2] then 	-- sex
		local sex = get_grid_item_text (char.gridlist[2]);
		if sex then
			sex = sex == "Erkek" and "male, guy, boy" or "female, woman, girl";
			loadSkins (sex);
		else
			toggle_nav (false);
			guiGridListClear (char.gridlist[3]);
		end
	elseif source == char.gridlist[3] then  -- skin list
		local model = get_grid_item_text (source);
		if model then
			toggle_nav (true);
			if isElement (ped) then
				ped:setModel (model);
			else
				ped = createPed(model, 259.1, -41.25, 1002, 54.0027465);
				ped:setInterior (14);
			end
		end
	end
end

function loadSkins (sex)
	local sex = sex or "male, guy, boy";
	sex = split (sex, ", ");
	guiGridListClear (char.gridlist[3]);
	for k, cat in ipairs (skin_cat) do
		local catrow = guiGridListAddRow (char.gridlist[3]);
		guiGridListSetItemText (char.gridlist[3], catrow, 1, cat, true, false);
		for i, v in ipairs (skins) do
			for _, word in ipairs (sex) do
				if string.find (v.keywords, word) then
					if (word == "male" or word == "boy" or word == "boy") and not string.find (v.keywords, "female") then
						local row = guiGridListAddRow (char.gridlist[3]);
						guiGridListSetItemText (char.gridlist[3], row, 1, v.id, false, false);
						guiGridListSetItemText (char.gridlist[3], row, 2, v.name, false, false);
						guiGridListSetItemText (char.gridlist[3], row, 3, v.level or 1, false, true);
					elseif 	(word == "female" or word == "woman") and not string.find (v.keywords, "male")  then
						local row = guiGridListAddRow (char.gridlist[3]);
						guiGridListSetItemText (char.gridlist[3], row, 1, v.id, false, false);
						guiGridListSetItemText (char.gridlist[3], row, 2, v.name, false, false);
						guiGridListSetItemText (char.gridlist[3], row, 3, v.level or 1, false, true);
					end
				end
			end
		end
	end
end

function redirectToCharScreen()
	fadeCamera (false);
	setTimer (
		function ()
			createCharButtons ();
			setCameraMatrix(257.154296875, -40.2236328125, 1002.1802978516, 349.09375, -79.2587890625, 997.35321044922);
			setElementInterior(localPlayer, 14);
			fadeCamera (true)
		end,
	1000, 1);
end

function requestChars ()
	triggerServerEvent ("onPlayerRequestCharacterList", localPlayer);
end

function loadChars(c, cc)
	if c then
		chars = c;
		characters_prefix = cc;
	end
	if isElement (char.window[1]) then
		guiGridListClear (char.gridlist[1]);
		for i, v in ipairs (chars) do
			local row = guiGridListAddRow (char.gridlist[1]);
			guiGridListSetItemText (char.gridlist[1], row, 1, v.name, false, false);
			guiGridListSetItemText (char.gridlist[1], row, 2, "Yaşıyor", false, false);
			guiGridListSetItemText (char.gridlist[1], row, 3, v.level, false, false);
		end
	end
end
addEvent ("login.request_chars", true);
addEventHandler ("login.request_chars", root, loadChars);

addEvent ("onSpawnResponded", true);
addEventHandler ("onSpawnResponded", root,
	function ()
		ped:destroy();
		setCameraTarget (localPlayer);
		for i, v in pairs (char.window) do
			if isElement (v) then
				v:destroy();
			end
		end
		showCursor (false);
		exports.mtatr_hud:showHud();
		showChat (true);
	end,
true, "low");
