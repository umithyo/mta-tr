local daily_limit = get ("*Para Transfer Limiti") or 25000;
local limited = {};
local cleared = {};

function transferMoney (sender, receiver, amount)
	local amount = tonumber (amount);
	if not amount then exports.mtatr_hud:dm ("Geçersiz sayı girişi yapıldı.", sender, 200, 0, 0); return false; end
	if amount <= 0 then exports.mtatr_hud:dm ("Gönderilecek miktar sıfırdan büyük olmalı.", sender, 200, 0, 0); return false; end
	if amount > sender:getMoney() then exports.mtatr_hud:dm ("Bakiye yetersiz.", sender, 200, 0, 0); return false; end
	if not isElement (sender) or not isElement (receiver) then return false; end
	local s_id, r_id = exports.database:getPlayerId (sender), exports.database:getPlayerId (receiver);
	if s_id and r_id then 
		local limit = limited[sender:getData"ID"];
		if not limit then 
			limited[sender:getData"ID"] = 0;
			limit = 0;
		end	
		if hasPlayerReachedLimit (sender, amount) then 
			exports.mtatr_hud:dm ("Günlük limiti aştığınız için para aktarımı sağlanamadı.", sender, 200, 0, 0);
			triggerClientEvent (client, "onMoneyTransferWindowResponded", client, daily_limit - limit)
			return false;
		end
		limited[sender:getData"ID"] = (limited[sender:getData"ID"] or 0) + amount;
		limit = limited[sender:getData"ID"] or 0;
		exports.database:givePlayerMoney (receiver, amount, "Transfer from "..sender:getName());
		exports.database:takePlayerMoney (sender, amount, "Transfer to "..receiver:getName());
		exports.mtatr_hud:dm ("Para başarıyla "..receiver:getName().." adlı kullanıcıya gönderildi.", sender, 0, 255, 0);
		exports.mtatr_hud:dm (sender:getName().." adlı kullanıcı size "..amount.."₺ gönderdi!", receiver, 0, 255, 0);
		triggerClientEvent (client, "onMoneyTransferWindowResponded", client, daily_limit - limit)
		return true;
	end
end

addEvent ("onClientRequestMoneyTransfer", true);
addEventHandler ("onClientRequestMoneyTransfer", root, 
	function (player, amount)
		if not isElement (player) then 
			exports.mtatr_hud:dm ("Yanlış veya eksik kullanıcı adı.", client, 200, 0, 0);
			return;
		end	
		if not tonumber (amount) then 
			exports.mtatr_hud:dm ("Hatalı miktar girişi yaptınız.", client, 200, 0, 0);
			return;
		end	
		transferMoney (client, player, amount);
	end
);	

addEvent ("onClientRequestMoneyTransferWindow", true);
addEventHandler ("onClientRequestMoneyTransferWindow", root, 
	function ()
		local limit = limited[client:getData"ID"] or 0;
		triggerClientEvent (client, "onMoneyTransferWindowResponded", client, daily_limit - limit)
	end
);	

function hasPlayerReachedLimit (player, amount)
	return limited[player:getData"ID"] and (limited[player:getData"ID"] + amount) > daily_limit; 
end

setTimer (
	function ()
		if getRealTime().hour == 0 and getRealTime ().minute < 5 then 	
			for i, v in pairs (limited) do 
				if cleared[i] then return; end
				if v ~= 0 then 
					limited[i] = 0;
					cleared[i] = true;	
				end	
			end	
		else
			local count = 0;
			for _ in pairs (cleared) do 
				count = count + 1;
			end
			if count > 0 then 
				cleared = {};
			end	
		end
	end,
60000, 0);	