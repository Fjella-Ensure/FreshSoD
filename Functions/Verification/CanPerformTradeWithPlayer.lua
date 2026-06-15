local guildTradeVerificationPassed = false

function FreshSoD_ResetGuildTradeVerification()
  guildTradeVerificationPassed = false
end

function FreshSoD_UpdateGuildTradeVerification()
  if not BonniesUtilities_IsTradePartnerInMyGuild() then
    FreshSoD_EndTradeVerification()
    return
  end

  if type(BonniesUtilities_TradeRequiresGuildVerification) ~= 'function' then
    return
  end

  if not BonniesUtilities_TradeRequiresGuildVerification() then
    guildTradeVerificationPassed = false
    FreshSoD_EndTradeVerification()
    return
  end

  if guildTradeVerificationPassed then
    FreshSoD_HideTradeVerificationOverlay()
    return
  end

  local session = FreshSoD_TradeVerificationSession
  if session and not session.resolved then
    return
  end

  local partnerName = GetUnitName('npc', true)
  if not partnerName then
    return
  end

  FreshSoD_PrintRestrictionMessage(partnerName .. ' is in my Guild.' .. ' Starting verification...')

  FreshSoD_BeginTradeVerification(partnerName, function(canTrade, message)
    if canTrade then
      guildTradeVerificationPassed = true
      FreshSoD_HideTradeVerificationOverlay()
    else
      FreshSoD_ClearPartnerVerificationCache(partnerName)
      FreshSoD_CancelTradeWithMessage(message)
    end
  end)
end
