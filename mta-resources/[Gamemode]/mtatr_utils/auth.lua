function isPlayerInACL ( player, acl )
	local account = getPlayerAccount ( player )
	if ( isGuestAccount ( account ) ) then
		return false
	end
	return isObjectInACLGroup ( "user."..getAccountName ( account ), aclGetGroup ( acl ) )
end

function isPlayerAdmin (player)
	return isPlayerInACL (player, "Admin")
end

local acl = {
	"Admin",
	"SuperModerator",
	"Moderator",
};
function isPlayerStaff (player)
	for i, v in ipairs (acl) do 
		if isPlayerInACL (player, v) then 
			return true;
		end	
	end	
	return false;
end

function getPlayerAdminLevel (player)
	if isPlayerInStaff (player) then 
		for i, v in ipairs (acl) do 
			if isPlayerInACL (player, v) then 
				return v;
			end
		end
	end
	return false;
end	