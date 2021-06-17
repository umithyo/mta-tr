
--mp3 oynat

function greetingCommand ( playerSource, commandName, muzikisim )
	if muzikisim then 
    triggerClientEvent ( root, "cal", playerSource, muzikisim )
	--outputChatBox (muzikisim)
	else
	outputChatBox ("yazma kızım")
	end
end
addCommandHandler ( "oynat", greetingCommand, muzikisim )

--link oynat

function urlcal ( playerSource, commandName, url )
	if url then 
    triggerClientEvent ( root, "urlcall", playerSource, url )
	else
	outputChatBox ("nah fam")
	end
end
addCommandHandler ( "url", urlcal, url )

--muzik durdur

function durr ( playerSource, commandName )
    triggerClientEvent ( root, "dur", playerSource )
end
addCommandHandler ( "durdur", durr )

--ses ayarla

function sesdegis ( playerSource, commandName, volum )
    triggerClientEvent ( root, "sesayar", playerSource, volum )
end
addCommandHandler ( "ses", sesdegis, volum )

