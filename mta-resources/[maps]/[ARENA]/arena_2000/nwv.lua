function ReplaceVehicle ( )

 
txd = engineLoadTXD ( "models/vgsssignage02.txd" )
engineImportTXD ( txd, 8323 )
end

 
addEventHandler( 'onClientResourceStart', getResourceRootElement( getThisResource() ), ReplaceVehicle )