function FreshSoD_IsTopGuildRank(playerName)
  if not playerName or not IsInGuild() then
    return false
  end

  FreshSoD_RefreshGuildRoster()

  local targetName = Ambiguate(playerName, 'short')
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name, _, rankIndex = GetGuildRosterInfo(index)
    if name and Ambiguate(name, 'short') == targetName then
      return rankIndex == 0 or rankIndex == 1
    end
  end

  return false
end

function FreshSoD_AmITopGuildRank()
  local playerName = UnitName('player')
  if not playerName then
    return false
  end

  return FreshSoD_IsTopGuildRank(playerName)
end
