function FreshSoD_AmIVerified()
    print('AmIVerified: ' .. tostring(not FreshSoD_GetDBValue('playerMoneyValidationFailed')) .. ' ' .. tostring(not FreshSoD_GetDBValue('buffValidationFailed')) .. ' ' .. tostring(FreshSoD_GetDBValue('buffVerifiedDisabled')))
    return not FreshSoD_GetDBValue('playerMoneyValidationFailed')
        and not FreshSoD_GetDBValue('buffValidationFailed')
        and FreshSoD_GetDBValue('buffVerifiedDisabled')
end