function gt (g, column)
	if g then 
		local item = guiGridListGetSelectedItem (g);
		if item == -1 then 
			return false;
		end
		return guiGridListGetItemText (g, item, column or 1);
	end	
	return false;
end

function gd (g, column)
	if g then 
		local item = guiGridListGetSelectedItem (g);
		if item == -1 then 
			return false;
		end
		return guiGridListGetItemData (g, item, column or 1);
	end	
	return false;
end	

function tr (name, ...) return triggerServerEvent ("duel."..name, localPlayer, ...); end

function findMap(tbl, text)
	for i, v in ipairs (tbl) do 
		if v.name==text then 
			return i;
		end
	end
	return false;
end	