addEvent ("housing.createhouse", true);
addEvent ("onHouseCreated");

function canPlayerCreateHouse (player)
	return exports.mtatr_accounts:isPlayerInStaff(player);
end

addCommandHandler ("house",
	function (player)
		if canPlayerCreateHouse (player) then
			triggerClientEvent (player, "housing.creationmenu", player);
		end
	end
);

addEventHandler ("housing.createhouse", root,
	function (...)
		local int, price, spawnx, spawny, spawnz, exitx, exity, exitz, pickupx, pickupy, pickupz, markerx, markery, markerz, rotation, dim = unpack (arg);
		local id = getNextSlot ();
		local dim_ =  id + 49999;
		if tonumber (dim) then
			dim_ = dim;
		end
		local loc = {
			int = int,
			spawn = {spawnx, spawny, spawnz + 1},
			exit = {exitx, exity, exitz + 1},
			marker = {markerx, markery, markerz},
			pickup = {pickupx, pickupy, pickupz},
			rotation = rotation,
			dim = dim_,
		};
		setHouseData (id, "location", toJSON (loc));
		setHouseData (id, "sale_price", price);
		setHouseData (id, "for_sale", "true");
		setHouseData (id, "creation_time", getRealTime().timestamp);
		setHouseData (id, "saved_by", exports.database:getPlayerId (client));
		for i, v in ipairs (getElementsByType"player") do
			triggerClientEvent (v, "housingsync.addhouse", v, id, houses[id]);
		end
		triggerClientEvent (client, "housing.closemenu", client);
	end
);
