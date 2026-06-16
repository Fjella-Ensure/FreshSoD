local function isLocalPlayer(playerName)
  if not playerName then
    return false
  end

  return Ambiguate(playerName, 'short') == Ambiguate(UnitName('player'), 'short')
end

local function isStoredInWhitelistedGuild(playerName)
  FreshSoD_EnsureLocalCharacterVerificationDB()

  local theirGuild = GetGuildInfo(playerName)

  local shortName = string.lower(Ambiguate(playerName, 'short'))
  local entry = FRESH_SOD_DB.localCharacterVerification[shortName]
  if entry and entry.guildName and FreshSoD_IsWhitelistedGuild(entry.guildName) then
    return true
  end

  FreshSoD_EnsureGuildVerificationDB()

  for guildName in pairs(FRESH_SOD_DB.guildVerificationStatus) do
    if FreshSoD_IsWhitelistedGuild(guildName)
      and FreshSoD_GetGuildMemberVerificationStatus(guildName, playerName) ~= nil then
      return true
    end
  end

  return false
end

function FreshSoD_IsPlayerInMyGuildOrWhitelistedGuild(playerName, guildName)
  if not playerName then
    return false
  end

  if isLocalPlayer(playerName) then
    return FreshSoD_GetPlayerGuildName() ~= nil
  end

  if FreshSoD_IsPlayerInGuildRoster(playerName) then
    return true
  end

  if guildName and guildName ~= '' and FreshSoD_IsWhitelistedGuild(guildName) then
    return true
  end

  return isStoredInWhitelistedGuild(playerName)
end
