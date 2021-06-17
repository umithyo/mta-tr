local words = {};
local dir = "anti_curse/words.txt";

addEventHandler ("onResourceStart", resourceRoot,
	function ()
		local file = fileExists (dir) and fileOpen (dir);
		if file then
			local buffer = fileRead (file, fileGetSize (file));
			for i, v in ipairs (split (buffer, "\n\r")) do
				table.insert (words, v);
			end
			fileClose (file);
		end
	end
);

function hasPlayerCursed (msg)
    return false;
end
-- 	local sentence = 0;
-- 	for i, v in ipairs (words) do
-- 		while msg:find(v) do
-- 			sentence = sentence + 5;
-- 			break
-- 		end
-- 	end
-- 	return sentence > 0 and sentence;
-- end
