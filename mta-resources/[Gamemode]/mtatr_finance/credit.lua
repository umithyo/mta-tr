local week_ts = 604800;
local interest = 3.4;
local interest_rate = .05;
local upper_limit = 1500000;
local time_to_get_credit = 10 -- days
local limit_base = 50000;
local limit_rate = 100;

function setCreditData (player, credit, key, data)
	local credit = tostring (credit);
	if not exports.mtatr_accounts:isPlayerLoggedIn(player) then return; end
	local id = exports.database:getPlayerId(player);
	if not id then return; end
	local credits = getPlayerCredits(player);
	if not credits[credit] then 
		credits[credit] = {};
	end
	credits[credit][key] = data;
	exports.database:setPlayerData (id, "fr_stats", "credit", toJSON(credits));
	updateCreditGUI(player);
	return true;
end	

function getCreditData (player, credit, key)
	local credit = tostring (credit);
	local credits = getPlayerCredits(player);
	if credits[credit] then 
		local data = credits[credit][key];
		return tonumber (data) or data;
	end
	return false;
end	

function getPlayerCredits(player)
	if not exports.mtatr_accounts:isPlayerLoggedIn(player) then return {} end
	local id = exports.database:getPlayerId(player);
	if not id then return {} end
	local credits = exports.database:getPlayerData (id, "fr_stats", "credit") or "[[]]";
	return fromJSON (credits) or {};
end	

function getCreditNextPaymentDate (player, credit)
	return getCreditData (player, credit, "date");
end

function getCreditMinimalAmount (player, credit)
	return getCreditData (player, credit, "minimal");
end	
	
function assignPlayerCredit (player, installment, amount)
	local credit = getRealTime().timestamp;
	local natural_interest = installment/10;
	local interest_ = interest + natural_interest;
	local debt = amount + ((amount*interest_) / 100);
	setCreditData (player, credit, "installment", installment);
	setCreditData (player, credit, "amount", amount);
	setCreditData (player, credit, "debt", debt);
	setCreditData (player, credit, "first_installment", installment);
	setCreditData (player, credit, "minimal", debt/installment);
	setCreditData (player, credit, "date", getRealTime().timestamp + week_ts);
	exports.database:givePlayerMoney (player, amount, "Credit");
	return true;
end	

function payCredit(player, credit, amount)
	local amount = tonumber (amount);
	if not amount then return false; end
	local money = getPlayerMoney (player);
	if money < amount then 
		outputChatBox ("Bu borcu ödemeye paranız yetmiyor.", player, 255, 0, 0);
		return;
	end	
	exports.database:takePlayerMoney (player, amount, "Credit Payment");
	local debt = getCreditData (player, credit, "debt");
	local new_amount = debt-amount;
	if new_amount == 0 then 
		return clearCredit (player, credit);
	elseif new_amount < 0 then 
		local offset = new_amount * -1;
		givePlayerMoney (player, offset, "Credit Offset");
		return clearCredit(player, credit);
	end	
	local installment = getCreditData (player, credit, "installment");
	setCreditData (player, credit, "installment", installment-1);
	setCreditData (player, credit, "date", getRealTime().timestamp + week_ts);
	outputChatBox ("Taksit başarıyla yatırıldı! Kalan taksit: "..tostring (installment-1), player, 115, 255, 115);
	return setCreditData (player, credit, "debt", new_amount);
end

function clearCredit (player, credit)
	local id = exports.database:getPlayerId(player);
	local credits = getPlayerCredits(player);
	credits[credit] = nil;
	exports.database:setPlayerData (id, "fr_stats", "credit", toJSON(credits));
	updateCreditGUI(player);
	outputChatBox ("[TR FİNANS]: Tebrikler! Kredinizi tamamen ödediniz. Bizi tercih ettiğiniz için teşekkürler.", player, 115, 255, 115);
	return true;
end

function punishCredit (player, credit)
	local cooldown = getCreditData (player, credit, "cooldown") or 0;
	if getRealTime().timestamp < cooldown then return; end
	local debt = getCreditData (player, credit, "debt");
	local new_d = debt + ((debt * (interest + interest_rate)) / 100);
	setCreditData (player, credit, "cooldown", getRealTime().timestamp + week_ts);
	outputChatBox ("[TR FİNANS]: Borcunuz geciktiği için faiz uygulandı. Daha fazla bilgi için F5'e basın.", player, 200, 0, 0);
	return setCreditData (player, credit, "debt", new_d);
end

function checkCredit (player)
	local player = isElement (player) and player or source;
	for i, v in pairs (getPlayerCredits(player)) do 
		local date = getCreditNextPaymentDate (player, i);
		local time = getRealTime().timestamp;
		if time > (date or math.huge) then 
			punishCredit(player, i);
		end	
	end	
end

setTimer (
	function ()
		for i, v in ipairs (getElementsByType"player") do 
			checkCredit (v);
		end
	end,
60000, 0);	

function canPlayerGetCredit (player, amount)
	local id = exports.database:getPlayerId(player);
	if not id then 
		return false; 
	end	
	local register_d = exports.database:getPlayerData (id, "userinfo", "registerdate");
	local playtime = getRealTime().timestamp - register_d;
	if amount >= upper_limit then 
		outputChatBox ("Girdiğiniz miktar çok yüksek. Kredi kabul edilemiyor.", player, 255, 0, 0);
		return false;
	end	
	if playtime < (week_ts/7) * time_to_get_credit then 
		outputChatBox ("Oyun saatiniz kredi çekmeniz için çok az.", player, 255, 0, 0);
		return false;
	end	
	local days = (playtime/60/60/24);
	local uplimit = (days*limit_rate) + limit_base;
	if amount >= uplimit then 
		outputChatBox ("Oyun saatinize göre en fazla "..math.floor (uplimit).."₺ kredi çekebilirsiniz.", player, 255, 0, 0);
		return false;
	end	
	local total = 0;
	for i, v in pairs (getPlayerCredits(player)) do 
		total = total + v.debt;
	end
	if total >= uplimit then 
		outputChatBox ("Birikmiş kredilerinizi ödemeden yeni kredi çekemezsiniz.", player, 255, 0, 0);
		return false;
	end	
	return true;
end

addEvent ("onPlayerCoreLogin");
addEventHandler ("onPlayerCoreLogin", root, 
	function ()
		updateCreditGUI (source);
		checkCredit(source);
	end
);	

function updateCreditGUI(player)
	local player = player or client;
	local tbl = {};
	for i, v in pairs (getPlayerCredits(player)) do 
		v.id = i;
		v.min = getCreditMinimalAmount(player, i);
		table.insert (tbl, v);
	end
	table.sort (tbl, function (a, b) return a.id < b.id; end);
	triggerLatentClientEvent (player, "credit.request", player, tbl);
end
addEvent ("credit.load", true);
addEventHandler ("credit.load", root, updateCreditGUI);

addEvent ("credit.pay", true);
addEventHandler ("credit.pay", root, 
	function (type, credit)
		local amount = getCreditData (client, credit, "debt");
		if type == "payinstall" then 
			amount = getCreditMinimalAmount (client, credit);
		end	
		payCredit (client, credit, amount);
	end
);

addEvent ("credit.apply", true);
addEventHandler ("credit.apply", root,
	function (amount, installment)
		if not tonumber (installment) then return; end
		if canPlayerGetCredit(client, amount) then  
			assignPlayerCredit (client, installment, amount);
			outputChatBox ("[TR FİNANS]: Kredi başvurunuz olumlu sonuçlandı. İyi günlerde kullanın. ", client, 115, 255, 115);
		end
	end
);	