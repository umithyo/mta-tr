function importTextures2()
	txd = engineLoadTXD ( "dust2.txd" )
		engineImportTXD ( txd, 13051 )
	col = engineLoadCOL ( "dust2.col" )
	dff = engineLoadDFF ( "dust2.dff", 0 )
	engineReplaceCOL ( col, 13051 )
	engineReplaceModel ( dff, 13051 )
	engineSetModelLODDistance(13051, 2000)
end

setTimer ( importTextures2, 1000, 1)
--addCommandHandler("replace",importTextures2)

addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()),
	function()
		engineRestoreCOL(13051)
		engineRestoreModel(13051)
		destroyElement(dff)
		destroyElement(col)
		destroyElement(txd)
	end
)