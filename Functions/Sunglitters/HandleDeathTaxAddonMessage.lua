local ADDON_PREFIX = 'FreshSoD'

local function normalizePlayerName(playerName)
  if not playerName then
    return nil
  end

  return string.lower(Ambiguate(playerName, 'short'))
end

local addonMessageFrame = CreateFrame('Frame')
addonMessageFrame:RegisterEvent('CHAT_MSG_ADDON')

addonMessageFrame:SetScript('OnEvent', function(_, event, ...)
  if event ~= 'CHAT_MSG_ADDON' then
    return
  end

  local prefix, message, channel, sender = ...
  if prefix ~= ADDON_PREFIX or channel ~= 'GUILD' or not sender then
    return
  end

  local playerName, taxCopper = FreshSoD_ParseDeathTaxAddonMessage(message)
  if not playerName or not taxCopper then
    return
  end

  if not FreshSoD_IsDeathTaxGuild() then
    return
  end

  if not FreshSoD_IsPlayerInGuildRoster(sender) then
    return
  end

  if normalizePlayerName(sender) ~= normalizePlayerName(playerName) then
    return
  end

  FreshSoD_ShowDeathTaxAnnouncement(playerName, taxCopper)
end)
