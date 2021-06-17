function createPro(source)
	 local isAdmin = exports.mtatr_accounts:isPlayerAdmin(source); 
	if isAdmin then	
		triggerClientEvent(source,"wolfram.createprojectile",source)
	end
end

function openProjectileMenu(source)
	local isAdmin = exports.mtatr_accounts:isPlayerAdmin(source);
	if isAdmin then	
		triggerClientEvent(source,"wolfram.projectilemenu",source)
	end	
end	

addEventHandler ("onResourceStart",resourceRoot,
	function()	
		addCommandHandler ("createprojectile",createPro)
		addCommandHandler("prmenu",openProjectileMenu)
	end
)