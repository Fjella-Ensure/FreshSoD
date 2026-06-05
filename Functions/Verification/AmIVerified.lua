function FreshSoD_AmIVerified()
    return not BonniesUtilities_GetNaughtyBoolean()
        and not FreshSoD_GetDBValue('buffValidationFailedAt')
        and FreshSoD_GetDBValue('buffVerifiedDisabled')
end