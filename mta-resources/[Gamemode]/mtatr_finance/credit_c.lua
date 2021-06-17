local dates = {2, 4, 6, 8, 10, 12};

addEventHandler ("onClientResourceStart", resourceRoot, 
	function ()
		triggerServerEvent ("credit.load", localPlayer);
		for i, v in ipairs (dates) do 
			guiComboBoxAddItem (fn.combobox[1], tostring (v).." HAFTA");
		end	
	end
);

addEvent ("credit.request", true);
addEventHandler ("credit.request", root,
	function (tbl)
		if tbl then 
			loadGrid(tbl);
		end	
	end
);	

function loadGrid (data)
	local g = fn.gridlist[1];
	local selected = guiGridListGetSelectedItem (g);
	guiGridListClear (g);
	if data and next (data) then 
		for i, v in ipairs (data) do 
			local row = guiGridListAddRow (g);
			local time = exports.mtatr_utils:todate (v.id);
			local first = v.first_installment or "N/A";
			local explanation = first.. " HAFTA VADELİ KREDİ";
			local deadline = exports.mtatr_utils:todate (v.date);
			local debt = v.debt;
			local min = v.min;
			local adjustment = ((getRealTime().timestamp) / ((v.date or 0)  / 100)) * 2.55
			local r, g_, b =  tonumber ((math.floor (255-adjustment))), tonumber (math.floor (adjustment)), 0;
			for k, j in ipairs ({explanation, deadline, debt, min}) do 
				guiGridListSetItemText (g, row, k, j, false, false);
				guiGridListSetItemColor (g, row, k, r, g_, b);
			end
			guiGridListSetItemData (g, row, 1, v.id);
		end
	end
end

addEventHandler ("onClientGUIChanged", fn.edit[3], 
	function ()	
		local text = guiGetText (source);
		if #text > 0 then 
			guiSetText (source, text:match("%d+") or "");
		end	
	end,
false);		

for i = 2, 4 do 
	local button = fn.button[i];
	addEventHandler ("onClientGUIClick", button, 
		function ()
			if source == fn.button[2] then 
				local amount = tonumber (guiGetText (fn.edit[3])); 
				local item = guiComboBoxGetSelected (fn.combobox[1]);
				local text = guiComboBoxGetItemText (fn.combobox[1], item);
				local installment = text:match("%d+");
				if not amount then return; end
				ts("credit.apply", amount, tonumber (installment));
			elseif source == fn.button[3] then 
				local g = fn.gridlist[1];
				local id = gd (g);
				ts("credit.pay", "paywhole", id);
			elseif source == fn.button[4] then 
				local g = fn.gridlist[1];
				local id = gd (g);
				ts("credit.pay", "payinstall", id);
			end
		end,
	false);
end	