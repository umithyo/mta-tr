local screenW, screenH = guiGetScreenSize()
local min_char = 3;
local xml_root = {};
login = {
    staticimage = {},
    edit = {},
    button = {},
    window = {},
    label = {},
	checkbox = {},
};

cameras = {
	{
		{1893.94140625, -1163.72265625, 27.619258880615, 1982.9287109375, -1209.2900390625, 29.812183380127}, {1913.94140625, -1153.72265625, 27.619258880615, 1982.9287109375, -1209.2900390625, 29.812183380127}
	},
	{
		{-1835, 1485.84, 48.09, -1835.89, 1486.63, 47.63}, {-1845, 1495.84, 48.09, -1835.89, 1486.63, 47.63}
	},
	{
		{353, -1708, 7.52, 352.96, -1708.98, 7.48}, {363, -1728, 7.52, 352.96, -1708.98, 7.48}
	},
	{
		{1089, -1138.9, 142.93, 1090.44, -1139.15, 143.03}, {1099, -1128.9, 142.93, 1090.44, -1139.15, 143.03}
	},
	{
		{2116, 2133.17, 51.26, 2126.65, 2133.25, 51.21}, {2126, 2133.17, 51.26, 2126.65, 2133.25, 51.21}
	},
	{
		{1463, 2734.56, 39.13, 1462.64, 2733.75, 38.72}, {1446, 2695.73, 20.68, 1445.75, 2694.89, 20.31}
	},
	{
		{2237, 2448.96, 31.1, 2237.21, 2449.88, 30.75}, {2230, 2483.17, 21.84, 2229.81, 2484.12, 21.57}
	},
};

camid = 1

function startCameraShow ()
	camerasetid = setTimer (
		function ()
			camid = camid + 1
			if camid >= #cameras then
				camid = 1
			end
		end,
	10000, 0)

	camerashow = setTimer (
		function ()
			local x1, y1, z1, x1t, y1t, z1t = unpack (cameras[camid][1])
			local x2, y2, z2, x2t, y2t, z2t = unpack (cameras[camid][2])
			smoothMoveCamera (x1, y1, z1, x1t, y1t, z1t, x2, y2, z2, x2t, y2t, z2t, 10000)
			if localPlayer:getData ("loggedin") then
				killTimer (sourceTimer)
			end
		end,
	50, 0)
end

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
		if localPlayer:getData ("loggedin") then return else showChat (true); end
		localPlayer:setDimension (0);
		localPlayer:setInterior (0);
		login.window[1] = guiCreateWindow((screenW - 571) / 2, (screenH - 387) / 2, 571, 387, "Giriş Yap", false)
		-- guiWindowSetSizable(login.window[1], false)
		-- guiWindowSetMovable (login.window[1], false);
		login.staticimage[1] = guiCreateStaticImage(0.02, 0.06, 0.96, 0.47, "img/login_logo.png", true, login.window[1])		login.edit[1] = guiCreateEdit(0.11, 0.63, 0.88, 0.06, "", true, login.window[1])
		login.edit[2] = guiCreateEdit(0.11, 0.72, 0.88, 0.06, "", true, login.window[1])
        login.button[1] = guiCreateButton(0.72, 0.89, 0.12, 0.06, "Kayıt Ol", true, login.window[1])
        guiSetProperty(login.button[1], "NormalTextColour", "FFAAAAAA")
		login.button[2] = guiCreateButton(0.86, 0.89, 0.12, 0.06, "Giriş Yap", true, login.window[1])
		guiSetProperty(login.button[2], "NormalTextColour", "FFAAAAAA")
		login.label[1] = guiCreateLabel(0.02, 0.56, 0.96, 0.05, "Bilgilerinizi giriniz.", true, login.window[1])        guiSetFont(login.label[1], "default-bold-small")        guiLabelSetHorizontalAlign(login.label[1], "center", false)        login.label[2] = guiCreateLabel(0.02, 0.63, 0.09, 0.06, "Mail:", true, login.window[1])        login.label[3] = guiCreateLabel(0.02, 0.72, 0.09, 0.06, "Şifre:", true, login.window[1])

		showCursor (true);

		for i, v in pairs (login.button) do
			addEventHandler ("onClientGUIClick", v, guiConf);
		end

		for i, v in pairs (login.edit) do
			addEventHandler ("onClientGUIAccepted", v, guiAccepted);
		end

		login.checkbox[1] = guiCreateCheckBox(0.82, 0.81, 0.16, 0.05, "Beni Hatırla?", false, true, login.window[1]);
		addEventHandler ("onClientGUIClick", login.checkbox[1], guiConf);

		setCameraMatrix(1893.94140625, -1163.72265625, 27.619258880615, 1982.9287109375, -1209.2900390625, 29.812183380127);

		createBlur();

		setPlayerHudComponentVisible ("radar", false);

		guiEditSetMasked (login.edit[2], true);

		xml_root.root = xmlLoadFile ("@options.xml") or xmlCreateFile ("@options.xml", "options");
		xml_root.remember_me = xmlNodeGetChildren (xml_root.root, 0) or xmlCreateChild (xml_root.root, "remember");
		xml_root.account = xmlNodeGetChildren (xml_root.root, 1) or xmlCreateChild (xml_root.root, "account");
		local value = xmlNodeGetValue (xml_root.remember_me) == "true";
		guiCheckBoxSetSelected (login.checkbox[1], value);

		if value then
			local account, password = xmlNodeGetAttribute (xml_root.account, "mail"), xmlNodeGetAttribute (xml_root.account, "password");
			login.edit[1]:setText (account);
			login.edit[2]:setText (password);
		end

		guiSetInputMode ("no_binds_when_editing");
		showChat (false);
	end
);

local function fade (element, limit, int, action, ...)
	local interval = int or .1;
	local limit = limit or 1;
	local tick = getTickCount () + 2000;
	local fading = true;
	local alpha = guiGetAlpha (element);

	local function notification_draw ()
		if isElement (element) then
			if fading then
				alpha = alpha - interval;
				if alpha <= 0 then
					fading = false;
				end
			else
				if alpha < limit then
					alpha = alpha + interval;
				end
			end

			guiSetAlpha (element, alpha);

			if getTickCount () > tick + 3000 then
				removeEventHandler ("onClientRender", root, notification_draw);
				if action then
					action (unpack (arg));
				end
			end
		else
			removeEventHandler ("onClientRender", root, notification_draw);
		end
	end

	addEventHandler ("onClientRender", root, notification_draw);
end

function notificate (text, colour)
	if isElement (login.label[1]) then
		local tick = getTickCount ();
		login.label[1]:setText (text);
		guiLabelSetColor (login.label[1], unpack (colour));
		fade (login.label[1]);
	end
end
addEvent ("login.notificate", true);
addEventHandler ("login.notificate", root, notificate);

function switchButtons (t)
	if t == "register" then
		if isElement (login.checkbox[1]) then
			login.window[1]:setText("Kayıt Ol");
			removeEventHandler ("onClientGUIClick", login.checkbox[1], guiConf);
			login.checkbox[1]:destroy();
			login.edit[3] = guiCreateEdit(0.11, 0.81, 0.88, 0.06, "", true, login.window[1]);
			login.label[4] = guiCreateLabel(0.02, 0.81, 0.09, 0.05, "Tekrar:", true, login.window[1]);
			guiEditSetMasked (login.edit[3], true);

		end

	elseif t == "login" then
		if isElement (login.edit[3]) then
			login.window[1]:setText("Giriş Yap");
			login.edit[3]:destroy();
			login.label[4]:destroy();
			login.checkbox[1] = guiCreateCheckBox(0.82, 0.81, 0.16, 0.05, "Beni Hatırla?", false, true, login.window[1]);
			addEventHandler ("onClientGUIClick", login.checkbox[1], guiConf);
			local value = xmlNodeGetValue (xml_root.remember_me) == "true";
			guiCheckBoxSetSelected (login.checkbox[1], value);
		end
	end

	login.label[1]:setText ("Bilgilerinizi giriniz.");
	guiLabelSetColor (login.label[1], 255, 255, 255);
end

function getMenuType ()
	return isElement (login.edit[3]) and "register" or "login";
end

function guiConf ()
	if source == login.button[1] then
		if getMenuType () == "register" then
			registerPlayer ();
		else
			-- fade (login.window[1], .8);
			Timer (switchButtons, 200, 1, "register");
		end
	elseif source == login.button[2] then
		if getMenuType () == "login" then
			logPlayerIn ();
		else
			-- fade (login.window[1], .8);
			Timer (switchButtons, 200, 1, "login");
		end
	elseif source == login.checkbox[1] then
		local value = guiCheckBoxGetSelected (source);
		xmlNodeSetValue (xml_root.remember_me, tostring (value));
		xmlSaveFile (xml_root.root);
	end
end

function guiAccepted ()
	if getMenuType () == "login" then
		logPlayerIn();
	else
		registerPlayer();
	end
end

local function str_check (...)
	for i, v in ipairs (arg) do
		if not string.match(v, "^[%a%d.:,;#'+*~|<>@^!\"$%%&/()=?{}%[%]\\_-]+$") then
			return false, i;
		end

		if #v < min_char then
			return false, "Minimum "..min_char.." karakter girmeniz gerek.";
		end

		if i == 1 and (not string.find (v, "@") or not string.find (v, ".")) then
			return false, 1;
		end
	end

	return true;
end

local r_issues = {
	"Hatalı e-mail adresi girdiniz.",
	"Hatalı şifre girdiniz.",
	"Şifreler uyuşmuyor.",
};

function registerPlayer()
	local mail = login.edit[1]:getText();
	local pass = login.edit[2]:getText();
	local pass2 = login.edit[3]:getText();
	if pass ~= pass2 then
		notificate ("Şifreler uyuşmuyor.", {255, 0, 0});
		return
	end

	local check, index = str_check (mail, pass, pass2);
	if not check then
		local msg = r_issues[index] or index;
		notificate (msg, {255, 0, 0});
		return
	end

	triggerServerEvent ("onPlayerRequestRegistration", localPlayer, mail, pass);
end

function logPlayerIn ()
	local mail = login.edit[1]:getText();
	local pass = login.edit[2]:getText();
	local check, index = str_check (mail, pass);
	if not check then
		local msg = r_issues[index] or index;
		notificate (msg, {255, 0, 0});
		return
	end
	triggerServerEvent ("onPlayerRequestLogin", localPlayer, mail, pass);
end

addEvent ("onClientPlayerLogin", true);
addEventHandler ("onClientPlayerLogin", root,
	function ()
		local mail = login.edit[1]:getText();
		local pass = login.edit[2]:getText();

		Timer (
			function ()
				login.window[1]:destroy();
				redirectToCharScreen();
			end,
		500, 1);

		notificate ("Başarıyla giriş yapıldı! Lütfen bekleyin...", {0, 255, 0});

		if xmlNodeGetValue (xml_root.remember_me) == "true" then
			xmlNodeSetAttribute (xml_root.account, "mail", mail);
			xmlNodeSetAttribute (xml_root.account, "password", pass);
		else
			xmlNodeSetAttribute (xml_root.account, "mail", "");
			xmlNodeSetAttribute (xml_root.account, "password", "");
		end

		xmlSaveFile (xml_root.root);
		requestChars();

		destroyBlur();

		if isTimer (camerashow) then
			sm.moov = 0
			killTimer (camerashow)
		end
		if isTimer (camerasetid ) then
			killTimer (camerasetid )
		end
	end
);

function drawlogo()
	if getElementData (localPlayer, "inevent") and getElementData (localPlayer, "inevent") ~= "race" then return; end
	dxDrawImage(10, screenH * 0.9433, screenW * 0.2014, screenH * 0.0522, "img/MTA-TR.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
end

function showLogo()
	addEventHandler("onClientRender", root, drawlogo);
end
addEventHandler ("onClientResourceStart", resourceRoot, showLogo);

function hideLogo()
	removeEventHandler("onClientRender", root, drawlogo);
end

--BLUR
local sW, sH = guiGetScreenSize()
local blurShader, blurTec
local blurTick = 0;
local blurStrength = 0;

function createBlur()
	if blurShader then return end
	blurShader, blurTec = dxCreateShader("blur.fx")
	addEventHandler("onClientPreRender", root, blur)
	blurTick = getTickCount() + 5000;
end

function destroyBlur()
	if blurShader then
		blurFading = true;
		local function removeBlur ()
			if blurStrength - .1 > 0 then
				blurStrength = blurStrength - .1;
			else
				removeEventHandler("onClientPreRender", root, blur)
				destroyElement(blurShader)
				blurShader = nil
				removeEventHandler ("onClientRender", root, removeBlur);
				setTime (getRealTime().hour, getRealTime().minute);
                intro = nil;
			end
		end
		addEventHandler ("onClientRender", root, removeBlur);
	end
end

local myScreenSource = dxCreateScreenSource(sW, sH)

function blur()
    if (blurShader) then
		if getTickCount() < blurTick then return; end
		if not intro then
			startCameraShow();
			setTime (20, 00);
            intro = true;
		end
		if blurStrength < 6.8 and not blurFading then
			blurStrength = blurStrength + .05;
		end
        dxUpdateScreenSource(myScreenSource)

        dxSetShaderValue(blurShader, "ScreenSource", myScreenSource)
        dxSetShaderValue(blurShader, "BlurStrength", blurStrength)
		dxSetShaderValue(blurShader, "UVSize", sW, sH)
        dxDrawImage(0, 0, sW, sH, blurShader)
    end
end

