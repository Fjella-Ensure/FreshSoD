function FreshSoD_AmIVerified()
    return not FreshSoD_GetDBValue('playerMoneyValidationFailedAt')
        and not FreshSoD_GetDBValue('buffValidationFailedAt')
        and FreshSoD_GetDBValue('buffVerifiedDisabled')
end