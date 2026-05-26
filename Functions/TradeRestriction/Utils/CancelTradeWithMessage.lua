function FreshSoD_CancelTradeWithMessage(message)
    if message then FreshSoD_PrintRestrictionMessage(message) end
    CancelTrade()
end