local DEATH_TAX_GUILD = 'shockstate'

function FreshSoD_IsDeathTaxGuild()
  local guildName = FreshSoD_GetPlayerGuildName()
  if not guildName then
    return false
  end

  return string.lower(guildName) == DEATH_TAX_GUILD
end
