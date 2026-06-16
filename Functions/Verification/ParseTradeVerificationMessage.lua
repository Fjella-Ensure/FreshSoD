function FreshSoD_ParseTradeVerificationMessage(message)
  if not message then
    return nil
  end

  local status, guildName = message:match('^TV:(%d):G:(.+)$')
  if not status then
    status = message:match('^TV:(%d)$')
    guildName = nil
  end

  if status == '1' then
    return true, guildName
  end
  if status == '0' then
    return false, guildName
  end

  return nil
end
