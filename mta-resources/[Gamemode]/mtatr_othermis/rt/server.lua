local result;
local timeout = 8 -- seconds
local rep = 10 -- minutes
local m_p = {100, 600};
local e_p = {3, 150};
local RT_ACTIVE = false;
local prize_money = 0;
local prize_exp = 0;
local stopper;

function startRt()
	RT_ACTIVE = true;
	prize_money = math.random (m_p[1], m_p[2]);
	prize_exp = math.random (e_p[1], e_p[2]);
	local odds = math.random(2);
	if odds == 1 then
		local output, r = generateMath();
		result = r;
		outputChatBox ("[TEST] #1FB900"..output.."#FFDA4F işlemini çöz "..prize_money.."₺ ve +"..prize_exp.." exp kazan!", root, 255, 218, 79, true);
	else
		result = generateRandomString(8);
		outputChatBox ("[TEST] #1FB900"..result.."#FFDA4F yaz "..prize_money.."₺ ve +"..prize_exp.." exp kazan!", root, 255, 218, 79, true);
	end

	stopper = setTimer (stopRt, timeout*1000, 1);
end
addEventHandler ("onResourceStart", resourceRoot, startRt);

function stopRt(winner)
	if not winner then
		outputChatBox ("Test bitti, kimse kazanamadı.", root, 255, 218, 79);
	else
		outputChatBox ("Testi #ffffff"..winner:getName().."#FFDA4F kazandı!", root, 255, 218, 79, true);
		giveRTPrize(winner);
	end
	result = nil;
	RT_ACTIVE = false;
	prize_money = 0;
	prize_exp = 0;
	if isTimer (stopper) then stopper:destroy(); end
	setTimer (startRt, rep*1000*60, 1);
end

function giveRTPrize (winner)
	exports.database:givePlayerMoney (winner, prize_money, "Reaction Test");
	exports.mtatr_mode:givePlayerCharacterExperience (winner, prize_exp);
end

addEventHandler ("onPlayerChat", root,
	function (msg, typ)
		if not RT_ACTIVE then return; end
		if typ == 0 then
			if msg == tostring (result) then
				Timer(stopRt, 100, 1, source);
			end
		end
	end
);
