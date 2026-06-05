local ADDON_PREFIX = 'FreshSoD'

function FreshSoD_SendGuildVerificationStatus(isVerified)
  print('SendGuildVerificationStatus', isVerified)
  if not IsInGuild() then
    return
  end

  local message = isVerified and 'GV:1' or 'GV:0'
  print('hello')
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, 'GUILD')
end
