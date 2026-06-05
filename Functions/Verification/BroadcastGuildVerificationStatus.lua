local lastBroadcastStatus = nil

function FreshSoD_BroadcastGuildVerificationStatusIfChanged()
  if not IsInGuild() then
    lastBroadcastStatus = nil
    return
  end

  if FreshSoD_UpdateBuffVerification then
    FreshSoD_UpdateBuffVerification()
  end

  local isVerified = FreshSoD_AmIVerified()
  if lastBroadcastStatus == isVerified then
    return
  end

  FreshSoD_SendGuildVerificationStatus(isVerified)
  lastBroadcastStatus = isVerified

  local guildName = FreshSoD_GetPlayerGuildName()
  if guildName then
    FreshSoD_SetGuildMemberVerificationStatus(guildName, UnitName('player'), isVerified)
  end

  if FreshSoD_RefreshGuildBoardTabIfVisible then
    FreshSoD_RefreshGuildBoardTabIfVisible()
  end
end

local broadcastFrame = CreateFrame('Frame')
broadcastFrame:RegisterEvent('PLAYER_LOGIN')
broadcastFrame:RegisterEvent('PLAYER_GUILD_UPDATE')

broadcastFrame:SetScript('OnEvent', function(_, event)
  if event == 'PLAYER_LOGIN' then
    if C_Timer and C_Timer.After then
      C_Timer.After(2, FreshSoD_BroadcastGuildVerificationStatusIfChanged)
    else
      FreshSoD_BroadcastGuildVerificationStatusIfChanged()
    end
    return
  end

  FreshSoD_BroadcastGuildVerificationStatusIfChanged()
end)
