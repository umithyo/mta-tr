local acl = {
	Kurucu = {
		true,
		true,
		true,
		true,
		true,
		true,
		true,
		false,
		true,
		true,
	},
	Lider = {
		false,
		true,
		true,
		false,
		false,
		false,
		true,
		true,
		false,
	},
	["Yrd. Lider"] = {
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		true,
		false,
	},
	["Kıdemli"] = {
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		true,
		false,
	},
	["Üye"] = {
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		true,
		false,
	}, 
};

function aclSetGui (rank)
	for i, v in ipairs (gr.button) do 
		if acl[rank] then 
			v:setEnabled(acl[rank][i] or false);
		end	
	end
end	