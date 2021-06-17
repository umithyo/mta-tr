function playH (muzikisim) 
	if muzik then
	stopSound (muzik)
	muzik = playSound("sounds/".. muzikisim ..".mp3")
	else
	muzik = playSound("sounds/".. muzikisim ..".mp3") 
	end
end

addEvent( "cal", true )
addEventHandler( "cal", root, playH )

function playUrl (url) 
	if muzik then
	stopSound (muzik)
	muzik = playSound(url)
	else
	muzik = playSound(url)
	--outputChatBox(url)
	end
end

addEvent( "urlcall", true )
addEventHandler( "urlcall", root, playUrl )







function stopH () 
	stopSound(muzik) --Play wasted.mp3 from the sounds folder
end
addEvent( "dur", true )
addEventHandler( "dur", root, stopH )

function sess (volum) 
	local seviye = tonumber (volum * 1)
	--local seviyeyazi = toString (seviye)
	if seviye then
		setSoundVolume(muzik, seviye) -- set the sound volume to 50%
		outputChatBox("ses " .. seviye .. " olarak ayarlandi.")
	else
	end
end

addEvent( "sesayar", true )
addEventHandler( "sesayar", root, sess )