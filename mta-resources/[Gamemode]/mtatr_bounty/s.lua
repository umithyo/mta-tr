local hits = {}
local clnt = {}
local reasons = texts.server[1]

function getHitmen()
	return hits or {}
end


function isPlayerInHitList(player)
	if not isElement(player) then return false end
	return hits[player];
end	

addEvent("bounty.setBounty",true)
addEventHandler("bounty.setBounty",root,
	function(name,bounty)
		if name then 
			if bounty then
				if getPlayerMoney(client) < bounty then 
					outputChatBox ("Yeterli paranız yok!", client, 255, 0, 0);
					return;
				end	
			
				local target = Player(name)
				local bounty = tonumber(bounty)
				
				if isPlayerInHitList(target) then outputChatBox(texts.server[2], client, 255, 0, 0 ); return end
				if target == client then outputChatBox(texts.server[6] , client, 255, 0, 0) return end
				
				outputChatBox(texts.server[3]:format(client:getName(), name, bounty), root, 255, 125, 0);
				
				hits[target] = bounty;
				clnt[target] = client;
				
				exports.database:takePlayerMoney (client, bounty, "Bounty on "..name);
				for _, allPlayers in ipairs (getElementsByType("player")) do
					triggerClientEvent(allPlayers, "bounty.getHitList", allPlayers, getHitmen());
				end
			end
		end
	end
)	

addEvent("bounty.getBounty",true)
addEventHandler("bounty.getBounty", root,
	function()
		for _, allPlayers in ipairs (getElementsByType("player")) do
			triggerClientEvent(allPlayers, "bounty.getHitList", allPlayers, getHitmen());
		end
	end
)	

addEventHandler("onPlayerWasted", root,
	function(_, killer, wep)
	
		if not hits[source] then return end
		if killer == source then return end
		if not isElement (killer) then return end
		if getElementType(killer) == "vehicle" then return; end
		
		local bounty = tonumber(hits[source]);
		local a = texts.server[4]
		if not bounty then return end
		
		outputChatBox(a:format(getPlayerName(killer), getPlayerName (source), bounty), root, 40, 225, 12);
		
		exports.database:givePlayerMoney (killer, bounty, "Bounty on "..source:getName());
		
		triggerClientEvent(source,"bounty.playSound",source)
		
		clnt[source] = nil;	
		hits[source] = nil;
		
		for _, allPlayers in ipairs (getElementsByType("player")) do
			triggerClientEvent(allPlayers, "bounty.getHitList", allPlayers, getHitmen());
		end
		
	end
)	

addEventHandler("onPlayerQuit", root,
	function()

		if not hits[source] then return end
		
		local a = texts.server[5]
		outputChatBox(a:format(source:getName()), root, 225, 40, 12);
		
		local customer = clnt[source];
		exports.database:givePlayerMoney (customer, tonumber(hits[source]), "Bounty on "..source:getName() );
		
		clnt[source] = nil;	
		hits[source] = nil;
		
		for _, allPlayers in ipairs (getElementsByType("player")) do
			triggerClientEvent(allPlayers, "bounty.getHitList", allPlayers, getHitmen());
		end
		
	end
)	