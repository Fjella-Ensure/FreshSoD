local WHITELISTED_GUILDS = {
  'shockstate',
  'otherguild',
}

local function normalizeGuildName(guildName)
  if not guildName then
    return nil
  end

  return string.lower(guildName)
end

function FreshSoD_IsWhitelistedGuild(guildName)
  if not guildName then
    return false
  end

  local normalizedGuildName = normalizeGuildName(guildName)
  for _, whitelistedGuild in ipairs(WHITELISTED_GUILDS) do
    if normalizeGuildName(whitelistedGuild) == normalizedGuildName then
      return true
    end
  end

  return false
end
