function FreshSoD_ParseDeathTaxAddonMessage(message)
  if not message then
    return nil, nil
  end

  local taxCopper, playerName = message:match('^DT:(%d+):(.+)$')
  if not taxCopper or not playerName or playerName == '' then
    return nil, nil
  end

  return playerName, tonumber(taxCopper)
end
