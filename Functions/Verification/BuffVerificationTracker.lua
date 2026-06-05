local buffVerificationFrame = CreateFrame('Frame')
local BUFF_DISABLE_DEADLINE_LEVEL = 10

function FreshSoD_UpdateBuffVerification()
  if FreshSoD_GetDBValue('buffValidationFailedAt') then
    return
  end

  local buffState = FreshSoD_GetVerificationBuffState()
  local playerLevel = UnitLevel('player') or 0

  if buffState == 'disabled' then
    if not FreshSoD_GetDBValue('buffVerifiedDisabled') then
      FreshSoD_SaveDBData('buffVerifiedDisabled', true)
      if FreshSoD_BroadcastGuildVerificationStatusIfChanged then
        FreshSoD_BroadcastGuildVerificationStatusIfChanged()
      end
    end
    return
  end

  if buffState == 'active' and FreshSoD_GetDBValue('buffVerifiedDisabled') then
    FreshSoD_SaveDBData('buffValidationFailedAt', time())
    if FreshSoD_BroadcastGuildVerificationStatusIfChanged then
      FreshSoD_BroadcastGuildVerificationStatusIfChanged()
    end
    return
  end

  if buffState == 'active'
      and not FreshSoD_GetDBValue('buffVerifiedDisabled')
      and playerLevel >= BUFF_DISABLE_DEADLINE_LEVEL then
    FreshSoD_SaveDBData('buffValidationFailedAt', time())
    if FreshSoD_BroadcastGuildVerificationStatusIfChanged then
      FreshSoD_BroadcastGuildVerificationStatusIfChanged()
    end
  end
end

buffVerificationFrame:RegisterEvent('UNIT_AURA')
buffVerificationFrame:RegisterEvent('PLAYER_LOGIN')

buffVerificationFrame:SetScript('OnEvent', function(_, event, unit)
  if event == 'UNIT_AURA' and unit ~= 'player' then
    return
  end
  FreshSoD_UpdateBuffVerification()
end)
