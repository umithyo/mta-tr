function toggleGodMode(thePlayer)
    local account = getPlayerAccount(thePlayer)
    if (not account or isGuestAccount(account)) then return end

    local accountName = getAccountName(account)
    if (isObjectInACLGroup("user."..accountName, aclGetGroup("Admin"))) then
        if getElementData(thePlayer, "invincible") then
            setElementData(thePlayer, "invincible", false)
            outputChatBox("#fffffffuckoff mode #FF0000off.", thePlayer, 255,255,255, true)
        else
            setElementData(thePlayer,"invincible",true)
            outputChatBox("#fffffffuckoff mode#008000 on.", thePlayer, 255,255,255, true)
        end
    end
end
addCommandHandler("god", toggleGodMode)

function dealDmg(target, damage)
    if not getElementData(target, "invincible") then
        local can = getElementHealth(target)
        setElementHealth(target, can - damage)
    end
end
addEvent("dealDamageToAttacker", true)
addEventHandler("dealDamageToAttacker", root, dealDmg)