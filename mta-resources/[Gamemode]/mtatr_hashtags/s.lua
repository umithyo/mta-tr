local hashtags = {}
local db = dbConnect ("sqlite", "hashtags.db")
dbExec (db, "CREATE TABLE IF NOT EXISTS hashtags (word TEXT)")
addEventHandler ("onResourceStop", resourceRoot, 
	function ()
		local qh = dbQuery (db, "SELECT * FROM hashtags")
		local result = dbPoll (qh, -1)
		if #result == 0 then 
			dbExec (db, "INSERT INTO hashtags (word) VALUES (?)", toJSON (hashtags))
		else
			dbExec (db, "UPDATE hashtags SET word = ?", toJSON (hashtags))
		end	
	end
)	

addCommandHandler ("clearhashtags", 
	function (p)
		if exports.mtatr_accounts:isPlayerInStaff (p) then 
			hashtags = {}
			outputChatBox ("Hashtagler temizlendi.", p, 0, 255, 0)
		end
	end
)	

function getHashtagsOnStart () 
	hashtags = fromJSON (dbPoll (dbQuery(db, "SELECT * FROM hashtags"), -1)[1].word) or {}
end	
addEventHandler ("onResourceStart", resourceRoot, getHashtagsOnStart)

addEventHandler ("onPlayerChat", root, 
	function (msg, msgtype)
		if msgtype == 0 then 
			if string.find (tostring(msg:lower()), "#") and #msg > 1 then 
				local newmsg = "#";
				for word in string.gmatch (msg, "[a-zA-Z0-9_.-]") do 
					newmsg = newmsg..word;
				end	
				if #newmsg > 1 then 
					if not isMessageOnTable(newmsg:lower()) then 
						table.insert (hashtags, {newmsg, 1})
					else
						hashtags[getMessageIndex(newmsg)][2] = hashtags[getMessageIndex(newmsg)][2] + 1
					end	
					triggerClientEvent (root, "hashtags.getHashtags", resourceRoot, hashtags)
				end	
			end	
		end
	end
)

function getMessageIndex (msg)
	for i, v in ipairs (hashtags) do 
		if v[1]:lower() == msg:lower() then 
			return i
		end
	end
	return false
end	

function isMessageOnTable (msg)
	for i, v in ipairs (hashtags) do 
		if v[1]:lower() == msg:lower() then 
			return true
		end
	end
	return false
end	

addCommandHandler ("tt", 
	function (p)
		table.sort (hashtags, function (a, b) return tonumber(a[2]) > tonumber(b[2]) end)
		triggerClientEvent (p, "hashtags.getHashtags", p, hashtags, true)
	end	
)