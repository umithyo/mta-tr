function importTextures2()
	txd = engineLoadTXD ( "dust2x2.txd" )
		engineImportTXD ( txd, 13051 )
	col = engineLoadCOL ( "dust2x2.col" )
	dff = engineLoadDFF ( "dust2x2.dff", 0 )
	engineReplaceCOL ( col, 13051 )
	engineReplaceModel ( dff, 13051 )
	engineSetModelLODDistance(13051, 2000)
        outputChatBox( 'Map: de_dust2x2_winter, Converted by Luc1FeR.', 0, 228, 33, true );
        outputChatBox( 'Visit my site www.luc1fer.u2m.ru', 255, 0, 0, true );
end

setTimer ( importTextures2, 100, 1)
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