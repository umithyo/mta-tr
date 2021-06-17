do 
	for i, v in pairs (anims) do 
		addCommandHandler (i, 
			function (player) 
				player:setAnimation(v[1], v[2], true, false);
			end
		);
	end
end	