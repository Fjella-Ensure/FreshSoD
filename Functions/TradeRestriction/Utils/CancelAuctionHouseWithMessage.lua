function FreshSoD_CancelAuctionHouseWithMessage(message)
    if message then SendChatMessage('[FreshSoD] ' .. message, 'EMOTE') end
    
    if C_Timer and C_Timer.After then
        C_Timer.After(0.1, function()
            if CloseAuctionHouse then
                CloseAuctionHouse()
            end
        end)
    end
end