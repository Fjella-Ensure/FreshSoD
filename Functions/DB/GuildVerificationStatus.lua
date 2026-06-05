function FreshSoD_EnsureGuildVerificationDB()
  if not FRESH_SOD_DB then
    FRESH_SOD_DB = {}
  end

  if not FRESH_SOD_DB.guildVerificationStatus then
    FRESH_SOD_DB.guildVerificationStatus = {}
  end
end

local function normalizeGuildPlayerName(playerName)
  if not playerName then
    return nil
  end

  return string.lower(Ambiguate(playerName, 'short'))
end

function FreshSoD_GetPlayerGuildName()
  if not IsInGuild() then
    return nil
  end

  return GetGuildInfo('player')
end

function FreshSoD_GetGuildMemberVerificationStatus(guildName, playerName)
  FreshSoD_EnsureGuildVerificationDB()

  if not guildName or not playerName then
    return nil
  end

  local guildData = FRESH_SOD_DB.guildVerificationStatus[guildName]
  if not guildData then
    return nil
  end

  local shortName = normalizeGuildPlayerName(playerName)
  if not shortName then
    return nil
  end

  for storedName, status in pairs(guildData) do
    if normalizeGuildPlayerName(storedName) == shortName then
      return status
    end
  end

  return nil
end

function FreshSoD_SetGuildMemberVerificationStatus(guildName, playerName, isVerified)
  FreshSoD_EnsureGuildVerificationDB()

  if not guildName or not playerName then
    return false
  end

  local shortName = normalizeGuildPlayerName(playerName)
  if not shortName then
    return false
  end

  local guildData = FRESH_SOD_DB.guildVerificationStatus[guildName]

  if guildData then
    for storedName, status in pairs(guildData) do
      if normalizeGuildPlayerName(storedName) == shortName then
        if status == isVerified then
          return false
        end
        guildData[storedName] = nil
        break
      end
    end
  else
    FRESH_SOD_DB.guildVerificationStatus[guildName] = {}
    guildData = FRESH_SOD_DB.guildVerificationStatus[guildName]
  end

  guildData[shortName] = isVerified
  return true
end
