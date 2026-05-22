function FreshSoD_CancelMailWithMessage(inboxIndex, message)
    if not inboxIndex then return end
    
    if message then SendChatMessage('[FreshSoD] ' .. message, 'EMOTE') end
    ReturnInboxItem(inboxIndex)
end