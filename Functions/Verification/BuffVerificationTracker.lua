local buffVerificationFrame = CreateFrame('Frame')

function FreshSoD_UpdateBuffVerification()
  if FreshSoD_GetDBValue('buffValidationFailed') then
    return
  end

  local buffState = FreshSoD_GetVerificationBuffState()

  if buffState == 'disabled' then
    if not FreshSoD_GetDBValue('buffVerifiedDisabled') then
      FreshSoD_SaveDBData('buffVerifiedDisabled', true)
    end
    return
  end

  if buffState == 'active' and FreshSoD_GetDBValue('buffVerifiedDisabled') then
    FreshSoD_SaveDBData('buffValidationFailed', true)
    FreshSoD_SaveDBData('buffValidationFailedAt', time())
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
