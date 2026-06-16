local function isLocalPlayer(playerName)
  if not playerName then
    return false
  end

  return Ambiguate(playerName, 'short') == Ambiguate(UnitName('player'), 'short')
end

local function getStoredValidationStatus(guildName, playerName)
  local status = FreshSoD_GetGuildMemberVerificationStatus(guildName, playerName)
  if status == nil then
    status = FreshSoD_GetLocalCharacterVerificationStatus(playerName, guildName)
  end

  return status
end

local function isValidatedInGuild(guildName, playerName, requireWhitelistedGuild)
  if not guildName then
    return false
  end

  if requireWhitelistedGuild and not FreshSoD_IsWhitelistedGuild(guildName) then
    return false
  end

  if isLocalPlayer(playerName) then
    return FreshSoD_AmIVerified()
  end

  return getStoredValidationStatus(guildName, playerName) == true
end

function FreshSoD_PassesLiveTradeVerification(isVerified, guildName, playerName)
  if isVerified ~= true then
    return false
  end

  if playerName and FreshSoD_IsPlayerInGuildRoster(playerName) then
    return true
  end

  return guildName ~= nil
    and guildName ~= ''
    and FreshSoD_IsWhitelistedGuild(guildName)
end

function FreshSoD_AmIEligibleForWhitelistedTrade()
  if not FreshSoD_AmIVerified() then
    return false
  end

  return FreshSoD_GetPlayerGuildName() ~= nil
end

function FreshSoD_IsPlayerValidatedInWhitelistedGuild(playerName)
  if not playerName then
    return false
  end

  if isLocalPlayer(playerName) then
    return isValidatedInGuild(FreshSoD_GetPlayerGuildName(), playerName, false)
  end

  if FreshSoD_IsPlayerInGuildRoster(playerName) then
    return isValidatedInGuild(FreshSoD_GetPlayerGuildName(), playerName, false)
  end

  FreshSoD_EnsureGuildVerificationDB()

  for guildName in pairs(FRESH_SOD_DB.guildVerificationStatus) do
    if isValidatedInGuild(guildName, playerName, true) then
      return true
    end
  end

  FreshSoD_EnsureLocalCharacterVerificationDB()

  local shortName = string.lower(Ambiguate(playerName, 'short'))
  local entry = FRESH_SOD_DB.localCharacterVerification[shortName]
  if entry and entry.isVerified and FreshSoD_IsWhitelistedGuild(entry.guildName) then
    return true
  end

  return false
end
