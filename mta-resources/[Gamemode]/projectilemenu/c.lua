local projectiles = {
[16]="Grenade",
[17]="Tear Gas Grenade",
[18]="Molotov",
[19]="Rocket (simple)",
[20]="Rocket (heat seeking)",
[21]="Air Bomb",
[39]="Satchel Charge"
}
local abElems = {}

local playerProjectiles = {
	[localPlayer] = {}
}

addEvent("wolfram.projectilemenu",true)
addEventHandler("wolfram.projectilemenu",localPlayer,
	function()
		if isElement (abuseWin) then
			closeAbuseWindow ()
		else		
			createAbuseWindow ()
		end	
	end
)	

function createAbuseWindow()
	if isElement(abuseWin) then return end
	showCursor(true)
	abuseWin = guiCreateWindow(0.39, 0.28, 0.22, 0.29, "Select Projectile", true)
	abuseGrid = guiCreateGridList(0.03, 0.09, 0.94, 0.50, true, abuseWin)
	guiGridListAddColumn(abuseGrid, "ID", 0.3)
	guiGridListAddColumn(abuseGrid, "Name", 0.4) 
	abuseForceLabel = guiCreateLabel(0.63, 0.89, 0.18, 0.06, "Force:", true, abuseWin)
	abuseForceEdit = guiCreateEdit(0.81, 0.89, 0.14, 0.06, "", true, abuseWin)   
	abElems= {abuseGrid,abuseWin,abuseForceEdit,abuseForceLabel}	

	for k,v in pairs (projectiles) do
		local row = guiGridListAddRow(abuseGrid)
		guiGridListSetItemText(abuseGrid,row,1,k,false,false)
		guiGridListSetItemText(abuseGrid,row,2,v,false,false)
	end	
end	

function closeAbuseWindow ()
	for i,v in ipairs (abElems) do
		if isElement(v) then
			destroyElement(v)
			showCursor(false)
		end
	end
end	

addEventHandler ("onClientGUIChanged",root,
	function()
		if source == abuseForceEdit then
			local text = guiGetText(source)
			if type(tonumber(text)) ~= "number" then
				guiSetText(source,"")
			end
		end	
	end
)	

addEventHandler ("onClientGUIDoubleClick",root,
	function()
		if source == abuseGrid then
			local item = guiGridListGetSelectedItem(source)
			if item ~= -1 then
				local prj  = playerProjectiles[localPlayer]
				prj[1] = tonumber(guiGridListGetItemText(source,item,1))
				if guiGetText (abuseForceEdit) ~= "" then
					prj[2] = tonumber (guiGetText(abuseForceEdit))
				end
				closeAbuseWindow()
				outputChatBox("Changes saved!",255,125,0)
			end
		end	
	end
)
	
addEvent ("wolfram.createprojectile",true)
addEventHandler ("wolfram.createprojectile",localPlayer,
	function()
		local prj  = playerProjectiles[localPlayer]
		local force = tonumber(prj[2]) or 1.0
		local id = prj[1] or 19
		local xg,yg,zg=getElementPosition(localPlayer)
		local target = getPedTarget(localPlayer)
		createProjectile(getLocalPlayer(),id,xg,yg,zg + 2,force,target)
	end
)	
