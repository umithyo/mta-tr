addEventHandler("onClientResourceStart", resourceRoot,
    function()
        ttWin = guiCreateWindow(0.43, 0.28, 0.19, 0.53, "Trend Topics", true)
        guiSetVisible(ttWin, false)

        ttGrid = guiCreateGridList(0.04, 0.05, 0.92, 0.86, true, ttWin)
        guiGridListAddColumn(ttGrid, "Topic", 0.45)
        guiGridListAddColumn(ttGrid, "Sayı", 0.4)
        ttClose = guiCreateButton(0.36, 0.93, 0.29, 0.05, "Kapat", true, ttWin)
        guiSetProperty(ttClose, "NormalTextColour", "FFAAAAAA") 

		addEventHandler ("onClientGUIClick", ttClose, function () guiSetVisible (ttWin, false) showCursor (false) end, false)	
    end
)

function toggleTtWin ()
	guiSetVisible (ttWin, not guiGetVisible (ttWin))
	showCursor(guiGetVisible (ttWin))
end

addEvent ("hashtags.getHashtags", true)
addEventHandler ("hashtags.getHashtags", root, 
	function (tbl, toggle)
		if tbl then 
			if toggle then 
				toggleTtWin()
			end	
			loadGrid(tbl);
		end
	end
)	

function loadGrid (hashtags)
	guiGridListClear(ttGrid)
	for i, v in ipairs (hashtags) do 
		local row = guiGridListAddRow (ttGrid)
		guiGridListSetItemText (ttGrid, row, 1, v[1], false, false)
		guiGridListSetItemText (ttGrid, row, 2, v[2], false, false)
	end
end	