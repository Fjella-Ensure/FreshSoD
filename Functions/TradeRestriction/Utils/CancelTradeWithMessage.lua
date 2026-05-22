function FreshSoD_CancelTradeWithMessage(message)
    if message then SendChatMessage('[FreshSoD] ' .. message, 'EMOTE') end
    CancelTrade()
end