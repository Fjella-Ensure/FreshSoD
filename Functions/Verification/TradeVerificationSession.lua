local VERIFICATION_TIMEOUT_SECONDS = 5

FreshSoD_TradeVerificationSession = nil
FreshSoD_tradeVerificationTimeout = nil

function FreshSoD_ClearTradeVerificationSession()
  if FreshSoD_tradeVerificationTimeout then
    FreshSoD_tradeVerificationTimeout:Cancel()
    FreshSoD_tradeVerificationTimeout = nil
  end
  FreshSoD_TradeVerificationSession = nil
end

function FreshSoD_EndTradeVerification()
  FreshSoD_HideTradeVerificationOverlay()
  FreshSoD_ClearTradeVerificationSession()
end

local function getSelfBlockedMessage()
  if not FreshSoD_AmIVerified() then
    return 'Trade blocked - you are not verified.'
  end

  if not FreshSoD_GetPlayerGuildName() then
    return 'Trade blocked - you are not in a guild.'
  end

  return 'Trade blocked - verification failed.'
end

local function getPartnerBlockedMessage(targetName, partnerVerified, partnerGuildName)
  if partnerVerified == false then
    return 'Trade with ' .. targetName .. ' blocked - partner not verified.'
  end

  if FreshSoD_IsPlayerInGuildRoster(targetName) then
    return 'Trade with ' .. targetName .. ' blocked - verification failed.'
  end

  if not partnerGuildName then
    return 'Trade with ' .. targetName .. ' blocked - partner is not in a guild.'
  end

  if not FreshSoD_IsWhitelistedGuild(partnerGuildName) then
    return 'Trade with ' .. targetName .. ' blocked - partner not in a whitelisted guild.'
  end

  return 'Trade with ' .. targetName .. ' blocked - verification failed.'
end

function FreshSoD_TryResolveTradeVerification(isTimeout)
  local session = FreshSoD_TradeVerificationSession
  if not session or session.resolved then
    return
  end

  if isTimeout and session.partnerVerified == nil then
    session.resolved = true
    local onComplete = session.onComplete
    local targetName = session.targetName
    FreshSoD_ClearTradeVerificationSession()
    onComplete(false, 'Trade with ' .. targetName .. ' blocked - verification timed out.')
    return
  end

  if session.partnerVerified == nil then
    return
  end

  session.resolved = true

  local partnerPasses = FreshSoD_PassesLiveTradeVerification(
    session.partnerVerified,
    session.partnerGuildName,
    session.targetName
  )
  local canTrade = FreshSoD_AmIEligibleForWhitelistedTrade() and partnerPasses
  local message
  if not canTrade then
    if not FreshSoD_AmIEligibleForWhitelistedTrade() then
      message = getSelfBlockedMessage()
    else
      message = getPartnerBlockedMessage(session.targetName, session.partnerVerified, session.partnerGuildName)
    end
  end

  local onComplete = session.onComplete

  FreshSoD_ClearTradeVerificationSession()

  if canTrade then
    FreshSoD_PrintRestrictionMessage('Verification passed, trading can continue')
    FreshSoD_HideTradeVerificationOverlay()
  end

  onComplete(canTrade, message)
end

function FreshSoD_BeginTradeVerification(playerName, onComplete)
  FreshSoD_ClearTradeVerificationSession()

  if not FreshSoD_AmIEligibleForWhitelistedTrade() then
    onComplete(false, getSelfBlockedMessage())
    return
  end

  FreshSoD_ShowTradeVerificationOverlay()

  FreshSoD_TradeVerificationSession = {
    targetName = playerName,
    onComplete = onComplete,
    partnerVerified = nil,
    partnerGuildName = nil,
    resolved = false,
  }

  local iAmVerified = FreshSoD_AmIVerified()
  FreshSoD_PrintRestrictionMessage(iAmVerified and 'I have passed verification' or 'I have failed verification')
  FreshSoD_SendTradeVerificationStatus(iAmVerified, playerName)

  if C_Timer and C_Timer.NewTimer then
    FreshSoD_tradeVerificationTimeout = C_Timer.NewTimer(VERIFICATION_TIMEOUT_SECONDS, function()
      FreshSoD_TryResolveTradeVerification(true)
    end)
  end
end

function FreshSoD_OnTradeVerificationMessageReceived(sender, isVerified, guildName)
  local partnerPasses = FreshSoD_PassesLiveTradeVerification(isVerified, guildName, sender)
  FreshSoD_CachePartnerVerification(sender, partnerPasses, guildName)

  if partnerPasses and guildName and FreshSoD_IsWhitelistedGuild(guildName) then
    FreshSoD_SetGuildMemberVerificationStatus(guildName, sender, true)
  elseif partnerPasses and FreshSoD_IsPlayerInGuildRoster(sender) then
    local myGuildName = FreshSoD_GetPlayerGuildName()
    if myGuildName then
      FreshSoD_SetGuildMemberVerificationStatus(myGuildName, sender, true)
    end
  end

  local session = FreshSoD_TradeVerificationSession
  if not session or session.resolved or not FreshSoD_PlayerNamesMatch(sender, session.targetName) then
    return
  end

  session.partnerVerified = isVerified
  session.partnerGuildName = guildName

  if partnerPasses then
    FreshSoD_PrintRestrictionMessage(session.targetName .. ' has passed verification')
  elseif isVerified ~= true then
    FreshSoD_PrintRestrictionMessage(session.targetName .. ' has failed verification')
  elseif FreshSoD_IsPlayerInGuildRoster(sender) then
    FreshSoD_PrintRestrictionMessage(session.targetName .. ' has failed verification')
  elseif not guildName then
    FreshSoD_PrintRestrictionMessage(session.targetName .. ' is not in a guild')
  else
    FreshSoD_PrintRestrictionMessage(session.targetName .. ' is not in a whitelisted guild')
  end

  FreshSoD_TryResolveTradeVerification()
end
