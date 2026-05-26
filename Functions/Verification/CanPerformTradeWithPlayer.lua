function FreshSoD_CanPerformTradeWithPlayer(playerName, onComplete)
  if not playerName or not onComplete then
    return
  end

  if not FreshSoD_IsTradePartnerInMyGuild() then
    onComplete(false, 'Trade with ' .. playerName .. ' blocked - not in my Guild.')
    return
  end

  FreshSoD_PrintRestrictionMessage(playerName .. ' is in my Guild.' .. ' Starting verification...')

  FreshSoD_BeginTradeVerification(playerName, onComplete)
end
