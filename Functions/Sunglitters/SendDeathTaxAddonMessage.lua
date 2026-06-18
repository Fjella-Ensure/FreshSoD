local ADDON_PREFIX = 'FreshSoD'

function FreshSoD_SendDeathTaxAddonMessage(playerName, taxCopper)
  if not IsInGuild() or not FreshSoD_IsDeathTaxGuild() then
    return
  end

  local message = 'DT:' .. taxCopper .. ':' .. playerName
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, 'GUILD')
end
