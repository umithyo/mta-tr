function output (...)
	local args = {...}
	local element = args[3];
	table.remove (args, 3);
	triggerClientEvent (element, "engines.output", element, unpack (args));
end	

function playFX (fx, elem)
	local element = elem or root;
	triggerClientEvent (element, "engines.playfx", element, fx);
end	