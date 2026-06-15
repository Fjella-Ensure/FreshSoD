local ADDON_PREFIX = 'FreshSoD'

function FreshSoD_SendGuildResetRequest(playerName)
  if not playerName or playerName == '' then
    return false
  end

  if not FreshSoD_AmITopGuildRank() then
    return false
  end

  if not FreshSoD_IsPlayerInGuildRoster(playerName) then
    return false
  end

  if not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
    return false
  end

  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, 'GR:1', 'WHISPER', playerName)
  return true
end
