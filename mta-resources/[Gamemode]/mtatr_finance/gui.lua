KEY = "F5";
fn = {
 	window = {},
    tab = {},
    tabpanel = {},
    edit = {},
    button = {},
    label = {},
    gridlist = {},
    combobox = {}
}

local screenW, screenH = guiGetScreenSize()
fn.window[1] = guiCreateWindow((screenW - 453) / 2, (screenH - 313) / 2, 453, 313, "Finans ("..KEY..")", false)
guiWindowSetSizable(fn.window[1], false)
guiWindowSetMovable (fn.window[1], false);
guiSetVisible (fn.window[1], false);

fn.tabpanel[1] = guiCreateTabPanel(0.02, 0.07, 0.96, 0.89, true, fn.window[1])

fn.tab[1] = guiCreateTab("Havale", fn.tabpanel[1])

fn.label[1] = guiCreateLabel(0.17, 0.33, 0.14, 0.09, "Kullanıcı", true, fn.tab[1])
fn.label[2] = guiCreateLabel(0.17, 0.45, 0.14, 0.09, "Miktar", true, fn.tab[1])
fn.edit[1] = guiCreateEdit(0.33, 0.33, 0.48, 0.09, "", true, fn.tab[1])
fn.edit[2] = guiCreateEdit(0.33, 0.45, 0.48, 0.09, "", true, fn.tab[1])
fn.label[3] = guiCreateLabel(0, 0, 434, 18, "Günlük Limit: ", false, fn.tab[1])
guiSetFont(fn.label[3], "default-bold-small")
guiLabelSetHorizontalAlign(fn.label[3], "center", false)
guiLabelSetVerticalAlign(fn.label[3], "center")
fn.button[1] = guiCreateButton(0.44, 0.64, 0.19, 0.09, "Gönder", true, fn.tab[1])
guiSetProperty(fn.button[1], "NormalTextColour", "FFAAAAAA")

fn.tab[2] = guiCreateTab("Kredi", fn.tabpanel[1])

fn.tabpanel[2] = guiCreateTabPanel(0.00, 0.00, 0.97, 0.96, true, fn.tab[2])

fn.tab[3] = guiCreateTab("Kredi Başvurusu", fn.tabpanel[2])

fn.edit[3] = guiCreateEdit(0.18, 0.08, 0.57, 0.12, "", true, fn.tab[3])
fn.label[4] = guiCreateLabel(0.01, 0.09, 0.14, 0.11, "Miktar", true, fn.tab[3])
guiLabelSetVerticalAlign(fn.label[4], "center")
fn.combobox[1] = guiCreateComboBox(76, 53, 241, 151, "", false, fn.tab[3])
fn.label[5] = guiCreateLabel(0.01, 0.22, 0.14, 0.11, "Vade", true, fn.tab[3])
guiLabelSetVerticalAlign(fn.label[5], "center")
fn.button[2] = guiCreateButton(0.81, 0.23, 0.16, 0.11, "Başvur", true, fn.tab[3])
guiSetProperty(fn.button[2], "NormalTextColour", "FFAAAAAA")

fn.tab[4] = guiCreateTab("Kredilerim", fn.tabpanel[2])

fn.gridlist[1] = guiCreateGridList(0.01, 0.02, 0.99, 0.81, true, fn.tab[4])
guiGridListAddColumn(fn.gridlist[1], "Açıklama", 0.35)
guiGridListAddColumn(fn.gridlist[1], "Son Ödeme Tarihi", 0.2)
guiGridListAddColumn(fn.gridlist[1], "Borç", 0.2)
guiGridListAddColumn(fn.gridlist[1], "Taksit Tutarı", 0.2)
guiGridListSetSortingEnabled (fn.gridlist[1], false);

fn.button[3] = guiCreateButton(0.01, 0.85, 0.25, 0.10, "Borcu öde", true, fn.tab[4])
guiSetProperty(fn.button[3], "NormalTextColour", "FFAAAAAA")
fn.button[4] = guiCreateButton(0.73, 0.85, 0.25, 0.10, "Taksidi öde", true, fn.tab[4])
guiSetProperty(fn.button[4], "NormalTextColour", "FFAAAAAA")   

function ts (name, ...)
	return triggerServerEvent (name, localPlayer, ...);
end

gt = function (g, column)
	if g then 
		local item = guiGridListGetSelectedItem (g);
		if item == -1 then 
			return false;
		end
		return guiGridListGetItemText (g, item, column or 1);
	end	
end	

gd = function (g, column)
	if g then 
		local item = guiGridListGetSelectedItem (g);
		if item == -1 then 
			return false;
		end
		return guiGridListGetItemData (g, item, column or 1);
	end	
end	