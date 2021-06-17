GUIEditor = {
    label = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local screenW, screenH = guiGetScreenSize()
        Window = guiCreateWindow((screenW - 576) / 2, (screenH - 401) / 2, 576, 401, "Maden İşleyici", false)
        guiWindowSetSizable(Window, false)
        guiSetProperty(Window, "CaptionColour", "FFE389F0")

        ImageCopper = guiCreateStaticImage(0.05, 0.10, 0.13, 0.15, "misc/element.png", true, Window)
        ImageSilver = guiCreateStaticImage(0.05, 0.31, 0.13, 0.15, "misc/element2.png", true, Window)
        ImageMagnesium = guiCreateStaticImage(0.05, 0.53, 0.13, 0.15, "misc/element3.png", true, Window)
        ImageIron = guiCreateStaticImage(0.05, 0.74, 0.13, 0.15, "misc/element4.png", true, Window)
		ImageGold = guiCreateStaticImage(0.38, 0.10, 0.13, 0.15, "misc/element5.png", true, Window)
        AmountCopper = guiCreateLabel(0.19, 0.13, 0.13, 0.05, "??₺", true, Window)
        guiSetFont(AmountCopper, "default-bold-small")
        guiLabelSetColor(AmountCopper, 21, 244, 10)
        guiLabelSetHorizontalAlign(AmountCopper, "center", false)
        GramCopper = guiCreateLabel(0.19, 0.20, 0.13, 0.05, "?? G", true, Window)
        guiSetFont(GramCopper, "default-bold-small")
        guiLabelSetColor(GramCopper, 245, 197, 7)
        guiLabelSetHorizontalAlign(GramCopper, "center", false)
        AmountMagnesium = guiCreateLabel(0.19, 0.55, 0.13, 0.05, "??₺", true, Window)
        guiSetFont(AmountMagnesium, "default-bold-small")
        guiLabelSetColor(AmountMagnesium, 21, 244, 10)
        guiLabelSetHorizontalAlign(AmountMagnesium, "center", false)
        GramSilver = guiCreateLabel(0.19, 0.41, 0.13, 0.05, "?? G", true, Window)
        guiSetFont(GramSilver, "default-bold-small")
        guiLabelSetColor(GramSilver, 245, 197, 7)
        guiLabelSetHorizontalAlign(GramSilver, "center", false)
        AmountSilver = guiCreateLabel(0.19, 0.33, 0.13, 0.05, "??₺", true, Window)
        guiSetFont(AmountSilver, "default-bold-small")
        guiLabelSetColor(AmountSilver, 21, 244, 10)
        guiLabelSetHorizontalAlign(AmountSilver, "center", false)
        GramMagnesium = guiCreateLabel(0.19, 0.63, 0.13, 0.05, "?? G", true, Window)
        guiSetFont(GramMagnesium, "default-bold-small")
        guiLabelSetColor(GramMagnesium, 245, 197, 7)
        guiLabelSetHorizontalAlign(GramMagnesium, "center", false)
        AmountIron = guiCreateLabel(0.19, 0.76, 0.13, 0.05, "??₺", true, Window)
        guiSetFont(AmountIron, "default-bold-small")
        guiLabelSetColor(AmountIron, 21, 244, 10)
        guiLabelSetHorizontalAlign(AmountIron, "center", false)
        GramIron = guiCreateLabel(0.19, 0.84, 0.13, 0.05, "?? G", true, Window)
        guiSetFont(GramIron, "default-bold-small")
        guiLabelSetColor(GramIron, 245, 197, 7)
        guiLabelSetHorizontalAlign(GramIron, "center", false)
        calcButton = guiCreateButton(0.51, 0.83, 0.12, 0.06, "İşle", true, Window)
        guiSetFont(calcButton, "default-bold-small")
        guiSetProperty(calcButton, "NormalTextColour", "FFE69EEF")
        SellButton = guiCreateButton(0.65, 0.83, 0.12, 0.06, "Sat", true, Window)
        guiSetFont(SellButton, "default-bold-small")
        guiSetProperty(SellButton, "NormalTextColour", "FFE69EEF")
        close = guiCreateButton(0.86, 0.83, 0.12, 0.06, "Kapat", true, Window)
        guiSetFont(close, "default-bold-small")
        guiSetProperty(close, "NormalTextColour", "FFFF6363")
        Total = guiCreateLabel(0.51, 0.76, 0.32, 0.05, "Genel Toplam", true, Window)
        guiSetFont(Total, "default-bold-small")
        TotalGrams = guiCreateLabel(0.51, 0.68, 0.5, 0.06, "Toplam Gramaj", true, Window)
        guiSetFont(TotalGrams, "default-small")
        guiLabelSetColor(TotalGrams, 245, 197, 7)
        AmountGold = guiCreateLabel(0.53, 0.13, 0.13, 0.05, "??₺", true, Window)
        guiSetFont(AmountGold, "default-bold-small")
        guiLabelSetColor(AmountGold, 21, 244, 10)
        guiLabelSetHorizontalAlign(AmountGold, "center", false)
        GramGold = guiCreateLabel(0.53, 0.20, 0.13, 0.05, "?? G", true, Window)
        guiSetFont(GramGold, "default-bold-small")
        guiLabelSetColor(GramGold, 245, 197, 7)
        guiLabelSetHorizontalAlign(GramGold, "center", false)
        GUIEditor.label[1] = guiCreateLabel(0.05, 0.25, 0.13, 0.06, "Gümüş", true, Window)
        guiSetFont(GUIEditor.label[1], "default-small")
        guiLabelSetColor(GUIEditor.label[1], 211, 211, 211)
        guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
        GUIEditor.label[2] = guiCreateLabel(0.05, 0.04, 0.13, 0.06, "Bakır", true, Window)
        guiSetFont(GUIEditor.label[2], "default-small")
        guiLabelSetColor(GUIEditor.label[2], 241, 141, 61)
        guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
        GUIEditor.label[3] = guiCreateLabel(0.05, 0.46, 0.13, 0.06, "Magnezyum", true, Window)
        guiSetFont(GUIEditor.label[3], "default-small")
        guiLabelSetColor(GUIEditor.label[3], 153, 153, 153)
        guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
        GUIEditor.label[4] = guiCreateLabel(0.05, 0.68, 0.13, 0.06, "Demir", true, Window)
        guiSetFont(GUIEditor.label[4], "default-small")
        guiLabelSetColor(GUIEditor.label[4], 123, 123, 123)
        guiLabelSetHorizontalAlign(GUIEditor.label[4], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[4], "center")
        GUIEditor.label[5] = guiCreateLabel(0.38, 0.04, 0.13, 0.06, "Altın", true, Window)
        guiSetFont(GUIEditor.label[5], "default-small")
        guiLabelSetColor(GUIEditor.label[5], 238, 203, 7)
        guiLabelSetHorizontalAlign(GUIEditor.label[5], "center", false)
        guiLabelSetVerticalAlign(GUIEditor.label[5], "center")   

		guiSetVisible (Window, false);
    end
)

local elementsTable = {--Name of the element,how much per gram of rock, how much ₺₺ per unit
	["Gold"] = {0.01,6.9},
	["Silver"] = {0.04,2.3},
	["Copper"] = {0.08,1.3},
	["Iron"] = {0.55,0.3},
	["Magnesium"] = {0.3,0.45},
};

function showTradingGUI()
	guiSetVisible(Window, true)
	showCursor(true)
	local gram = getGrams()
	guiSetText(TotalGrams,"Toplam gramaj: "..gram.." G")
end

function hideTradingGUI()
	if guiGetVisible(Window) then
		guiSetVisible(Window, false)
		showCursor(false)
		triggerServerEvent("mining.freeze", resourceRoot, false)
		toggleAllControls(true)
		calculated = false
		PayTotal = false
		guiSetText(GramIron,"?? G")
		guiSetText(AmountIron, "?? ₺")
		guiSetText(GramCopper,"?? G")
		guiSetText(AmountCopper, "?? ₺")
		guiSetText(GramSilver,"?? G")
		guiSetText(AmountSilver, "?? ₺")
		guiSetText(GramMagnesium,"?? G")
		guiSetText(AmountMagnesium, "?? ₺")
		guiSetText(GramGold,"?? G")
		guiSetText(AmountGold, "?? ₺")
		guiSetText(Total, "Genel Toplam: ??")
		if isTimer(calcTimer) then
			killTimer(calcTimer)
		end
		if isTimer(payTimer) then
			killTimer(payTimer)
		end
	end
end

function handleBtns()
	if ( source == close ) then
		hideTradingGUI()
	elseif ( source == calcButton ) then
		if calculated then return end
		triggerServerEvent ("mining.getPayOffset", localPlayer);
		calculated = true
	elseif ( source == SellButton) then
		if not calculated then outputChatBox("Satmadan önce madeni işlemelisin.", 255, 0, 0) return end
		local gram = getGrams()
		if not isPedInVehicle(localPlayer) then return end
		if not isPedInVehicle(localPlayer) then return end
		triggerServerEvent("mining.Pay", resourceRoot, PayTotal, gram)
		hideTradingGUI()
		noGram()
		PayTotal = false
	end
end
addEventHandler("onClientGUIClick",root,handleBtns)

addEvent("mining.calculate", true)
addEventHandler("mining.calculate", root, function(poffset)
	PayTotal = 0
	local grams = getGrams()
	--
	local unitc,unitcpay = elementsTable["Copper"][1],elementsTable["Copper"][2]
	gramC = math.ceil(grams*unitc)
	PayTotal = math.ceil(gramC*unitcpay)+PayTotal
	Copper = math.ceil((gramC*unitcpay)*poffset)
	guiSetText(GramCopper,gramC.." G")
	guiSetText(AmountCopper, Copper.."₺")
	--
	local uniti,unitipay = elementsTable["Iron"][1],elementsTable["Iron"][2]
	gramI = math.ceil(grams*uniti)
	PayTotal = math.ceil(gramI*unitipay)+PayTotal
	Iron = math.ceil((gramI*unitipay)*poffset)
	guiSetText(GramIron,gramI.." G")
	guiSetText(AmountIron, Iron.."₺")
	--
	local units,unitspay = elementsTable["Silver"][1],elementsTable["Silver"][2]
	gramS = math.ceil(grams*units)
	PayTotal = math.ceil(gramS*unitspay)+PayTotal
	Silver = math.ceil((gramS*unitspay)*poffset)
	guiSetText(GramSilver,gramS.." G")
	guiSetText(AmountSilver, Silver.."₺")
	--
	local unitb,unitbpay = elementsTable["Magnesium"][1],elementsTable["Magnesium"][2]
	gramB = math.ceil(grams*unitb)
	PayTotal = math.ceil(gramB*unitbpay)+PayTotal
	Magnesium = math.ceil((gramB*unitbpay)*poffset)
	guiSetText(GramMagnesium,gramB.." G")
	guiSetText(AmountMagnesium, Magnesium.."₺")
	--
	local unitg,unitgpay = elementsTable["Gold"][1],elementsTable["Gold"][2]
	gramG = math.ceil(grams*unitg)
	PayTotal = math.ceil(gramG*unitgpay)+PayTotal
	Gold = math.ceil((gramG*unitgpay)*poffset)
	guiSetText(GramGold,gramG.." G")
	guiSetText(AmountGold, Gold.."₺")
	--
	GrandTotal = Copper+Iron+Silver+Magnesium+Gold
	GrandTotalGrams = gramB+gramC+gramG+gramS+gramI
	guiSetText(Total, "Genel Toplam: "..PayTotal.."₺")
end)
