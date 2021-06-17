addEvent ("3dmodel.active", true);
addEventHandler('3dmodel.active', root,
    function(state)
		if state == true then 
			txd = engineLoadTXD ( "Files/cmodel.txd" )	engineImportTXD ( txd, 496 )

			dff = engineLoadDFF ( "Files/cmodel.dff", 0 )   engineReplaceModel ( dff, 496 )
			
			local txd = engineLoadTXD('Files/3dmodel.txd',true)
			engineImportTXD(txd, 16209)
			engineImportTXD(txd, 16208)
			engineImportTXD(txd, 16207)
	 
			local dff = engineLoadDFF('Files/3dmodel.dff', 0)
			engineReplaceModel(dff, 16209)
	 
			local col = engineLoadCOL('Files/3dmodel.col')
			engineReplaceCOL(col, 16209)
			engineSetModelLODDistance(16209, 0)

			local dff = engineLoadDFF('Files/3dmodel1.dff', 0)
			engineReplaceModel(dff, 16208)
	 
			local col = engineLoadCOL('Files/3dmodel1.col')
			engineReplaceCOL(col, 16208)
			engineSetModelLODDistance(16208, 0)
			
			local dff = engineLoadDFF('Files/3dmodel2.dff', 0)
			engineReplaceModel(dff, 16207)
	 
			local col = engineLoadCOL('Files/3dmodel2.col')
			engineReplaceCOL(col, 16207)
			engineSetModelLODDistance(16207, 0)     
			local txd = engineLoadTXD('Files/3dmodel3.txd',true)
			engineImportTXD(txd, 16118)
 
			local dff = engineLoadDFF('Files/3dmodel3.dff', 0)
			engineReplaceModel(dff, 16118)
 
			local col = engineLoadCOL('Files/3dmodel3.col')
			engineReplaceCOL(col, 16118)
			engineSetModelLODDistance(16118, 0)
		else
			engineRestoreModel(16209);
			engineRestoreModel(16208);
			engineRestoreModel(16207);
			engineRestoreModel(16118);
			engineRestoreCOL(16209);
			engineRestoreCOL(16208);
			engineRestoreCOL(16207);
			engineRestoreCOL(16118);
			engineRestoreModel(496);
		end	
	end 
)

triggerEvent ("3dmodel.active", localPlayer);