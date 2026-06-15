function FreshSoD_GetNonGuildMailIndices()
  FreshSoD_RefreshGuildRoster()

  local indices = {}
  local numItems = GetInboxNumItems()

  for inboxIndex = numItems, 1, -1 do
    local _, _, sender, _, _, _, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(inboxIndex)
    if sender and not isGM and not FreshSoD_IsPlayerInGuildRoster(sender) then
      indices[#indices + 1] = inboxIndex
    end
  end

  return indices
end

function FreshSoD_HasNonGuildMail()
  return #FreshSoD_GetNonGuildMailIndices() > 0
end
