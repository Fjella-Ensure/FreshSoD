function FreshSoD_IsPlayerInGuildRoster(playerName)
    FreshSoD_RefreshGuildRoster()

  if not playerName or not IsInGuild() then
    return false
  end

  local targetName = string.lower(Ambiguate(playerName, 'short'))
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name = GetGuildRosterInfo(index)
    if name and string.lower(Ambiguate(name, 'short')) == targetName then
      return true
    end
  end

  return false
end
