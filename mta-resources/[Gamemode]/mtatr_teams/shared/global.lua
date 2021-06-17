SERVER = triggerClientEvent or false;
if SERVER then 
	TEAM = exports.mtatr_main:getTeamsType() == "scoreboard"; 
	COLOR = {200, 100, 100};
	TEAM_DATA = "Grup";
	MIN_CHAR = 3;
else	
	HOTKEY = "F6";
end	