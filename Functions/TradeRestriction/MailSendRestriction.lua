local sendGuardInstalled = false
local canSendHookInstalled = false

local function getRecipient()
  if SendMailNameEditBox then
    return SendMailNameEditBox:GetText()
  end
  return nil
end

local function updateSendMailButtonState()
  if type(SendMailFrame_CanSend) == 'function' then
    SendMailFrame_CanSend()
    return
  end

  if not SendMailMailButton or not SendMailMailButton:IsEnabled() then
    return
  end

  local recipient = getRecipient()
  if not recipient or recipient == '' then
    return
  end

  local allowed = FreshSoD_CanSendMailToRecipient(recipient)
  if not allowed then
    SendMailMailButton:Disable()
  end
end

local function blockInvalidSend(recipient)
  local allowed, reason = FreshSoD_CanSendMailToRecipient(recipient)
  if allowed then
    return false
  end

  FreshSoD_PrintRestrictionMessage(reason)
  if SendMailMailButton then
    SendMailMailButton:Enable()
  end
  return true
end

local function installCanSendHook()
  if canSendHookInstalled or type(SendMailFrame_CanSend) ~= 'function' then
    return
  end

  hooksecurefunc('SendMailFrame_CanSend', function()
    if not SendMailMailButton or not SendMailMailButton:IsEnabled() then
      return
    end

    local recipient = getRecipient()
    if not recipient or recipient == '' then
      return
    end

    local allowed = FreshSoD_CanSendMailToRecipient(recipient)
    if not allowed then
      SendMailMailButton:Disable()
    end
  end)

  canSendHookInstalled = true
end

local function installSendGuard()
  if not sendGuardInstalled then
    if type(SendMail) == 'function' then
      local origSendMail = SendMail
      SendMail = function(recipient, ...)
        if blockInvalidSend(recipient) then
          return
        end
        return origSendMail(recipient, ...)
      end
      sendGuardInstalled = true
    elseif type(SendMailFrame_SendMail) == 'function' then
      local origFrameSend = SendMailFrame_SendMail
      SendMailFrame_SendMail = function(...)
        if blockInvalidSend(getRecipient()) then
          return
        end
        return origFrameSend(...)
      end
      sendGuardInstalled = true
    end
  end

  installCanSendHook()
end

local mailSendRestrictionFrame = CreateFrame('Frame')
mailSendRestrictionFrame:RegisterEvent('PLAYER_LOGIN')
mailSendRestrictionFrame:RegisterEvent('MAIL_SHOW')
mailSendRestrictionFrame:RegisterEvent('MAIL_SEND_INFO_UPDATE')
mailSendRestrictionFrame:RegisterEvent('GUILD_ROSTER_UPDATE')

mailSendRestrictionFrame:SetScript('OnEvent', function(_, event)
  if event == 'PLAYER_LOGIN' or event == 'MAIL_SHOW' then
    installSendGuard()
    updateSendMailButtonState()
    return
  end

  updateSendMailButtonState()
end)
