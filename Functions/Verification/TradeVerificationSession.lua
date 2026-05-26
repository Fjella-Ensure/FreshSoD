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

local function getTradeBlockedMessage(session)
  if not FreshSoD_AmIVerified() then
    return 'Trade blocked - you are not verified.'
  end
  if session.partnerVerified == false then
    return 'Trade with ' .. session.targetName .. ' blocked - partner not verified.'
  end
  return 'Trade with ' .. session.targetName .. ' blocked - verification failed.'
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

  local canTrade = FreshSoD_AmIVerified() and session.partnerVerified
  local message = canTrade and nil or getTradeBlockedMessage(session)
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
  FreshSoD_ShowTradeVerificationOverlay()

  FreshSoD_TradeVerificationSession = {
    targetName = playerName,
    onComplete = onComplete,
    partnerVerified = nil,
    resolved = false,
  }

  local iAmVerified = FreshSoD_AmIVerified()
  FreshSoD_PrintRestrictionMessage(iAmVerified and 'I have passed verification' or 'I have failed verification')
  FreshSoD_SendTradeVerificationStatus(iAmVerified, playerName)

  local cached = FreshSoD_GetCachedPartnerVerification(playerName)
  if cached ~= nil then
    FreshSoD_PrintRestrictionMessage(playerName .. ' has ' .. (cached and 'passed' or 'failed') .. ' verification')
    FreshSoD_TradeVerificationSession.partnerVerified = cached
    FreshSoD_TryResolveTradeVerification()
  end

  if C_Timer and C_Timer.NewTimer then
    FreshSoD_tradeVerificationTimeout = C_Timer.NewTimer(VERIFICATION_TIMEOUT_SECONDS, function()
      FreshSoD_TryResolveTradeVerification(true)
    end)
  end
end

function FreshSoD_OnTradeVerificationMessageReceived(sender, isVerified)
  FreshSoD_CachePartnerVerification(sender, isVerified)

  local session = FreshSoD_TradeVerificationSession
  if not session or session.resolved or not FreshSoD_PlayerNamesMatch(sender, session.targetName) then
    return
  end

  session.partnerVerified = isVerified
  FreshSoD_PrintRestrictionMessage(session.targetName .. ' has ' .. (isVerified and 'passed' or 'failed') .. ' verification')
  FreshSoD_TryResolveTradeVerification()
end
