function FreshSoD_AmIVerified()
    return not FreshSoD_GetDBValue('playerMoneyValidationFailed')
        and not FreshSoD_GetDBValue('buffValidationFailed')
        and FreshSoD_GetDBValue('buffVerifiedDisabled')
end