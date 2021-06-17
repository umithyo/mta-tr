function output (...)
	local args = {...}
	local element = args[3];
	table.remove (args, 3);
	triggerClientEvent (element, "civ.output", element, unpack (args));
end	