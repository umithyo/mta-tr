addEvent ("onPlayerRequestClanCreation", true);
addEventHandler ("onPlayerRequestClanCreation", root,
	function (name, tag, color)
		createGroup (name, tag, color, client);
	end
);	