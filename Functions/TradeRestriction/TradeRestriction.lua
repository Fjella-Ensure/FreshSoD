local frame = CreateFrame('Frame')
local nonGuildTradeCheckScheduled = false

local TRADE_CONTENT_EVENTS = {
  'TRADE_SHOW',
  'TRADE_UPDATE',
  'TRADE_ACCEPT_UPDATE',
  'TRADE_MONEY_CHANGED',
  'PLAYER_TRADE_MONEY',
  'TRADE_PLAYER_ITEM_CHANGED',
  'TRADE_TARGET_ITEM_CHANGED',
}

for _, tradeEvent in ipairs(TRADE_CONTENT_EVENTS) do
  frame:RegisterEvent(tradeEvent)
end

frame:RegisterEvent('TRADE_CLOSED')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')

local function cancelNonGuildTrade()
  local partnerName = GetUnitName('npc', true)
  local hasMoney = type(BonniesUtilities_TradeHasMoney) == 'function'
    and BonniesUtilities_TradeHasMoney()
  local message = hasMoney
    and 'Trade blocked - no gold allowed with non-guild members.'
    or 'Trade blocked - only whitelisted items allowed with non-guild members.'
  if partnerName then
    message = hasMoney
      and ('Trade with ' .. partnerName .. ' blocked - no gold allowed.')
      or ('Trade with ' .. partnerName .. ' blocked - only whitelisted items allowed.')
  end
  FreshSoD_CancelTradeWithMessage(message)
end

local function runNonGuildTradeCheck()
  nonGuildTradeCheckScheduled = false
  if type(BonniesUtilities_TradeViolatesNonGuildRestrictions) ~= 'function' then
    return
  end
  if BonniesUtilities_TradeViolatesNonGuildRestrictions() then
    cancelNonGuildTrade()
  end
end

local function scheduleNonGuildTradeCheck()
  if nonGuildTradeCheckScheduled then
    return
  end
  nonGuildTradeCheckScheduled = true

  if C_Timer and C_Timer.After then
    C_Timer.After(0, runNonGuildTradeCheck)
  else
    runNonGuildTradeCheck()
  end
end

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'TRADE_SHOW' then
    local targetName = GetUnitName('npc', true)
    if not targetName then
      return
    end

    FreshSoD_CanPerformTradeWithPlayer(targetName, function(canTrade, message)
      if not canTrade then
        FreshSoD_CancelTradeWithMessage(message)
      end
    end)

    scheduleNonGuildTradeCheck()
  elseif event == 'TRADE_UPDATE'
    or event == 'TRADE_ACCEPT_UPDATE'
    or event == 'TRADE_MONEY_CHANGED'
    or event == 'PLAYER_TRADE_MONEY'
    or event == 'TRADE_PLAYER_ITEM_CHANGED'
    or event == 'TRADE_TARGET_ITEM_CHANGED' then
    scheduleNonGuildTradeCheck()
  elseif event == 'TRADE_CLOSED' then
    nonGuildTradeCheckScheduled = false
    FreshSoD_EndTradeVerification()
  elseif event == 'AUCTION_HOUSE_SHOW' then
    FreshSoD_CancelAuctionHouseWithMessage('Auction House blocked')
  end
end)
