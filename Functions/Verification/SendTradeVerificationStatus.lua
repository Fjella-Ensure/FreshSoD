local ADDON_PREFIX = 'FreshSoD'

function FreshSoD_SendTradeVerificationStatus(isVerified)
  if not C_ChatInfo or not C_ChatInfo.SendAddonMessage then
    return
  end

  local message = isVerified and 'TV:1' or 'TV:0'
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, 'GUILD')
end
