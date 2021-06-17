local drawing = false
local texts = texts.client

function createHitButtons()
	if isElement(hitWindow) then return end
	showCursor(true)
	hitWindow = guiCreateWindow(0.34, 0.26, 0.29, 0.45, "Hitman", true)

	possibleHitsGrid = guiCreateGridList(0.02, 0.08, 0.52, 0.80, true, hitWindow)
	guiGridListAddColumn(possibleHitsGrid, "Oyuncu", 0.9)
	
	bountyPut = guiCreateButton(0.25, 0.91, 0.30, 0.06, "Ödül Koy", true, hitWindow)
	guiSetProperty(bountyPut, "NormalTextColour", "FFAAAAAA")
	
	bountyEdit = guiCreateEdit(0.05, 0.90, 0.19, 0.07, "", true, hitWindow)
	
	bountyLabel = guiCreateLabel(0.01, 0.92, 0.04, 0.04, "₺", true, hitWindow)
	guiLabelSetHorizontalAlign(bountyLabel, "right", false)
	
	mostWanted = guiCreateButton(0.59, 0.08, 0.26, 0.08, "En Çok Aranan", true, hitWindow)
	guiSetProperty(mostWanted, "NormalTextColour", "FFAAAAAA")

	bountyClose = guiCreateButton(0.86, 0.92, 0.11, 0.06, "Kapat", true, hitWindow)
	guiSetProperty(bountyClose, "NormalTextColour", "FFAAAAAA") 
	
	guiGridListSetSortingEnabled(possibleHitsGrid,false)
	fillGridList()
end

function closeHitButtons()
	if isElement (hitWindow) then
		hitWindow:destroy();
		
		if drawing then
		
			removeEventHandler("onClientRender", root, drawHitList);
			drawing = false;	
			
		end	
		if isElement(creditLabel) then
		
			creditLabel:destroy();
			
		end	
		
		if isElement(hitmenGrid) then 
		
			hitmenGrid:destroy();
			
		end	
		
		showCursor(false);
		
	end
end
	
function toggleHitButtons()

	if isElement(hitWindow) then
	
		closeHitButtons();
		
	else
	
		createHitButtons();
		
	end
end	

function fillGridList()

	for i,v in ipairs( getElementsByType('player') ) do
		local row = guiGridListAddRow( possibleHitsGrid );
		local name = v:getName();
		local r, g, b  = v:getNametagColor();
		guiGridListSetItemText(possibleHitsGrid, row, 1, name,false,false);
		guiGridListSetItemColor(possibleHitsGrid, row, 1, r, g, b);
	end
	
end	
		
	
local screenW, screenH = guiGetScreenSize()

local tbl = {}

addEvent("bounty.getHitList",true)
addEventHandler("bounty.getHitList", root,
	function( playertbl )	
	
		if playertbl then
			tbl = {};
			for i, v in pairs (playertbl) do 
				table.insert (tbl, {player = i, bounty = v});
			end	
			table.sort (tbl, function(a, b) return a.bounty > b.bounty end);
			if isElement(hitmenGrid) then
				guiGridListClear(hitmenGrid);
				loadHitGrid()
			end	
		end	
		
	end
)
function createHitmenList()
	if not isElement(hitmenGrid) then
	
		hitmenGrid = guiCreateGridList(0.65, 0.31, 0.17, 0.38, true);
		guiGridListAddColumn(hitmenGrid, texts[1], 0.4);
		guiGridListAddColumn(hitmenGrid, texts[2], 0.4) ;  	
		guiGridListClear(hitmenGrid);	
		guiGridListSetSortingEnabled(hitmenGrid,false)
		addEventHandler("onClientRender", root, drawHitList);
		loadHitGrid()
	end
end	

function loadHitGrid()	
	guiGridListClear (hitmenGrid);
	if next (tbl) then
		for i,v in ipairs(tbl) do
			if isElement (v.player) then 
				local r,g,b =(v.player):getNametagColor();
				local row = guiGridListAddRow(hitmenGrid);
				local name = v.player:getName();
				local goodies = v.bounty;
				
				guiGridListSetItemText(hitmenGrid, row, 1, name, false, false);
				guiGridListSetItemText(hitmenGrid, row, 2, goodies.."₺", false, false);
				guiGridListSetItemColor(hitmenGrid, row, 1, r, g, b);
				guiGridListSetItemColor(hitmenGrid, row, 2, 50, 126, 42);
			end
		end
	end	
end	

function drawHitList()
	if tbl then
	
		drawing = true
		
		dxDrawRectangle(screenW * 0.6382, screenH * 0.2589, screenW * 0.1979, screenH * 0.4467, tocolor(9, 0, 0, 195), false)
		dxDrawText(texts[3], screenW * 0.6514, screenH * 0.2633, screenW * 0.8292, screenH * 0.2989, tocolor(255, 255, 255, 255), 0.60, "bankgothic", "left", "top", false, false, false, false, false)
		
	end	
	
	if not next (tbl) then
		dxDrawText(texts[4], screenW * 0.6417, screenH * 0.7056, screenW * 0.8361, screenH * 0.9378, tocolor(255, 255, 255, 255), 1.00, "clear", "left", "top", false, false, false, false, false)
	end	
	
end


addEventHandler("onClientGUIClick", root,
	function()
		if source == bountyClose then
		
			closeHitButtons();
			
		elseif source == mostWanted then	
		
			if drawing then
			
				removeEventHandler("onClientRender", root, drawHitList);
				drawing = false
				
				if isElement(hitmenGrid) then 
					hitmenGrid:destroy()
				end	
				
			else
			
				triggerServerEvent("bounty.getBounty",localPlayer);
				
				createHitmenList();
				
			end	
		elseif source == bountyPut then
		
			local item = guiGridListGetSelectedItem(possibleHitsGrid,row,1);
			local bounty = tonumber( guiGetText(bountyEdit) );
			
			if item == -1 then outputChatBox(texts[5], 255, 0, 0) return end
			if guiGetText(bountyEdit) == "" then outputChatBox(texts[6], 255, 0, 0) return end
			
			local name = guiGridListGetItemText(possibleHitsGrid, item, 1);
			triggerServerEvent("bounty.setBounty", localPlayer, name, bounty);
		end
	end
)	

addEventHandler("onClientGUIChanged",root,
	function()
		if source == bountyEdit then
		
			local text = tonumber( guiGetText(source) );
			
			if type(text) ~= "number" then 
			
				guiSetText(source,"")
				
			end
			
		end
	end
)	

addEvent("bounty.playSound",true)
addEventHandler("bounty.playSound", root,
	function()
	
		-- playSound ("files/killed.mp3", false);
		
	end
)
	
addCommandHandler("hitman",toggleHitButtons);