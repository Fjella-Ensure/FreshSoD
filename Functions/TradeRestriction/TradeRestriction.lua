local frame = CreateFrame('Frame')
frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('TRADE_CLOSED')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')
frame:RegisterEvent('MAIL_INBOX_UPDATE')

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'MAIL_INBOX_UPDATE' then
    for inboxIndex = GetInboxNumItems(), 1, -1 do
      local _, _, sender, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(i)
      if sender and not isGM then
        if not FreshSoD_IsPlayerInGuildRoster(sender) then
          FreshSoD_CancelMailWithMessage(inboxIndex, 'Mail from ' .. sender .. ' blocked - not on my Guild.')
        end
      end
    end
  elseif event == 'TRADE_SHOW' then
    local targetName = GetUnitName('npc', true)
    if not targetName then
      return
    end

    FreshSoD_CanPerformTradeWithPlayer(targetName, function(canTrade, message)
      if not canTrade then
        FreshSoD_CancelTradeWithMessage(message)
      end
    end)
  elseif event == 'TRADE_CLOSED' then
    FreshSoD_EndTradeVerification()
  elseif event == 'AUCTION_HOUSE_SHOW' then
    FreshSoD_CancelAuctionHouseWithMessage('Auction House blocked')
  end
end)
