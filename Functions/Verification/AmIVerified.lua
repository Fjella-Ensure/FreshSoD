function FreshSoD_AmIVerified()
    return not BonniesUtilities_GetNaughty()
        and not FreshSoD_GetDBValue('buffValidationFailedAt')
        and FreshSoD_GetDBValue('buffVerifiedDisabled')
end