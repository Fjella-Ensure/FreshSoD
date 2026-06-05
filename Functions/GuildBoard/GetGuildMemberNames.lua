function FreshSoD_GetGuildMemberNames()
  FreshSoD_RefreshGuildRoster()

  if not IsInGuild() then
    return {}
  end

  local members = {}
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name = GetGuildRosterInfo(index)
    if name then
      members[#members + 1] = Ambiguate(name, 'short')
    end
  end

  table.sort(members)
  return members
end
