local ADDON_PREFIX = 'FreshSoD'

local addonMessageFrame = CreateFrame('Frame')
addonMessageFrame:RegisterEvent('CHAT_MSG_ADDON')

addonMessageFrame:SetScript('OnEvent', function(_, event, ...)
  if event ~= 'CHAT_MSG_ADDON' then
    return
  end

  local prefix, message, channel, sender = ...
  if prefix ~= ADDON_PREFIX or channel ~= 'WHISPER' or not sender then
    return
  end

  if not FreshSoD_ParseGuildResetMessage(message) then
    return
  end

  if not IsInGuild() or not FreshSoD_IsPlayerInGuildRoster(sender) then
    return
  end

  if not FreshSoD_IsTopGuildRank(sender) then
    return
  end

  if type(BonniesUtilities_ResetNaughty) ~= 'function' then
    return
  end

  BonniesUtilities_ResetNaughty()

  if FreshSoD_BroadcastGuildVerificationStatusIfChanged then
    FreshSoD_BroadcastGuildVerificationStatusIfChanged()
  end

  if FreshSoD_RefreshGuildBoardTabIfVisible then
    FreshSoD_RefreshGuildBoardTabIfVisible()
  end
end)
