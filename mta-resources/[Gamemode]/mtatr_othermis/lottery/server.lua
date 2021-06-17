local lt_running = false;
local lt_part = {};
local lt_number = 0;
local lt_max = 30;
local lt_prize = 0;
local lt_max_p = 60000;
local lt_timeout = 1; -- minutes
local lt_rep = 6; -- minutes
local tick_pr = 5000;
local lt_taken = {};

function startLt()
	lt_number = math.random(lt_max);
	lt_prize = math.random(30000, lt_max_p);
	outputChatBox ("#FBC4FF[LOTO] #ffffff"..lt_prize.."₺ #FBC4FFkazanmak için biletini tükenmeden al! /loto <1-"..lt_max.."> ("..tick_pr.."₺)", root, 255, 255, 255, true);
	lt_stopper = setTimer (stopLt, lt_timeout * 60 * 1000, 1);
	lt_running = true;
end
-- addEventHandler ("onResourceStart", resourceRoot, startLt);
setTimer (startLt, lt_rep * 60 * 1000, 1);

function stopLt ()
	local winner;
	for i, v in pairs (lt_part) do
		if tostring (v) == tostring (lt_number) then
			winner = i;
		end
	end
	if winner then
		outputChatBox ("#FBC4FF[LOTO] #ffffff"..winner:getName().." #FBC4FFşanslı numara #ffffff"..lt_number.."#FBC4FF ile #ffffff"..lt_prize.."₺#FBC4FF ödülü kazandı!", root, 255, 255, 255, true);
		exports.database:givePlayerMoney (winner, lt_prize, "Lottery");
	else
		outputChatBox ("#FBC4FF[LOTO] Çekiliş bitti, kazanan çıkmadı.#ffffff ["..lt_number.."]", root, 255, 255, 255, true);
	end
	lt_number = 0;
	lt_prize = 0;
	if isTimer(lt_stopper) then lt_stopper:destroy(); end
	setTimer (startLt, lt_rep * 60 * 1000, 1);
	lt_part = {};
	lt_taken = {};
	lt_running = false;
end

addCommandHandler ("loto",
	function (player, cmd, num)
		if num then
			if not lt_running then return; end
			if not tonumber (num) then return; end
			if getPlayerMoney (player) < tick_pr then
				outputChatBox ("Paranız yetmiyor. "..tick_pr.."₺", player, 255, 0, 0);
				return;
			end
			if tonumber (num) < 1 or tonumber (num) > 30 then return; end
			if lt_part[player] then
				outputChatBox ("#FBC4FFZaten bir biletiniz var.", player, 255, 255, 255, true);
				return;
			end
			if lt_taken[num] then
				outputChatBox ("#FBC4FFBu numara başkası tarafından seçildi.", player, 255, 255, 255, true);
				return;
			end
			outputChatBox ("#FBC4FF[LOTO] "..num.." numaralı biletinizi aldınız. Bol şans!", player, 255, 255, 255, true);
			lt_part[player] = tonumber (num);
			lt_taken[num] = true;
			exports.database:takePlayerMoney (player, tick_pr, "Lottery ticket");
		end
	end
);
