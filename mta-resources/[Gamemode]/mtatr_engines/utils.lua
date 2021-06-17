function table_find (tbl, index, value)
	for i, v in ipairs (tbl) do 
		if v[index] == value then 
			return i;
		end
	end
end	