function FreshSoD_CanPerformTradeWithPlayer(playerName, onComplete)
  if not playerName or not onComplete then
    return
  end

  if not BonniesUtilities_IsTradePartnerInMyGuild() then
    onComplete(true)
    return
  end

  FreshSoD_PrintRestrictionMessage(playerName .. ' is in my Guild.' .. ' Starting verification...')

  FreshSoD_BeginTradeVerification(playerName, onComplete)
end
